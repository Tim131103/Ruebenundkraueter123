-- ====================================================================
-- KRAUT UND RÜBEN - DSGVO-KONFORME STORED PROCEDURES
-- ====================================================================
-- Strukturierte und auditierbare Datenverarbeitung für DSGVO-Compliance
-- Erstellt: November 2025
-- Version: 1.0

-- ====================================================================
-- 1. BENUTZER-SPEZIFISCHE DATENABFRAGE (ARTIKEL 15 DSGVO)
-- ====================================================================

DELIMITER //
CREATE PROCEDURE sp_user_data_export(
    IN p_customer_id VARCHAR(50),
    IN p_requesting_user VARCHAR(100),
    IN p_purpose VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        -- Fehler-Logging
        INSERT INTO audit_log (operation_type, table_name, additional_info)
        VALUES ('SELECT', 'ERROR_LOG', JSON_OBJECT(
            'procedure', 'sp_user_data_export',
            'error', 'SQL Exception during data export',
            'customer_id', p_customer_id,
            'user', p_requesting_user
        ));
        RESIGNAL;
    END;

    START TRANSACTION;

    -- DSGVO-Zugriff protokollieren
    INSERT INTO gdpr_access_log (
        accessed_table, access_type, data_subject_id, purpose, 
        legal_basis, user_name, data_categories
    ) VALUES (
        'CUSTOMER_DATA_EXPORT', 'export', p_customer_id, p_purpose,
        'LEGAL_OBLIGATION', p_requesting_user, 'all_personal_data'
    );

    -- Vollständige Kundendaten exportieren
    SELECT 
        'KUNDENDATEN' as DATENTYP,
        k.KUNDENNR,
        k.KUNDENVORNAME,
        k.KUNDENNACHNAME,
        k.KUNDENGEBURTSDATUM,
        k.KUNDENORT,
        'Persönliche Identifikationsdaten' as KATEGORIE,
        NOW() as EXPORT_DATUM,
        p_requesting_user as EXPORTIERT_VON
    FROM KUNDE k
    WHERE k.KUNDENNR = p_customer_id

    UNION ALL

    -- Bestellhistorie
    SELECT 
        'BESTELLDATEN' as DATENTYP,
        CAST(b.BESTELLNR AS CHAR) as KUNDENNR,
        CAST(b.BESTELLDATUM AS CHAR) as KUNDENVORNAME,
        CAST(b.BESTELLWERT AS CHAR) as KUNDENNACHNAME,
        NULL as KUNDENGEBURTSDATUM,
        NULL as KUNDENORT,
        'Transaktionsdaten' as KATEGORIE,
        NOW() as EXPORT_DATUM,
        p_requesting_user as EXPORTIERT_VON
    FROM BESTELLUNG b
    WHERE b.KUNDENNR = p_customer_id;

    COMMIT;
END//
DELIMITER ;

-- ====================================================================
-- 2. DATEN-ANONYMISIERUNG (ARTIKEL 17 DSGVO)
-- ====================================================================

DELIMITER //
CREATE PROCEDURE sp_anonymize_customer_data(
    IN p_customer_id VARCHAR(50),
    IN p_reason ENUM('USER_REQUEST', 'RETENTION_POLICY', 'ADMIN_ACTION'),
    IN p_requesting_user VARCHAR(100)
)
BEGIN
    DECLARE customer_exists INT DEFAULT 0;
    DECLARE anonymization_id VARCHAR(100);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO audit_log (operation_type, table_name, additional_info)
        VALUES ('UPDATE', 'ERROR_LOG', JSON_OBJECT(
            'procedure', 'sp_anonymize_customer_data',
            'error', 'Anonymization failed',
            'customer_id', p_customer_id
        ));
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Prüfen ob Kunde existiert
    SELECT COUNT(*) INTO customer_exists
    FROM KUNDE 
    WHERE KUNDENNR = p_customer_id;

    IF customer_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer not found';
    END IF;

    -- Eindeutige Anonymisierungs-ID generieren
    SET anonymization_id = CONCAT('ANON_', UNIX_TIMESTAMP(), '_', RIGHT(p_customer_id, 4));

    -- DSGVO-Löschprotokoll erstellen
    INSERT INTO gdpr_deletion_log (
        data_subject_type, subject_id, deletion_reason,
        deleted_tables, performed_by, notes
    ) VALUES (
        'KUNDE', p_customer_id, p_reason,
        'KUNDE (anonymized)', p_requesting_user,
        CONCAT('Anonymisierung durchgeführt. Neue ID: ', anonymization_id)
    );

    -- Kundendaten anonymisieren
    UPDATE KUNDE 
    SET 
        KUNDENVORNAME = 'ANONYMISIERT',
        KUNDENNACHNAME = CONCAT('USER_', RIGHT(anonymization_id, 8)),
        KUNDENGEBURTSDATUM = '1900-01-01',
        KUNDENORT = 'ANONYMISIERT'
    WHERE KUNDENNR = p_customer_id;

    -- Audit-Log schreiben
    INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
    VALUES ('UPDATE', 'KUNDE', 1, JSON_OBJECT(
        'action', 'anonymization',
        'original_id', p_customer_id,
        'anonymized_id', anonymization_id,
        'reason', p_reason,
        'gdpr_article', 'Article 17 - Right to erasure'
    ));

    COMMIT;

    SELECT 
        'SUCCESS' as STATUS,
        p_customer_id as ORIGINAL_ID,
        anonymization_id as ANONYMIZED_ID,
        'Daten erfolgreich anonymisiert' as MESSAGE;
END//
DELIMITER ;

-- ====================================================================
-- 3. BENUTZER-SPEZIFISCHE REZEPTSUCHE
-- ====================================================================

DELIMITER //
CREATE PROCEDURE sp_user_recipe_search(
    IN p_user_role VARCHAR(50),
    IN p_customer_id VARCHAR(50),
    IN p_search_term VARCHAR(255),
    IN p_max_results INT
)
BEGIN
    DECLARE user_access_level INT DEFAULT 1;

    -- Zugriffslevel basierend auf Rolle bestimmen
    CASE p_user_role
        WHEN 'krr_admin' THEN SET user_access_level = 3;
        WHEN 'krr_user' THEN SET user_access_level = 2;
        WHEN 'krr_guest' THEN SET user_access_level = 1;
        ELSE SET user_access_level = 0;
    END CASE;

    -- Zugriff protokollieren
    INSERT INTO gdpr_access_log (
        accessed_table, access_type, data_subject_id, purpose,
        legal_basis, user_name, data_categories
    ) VALUES (
        'REZEPT_SEARCH', 'read', p_customer_id, 'Recipe search functionality',
        'LEGITIMATE_INTERESTS', USER(), 'recipe_data'
    );

    -- Rollenbasierte Rezeptsuche
    IF user_access_level >= 2 THEN
        -- Erweiterte Suche für registrierte Nutzer
        SELECT 
            r.REZEPTNR,
            r.REZEPTNAME,
            r.ZUBEREITUNGSZEIT,
            r.SCHWIERIGKEITSGRAD,
            ROUND(SUM(z.NETTOPREIS * rz.MENGE), 2) as GESCHAETZTE_KOSTEN,
            GROUP_CONCAT(DISTINCT z.BEZEICHNUNG SEPARATOR ', ') as ZUTATEN,
            (SELECT GROUP_CONCAT(DISTINCT e.ERNAEHRUNGSKATEGORIENAME SEPARATOR ', ')
             FROM REZEPTERNAEHRUNGSKATEGORIE rek 
             INNER JOIN ERNAEHRUNGSKATEGORIE e ON rek.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
             WHERE rek.REZEPTNR = r.REZEPTNR) as KATEGORIEN
        FROM REZEPT r
        INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
        INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
        WHERE r.REZEPTNAME LIKE CONCAT('%', p_search_term, '%')
           OR z.BEZEICHNUNG LIKE CONCAT('%', p_search_term, '%')
        GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT, r.SCHWIERIGKEITSGRAD
        ORDER BY r.REZEPTNAME
        LIMIT p_max_results;
    ELSE
        -- Basis-Suche für Gäste (ohne Preise)
        SELECT 
            r.REZEPTNR,
            r.REZEPTNAME,
            r.ZUBEREITUNGSZEIT,
            r.SCHWIERIGKEITSGRAD,
            'Nicht verfügbar' as GESCHAETZTE_KOSTEN,
            GROUP_CONCAT(DISTINCT z.BEZEICHNUNG SEPARATOR ', ') as ZUTATEN,
            'Registrierung erforderlich' as KATEGORIEN
        FROM REZEPT r
        INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
        INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
        WHERE r.REZEPTNAME LIKE CONCAT('%', p_search_term, '%')
        GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT, r.SCHWIERIGKEITSGRAD
        ORDER BY r.REZEPTNAME
        LIMIT LEAST(p_max_results, 10); -- Max 10 für Gäste
    END IF;
END//
DELIMITER ;

-- ====================================================================
-- 4. DSGVO-AUDIT-REPORT
-- ====================================================================

DELIMITER //
CREATE PROCEDURE sp_gdpr_audit_report(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_report_type ENUM('FULL', 'DELETIONS', 'EXPORTS', 'VIOLATIONS')
)
BEGIN
    DECLARE report_id VARCHAR(100);
    
    SET report_id = CONCAT('AUDIT_', UNIX_TIMESTAMP(), '_', p_report_type);

    -- Audit-Zugriff protokollieren
    INSERT INTO audit_log (operation_type, table_name, additional_info)
    VALUES ('SELECT', 'GDPR_AUDIT', JSON_OBJECT(
        'report_id', report_id,
        'report_type', p_report_type,
        'date_range', CONCAT(p_start_date, ' - ', p_end_date),
        'generated_by', USER()
    ));

    CASE p_report_type
        WHEN 'FULL' THEN
            -- Vollständiger DSGVO-Bericht
            SELECT 
                'OPERATIONS_SUMMARY' as SECTION,
                operation_type,
                table_name,
                COUNT(*) as ANZAHL,
                MIN(audit_date) as ERSTE_OPERATION,
                MAX(audit_date) as LETZTE_OPERATION
            FROM audit_log 
            WHERE audit_date BETWEEN p_start_date AND p_end_date
            GROUP BY operation_type, table_name
            
            UNION ALL
            
            SELECT 
                'GDPR_DELETIONS' as SECTION,
                deletion_reason as operation_type,
                deleted_tables as table_name,
                COUNT(*) as ANZAHL,
                MIN(deletion_date) as ERSTE_OPERATION,
                MAX(deletion_date) as LETZTE_OPERATION
            FROM gdpr_deletion_log
            WHERE deletion_date BETWEEN p_start_date AND p_end_date
            GROUP BY deletion_reason, deleted_tables;

        WHEN 'DELETIONS' THEN
            -- Löschungs-Report
            SELECT 
                deletion_id,
                deletion_date,
                data_subject_type,
                subject_id,
                deletion_reason,
                performed_by,
                notes
            FROM gdpr_deletion_log
            WHERE deletion_date BETWEEN p_start_date AND p_end_date
            ORDER BY deletion_date DESC;

        WHEN 'EXPORTS' THEN
            -- Datenexport-Report
            SELECT 
                access_id,
                access_date,
                data_subject_id,
                purpose,
                legal_basis,
                user_name,
                data_categories
            FROM gdpr_access_log
            WHERE access_type = 'export'
            AND access_date BETWEEN p_start_date AND p_end_date
            ORDER BY access_date DESC;

        WHEN 'VIOLATIONS' THEN
            -- Verdächtige Aktivitäten
            SELECT 
                audit_date,
                user_name,
                operation_type,
                table_name,
                additional_info
            FROM audit_log
            WHERE audit_date BETWEEN p_start_date AND p_end_date
            AND JSON_EXTRACT(additional_info, '$.alert_type') IS NOT NULL
            ORDER BY audit_date DESC;
    END CASE;
END//
DELIMITER ;

-- ====================================================================
-- 5. BENUTZER-BESTELLUNGEN ABRUFEN (DSGVO-KONFORM)
-- ====================================================================

DELIMITER //
CREATE PROCEDURE sp_user_orders(
    IN p_customer_id VARCHAR(50),
    IN p_requesting_user VARCHAR(100)
)
BEGIN
    -- Zugriffsprüfung: Nur eigene Daten oder Admin
    IF p_requesting_user NOT LIKE '%admin%' AND p_requesting_user != p_customer_id THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Access denied: You can only access your own order data';
    END IF;

    -- DSGVO-Zugriff protokollieren
    INSERT INTO gdpr_access_log (
        accessed_table, access_type, data_subject_id, purpose,
        legal_basis, user_name, data_categories
    ) VALUES (
        'BESTELLUNG', 'read', p_customer_id, 'User order history access',
        'CONTRACT', p_requesting_user, 'transaction_data'
    );

    -- Bestellungen des Kunden anzeigen
    SELECT 
        b.BESTELLNR,
        b.BESTELLDATUM,
        b.BESTELLWERT,
        GROUP_CONCAT(
            CONCAT(z.BEZEICHNUNG, ' (', bz.MENGE, ' ', bz.EINHEIT, ')')
            SEPARATOR ', '
        ) as BESTELLTE_ARTIKEL,
        COUNT(DISTINCT bz.ZUTATENNR) as ANZAHL_ARTIKEL
    FROM BESTELLUNG b
    LEFT JOIN BESTELLUNGZUTAT bz ON b.BESTELLNR = bz.BESTELLNR
    LEFT JOIN ZUTAT z ON bz.ZUTATENNR = z.ZUTATENNR
    WHERE b.KUNDENNR = p_customer_id
    GROUP BY b.BESTELLNR, b.BESTELLDATUM, b.BESTELLWERT
    ORDER BY b.BESTELLDATUM DESC;
END//
DELIMITER ;

-- ====================================================================
-- 6. DATENAUFBEWAHRUNG UND BEREINIGUNG
-- ====================================================================

DELIMITER //
CREATE PROCEDURE sp_data_retention_cleanup(
    IN p_retention_days INT,
    IN p_dry_run BOOLEAN
)
BEGIN
    DECLARE cleanup_count INT DEFAULT 0;
    DECLARE cleanup_id VARCHAR(100);
    
    SET cleanup_id = CONCAT('CLEANUP_', UNIX_TIMESTAMP());

    -- Audit-Log für Bereinigungsvorgang
    INSERT INTO audit_log (operation_type, table_name, additional_info)
    VALUES ('DELETE', 'DATA_RETENTION', JSON_OBJECT(
        'cleanup_id', cleanup_id,
        'retention_days', p_retention_days,
        'dry_run', p_dry_run,
        'initiated_by', USER()
    ));

    IF p_dry_run THEN
        -- Simulation: Was würde gelöscht werden?
        SELECT 
            'KUNDE' as TABLE_NAME,
            COUNT(*) as AFFECTED_RECORDS,
            'Inactive customers older than retention period' as DESCRIPTION
        FROM KUNDE k
        WHERE NOT EXISTS (
            SELECT 1 FROM BESTELLUNG b 
            WHERE b.KUNDENNR = k.KUNDENNR 
            AND b.BESTELLDATUM > DATE_SUB(CURDATE(), INTERVAL p_retention_days DAY)
        )
        AND k.KUNDENNR IN (
            SELECT DISTINCT b2.KUNDENNR FROM BESTELLUNG b2
            WHERE b2.BESTELLDATUM <= DATE_SUB(CURDATE(), INTERVAL p_retention_days DAY)
        );
    ELSE
        -- Tatsächliche Bereinigung
        SELECT COUNT(*) INTO cleanup_count
        FROM KUNDE k
        WHERE NOT EXISTS (
            SELECT 1 FROM BESTELLUNG b 
            WHERE b.KUNDENNR = k.KUNDENNR 
            AND b.BESTELLDATUM > DATE_SUB(CURDATE(), INTERVAL p_retention_days DAY)
        );

        -- Anonymisierung inaktiver Kunden
        UPDATE KUNDE k
        SET 
            KUNDENVORNAME = 'EXPIRED',
            KUNDENNACHNAME = CONCAT('DATA_', RIGHT(k.KUNDENNR, 6)),
            KUNDENGEBURTSDATUM = '1900-01-01',
            KUNDENORT = 'DELETED'
        WHERE NOT EXISTS (
            SELECT 1 FROM BESTELLUNG b 
            WHERE b.KUNDENNR = k.KUNDENNR 
            AND b.BESTELLDATUM > DATE_SUB(CURDATE(), INTERVAL p_retention_days DAY)
        );

        -- Bereinigungsprotokoll
        INSERT INTO gdpr_deletion_log (
            data_subject_type, deletion_reason, deleted_tables,
            retention_period_days, performed_by, notes
        ) VALUES (
            'SYSTEM', 'RETENTION_POLICY', 'KUNDE (anonymized)',
            p_retention_days, USER(),
            CONCAT('Automatic cleanup: ', cleanup_count, ' records processed')
        );

        SELECT 
            cleanup_id as CLEANUP_ID,
            cleanup_count as PROCESSED_RECORDS,
            'Data retention cleanup completed' as STATUS;
    END IF;
END//
DELIMITER ;

-- ====================================================================
-- 7. BERECHTIGUNGEN FÜR STORED PROCEDURES
-- ====================================================================

-- Admin-Procedures (alle Rechte)
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_gdpr_audit_report TO 'krr_admin'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_data_retention_cleanup TO 'krr_admin'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_anonymize_customer_data TO 'krr_admin'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_user_data_export TO 'krr_admin'@'%';

-- User-Procedures (eingeschränkt)
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_user_recipe_search TO 'krr_user'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_user_orders TO 'krr_user'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_user_data_export TO 'krr_user'@'%';

-- Guest-Procedures (minimal)
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_user_recipe_search TO 'krr_guest'@'%';

-- Auditor-Procedures (nur Lesezugriff)
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_gdpr_audit_report TO 'krr_auditor'@'%';

-- ====================================================================
-- DOKUMENTATION DER STORED PROCEDURES
-- ====================================================================
/*
DSGVO-KONFORME STORED PROCEDURES ÜBERSICHT:

1. sp_user_data_export
   - Artikel 15 DSGVO: Recht auf Auskunft
   - Vollständiger Export aller Nutzerdaten
   - Auditierbar und protokolliert

2. sp_anonymize_customer_data
   - Artikel 17 DSGVO: Recht auf Vergessenwerden
   - Sichere Anonymisierung von Kundendaten
   - Erhalt der Datenintegrität

3. sp_user_recipe_search
   - Rollenbasierte Datenzugriffe
   - DSGVO-konforme Protokollierung
   - Minimale Datenoffenlegung

4. sp_gdpr_audit_report
   - Umfassende Audit-Berichte
   - Compliance-Überwachung
   - Verschiedene Report-Typen

5. sp_user_orders
   - Zugriffskontrolle auf eigene Daten
   - Transparenz über Datenverarbeitung
   - Auditierte Datenzugriffe

6. sp_data_retention_cleanup
   - Automatische Datenaufbewahrung
   - DSGVO-konforme Löschfristen
   - Dry-Run Funktionalität

COMPLIANCE-MERKMALE:
- Vollständige Auditierbarkeit
- Rollenbasierte Zugriffskontrolle  
- Automatische DSGVO-Protokollierung
- Sichere Datenverarbeitung
- Transparente Berechtigungen
*/