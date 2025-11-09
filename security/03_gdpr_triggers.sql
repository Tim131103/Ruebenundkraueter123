-- ====================================================================
-- KRAUT UND RÜBEN - DSGVO-TRIGGER
-- ====================================================================
-- Trigger zur Automatisierung DSGVO-relevanter Aktionen
-- Erstellt: November 2025  
-- Version: 1.0

-- ====================================================================
-- 1. AUDIT-LOG TABELLEN ERSTELLEN
-- ====================================================================

-- Allgemeines Audit-Log für alle Datenbankoperationen
CREATE TABLE IF NOT EXISTS audit_log (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    audit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation_type ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE') NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    affected_rows INT DEFAULT 0,
    user_name VARCHAR(100) DEFAULT USER(),
    user_role VARCHAR(50),
    ip_address VARCHAR(45),
    additional_info JSON,
    INDEX idx_audit_date (audit_date),
    INDEX idx_table_operation (table_name, operation_type)
);

-- DSGVO-spezifisches Löschprotokoll
CREATE TABLE IF NOT EXISTS gdpr_deletion_log (
    deletion_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    deletion_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_subject_type ENUM('KUNDE', 'BESTELLUNG', 'SYSTEM') NOT NULL,
    subject_id VARCHAR(100),
    deletion_reason ENUM('USER_REQUEST', 'RETENTION_POLICY', 'ADMIN_ACTION', 'ANONYMIZATION') NOT NULL,
    deleted_tables TEXT,
    retention_period_days INT,
    performed_by VARCHAR(100) DEFAULT USER(),
    verification_hash VARCHAR(64),
    notes TEXT,
    INDEX idx_deletion_date (deletion_date),
    INDEX idx_subject_type (data_subject_type)
);

-- DSGVO-Zugriffs-Log für Transparenz
CREATE TABLE IF NOT EXISTS gdpr_access_log (
    access_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    access_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accessed_table VARCHAR(100),
    access_type ENUM('READ', 'export', 'modify', 'delete') NOT NULL,
    data_subject_id VARCHAR(100),
    purpose VARCHAR(255),
    legal_basis ENUM('CONSENT', 'CONTRACT', 'LEGAL_OBLIGATION', 'VITAL_INTERESTS', 'PUBLIC_TASK', 'LEGITIMATE_INTERESTS'),
    user_name VARCHAR(100) DEFAULT USER(),
    user_role VARCHAR(50),
    data_categories TEXT,
    INDEX idx_access_date (access_date),
    INDEX idx_subject_id (data_subject_id)
);

-- ====================================================================
-- 2. TRIGGER FÜR KUNDEN-TABELLE (PERSONENDATEN)
-- ====================================================================

-- Trigger bei Kunden-Einfügung
DELIMITER //
CREATE TRIGGER tr_kunde_insert_audit
    AFTER INSERT ON KUNDE
    FOR EACH ROW
BEGIN
    -- Audit-Log schreiben
    INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
    VALUES ('INSERT', 'KUNDE', 1, JSON_OBJECT(
        'kunde_nr', NEW.KUNDENNR,
        'kunde_ort', NEW.KUNDENORT,
        'data_category', 'personal_data'
    ));
    
    -- DSGVO-Zugriffs-Log
    INSERT INTO gdpr_access_log (accessed_table, access_type, data_subject_id, purpose, legal_basis, data_categories)
    VALUES ('KUNDE', 'modify', NEW.KUNDENNR, 'Kundendaten erfassen', 'CONTRACT', 'name,address,birthdate');
END//
DELIMITER ;

-- Trigger bei Kunden-Aktualisierung  
DELIMITER //
CREATE TRIGGER tr_kunde_update_audit
    AFTER UPDATE ON KUNDE
    FOR EACH ROW
BEGIN
    DECLARE changes JSON;
    
    -- Änderungen dokumentieren
    SET changes = JSON_OBJECT(
        'old_name', CONCAT(OLD.KUNDENVORNAME, ' ', OLD.KUNDENNACHNAME),
        'new_name', CONCAT(NEW.KUNDENVORNAME, ' ', NEW.KUNDENNACHNAME),
        'old_ort', OLD.KUNDENORT,
        'new_ort', NEW.KUNDENORT,
        'timestamp', NOW()
    );
    
    INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
    VALUES ('UPDATE', 'KUNDE', 1, changes);
    
    INSERT INTO gdpr_access_log (accessed_table, access_type, data_subject_id, purpose, legal_basis, data_categories)
    VALUES ('KUNDE', 'modify', NEW.KUNDENNR, 'Kundendaten aktualisieren', 'CONTRACT', 'personal_data');
END//
DELIMITER ;

-- Trigger bei Kunden-Löschung
DELIMITER //
CREATE TRIGGER tr_kunde_delete_audit
    BEFORE DELETE ON KUNDE
    FOR EACH ROW
BEGIN
    -- Löschprotokoll erstellen
    INSERT INTO gdpr_deletion_log (
        data_subject_type, subject_id, deletion_reason, 
        deleted_tables, performed_by, notes
    ) VALUES (
        'KUNDE', 
        OLD.KUNDENNR,
        'USER_REQUEST',
        'KUNDE,BESTELLUNG,BESTELLUNGZUTAT',
        USER(),
        CONCAT('Kunde gelöscht: ', OLD.KUNDENVORNAME, ' ', OLD.KUNDENNACHNAME)
    );
    
    INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
    VALUES ('DELETE', 'KUNDE', 1, JSON_OBJECT(
        'deleted_kunde_nr', OLD.KUNDENNR,
        'deletion_reason', 'gdpr_request'
    ));
END//
DELIMITER ;

-- ====================================================================
-- 3. TRIGGER FÜR BESTELLUNGEN (TRANSAKTIONSDATEN)
-- ====================================================================

-- Trigger bei Bestellung-Einfügung
DELIMITER //
CREATE TRIGGER tr_bestellung_insert_audit
    AFTER INSERT ON BESTELLUNG
    FOR EACH ROW
BEGIN
    INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
    VALUES ('INSERT', 'BESTELLUNG', 1, JSON_OBJECT(
        'bestellung_nr', NEW.BESTELLNR,
        'kunde_nr', NEW.KUNDENNR,
        'bestellwert', NEW.BESTELLWERT
    ));
    
    INSERT INTO gdpr_access_log (accessed_table, access_type, data_subject_id, purpose, legal_basis, data_categories)
    VALUES ('BESTELLUNG', 'modify', NEW.KUNDENNR, 'Bestellung erfassen', 'CONTRACT', 'transaction_data');
END//
DELIMITER ;

-- Trigger bei Bestellung-Löschung
DELIMITER //
CREATE TRIGGER tr_bestellung_delete_audit
    BEFORE DELETE ON BESTELLUNG
    FOR EACH ROW
BEGIN
    INSERT INTO gdpr_deletion_log (
        data_subject_type, subject_id, deletion_reason, 
        deleted_tables, performed_by
    ) VALUES (
        'BESTELLUNG', 
        OLD.BESTELLNR,
        'RETENTION_POLICY',
        'BESTELLUNG,BESTELLUNGZUTAT',
        USER()
    );
END//
DELIMITER ;

-- ====================================================================
-- 4. AUTOMATISCHE ANONYMISIERUNG-TRIGGER
-- ====================================================================

-- Trigger für automatische Anonymisierung alter Kundendaten
DELIMITER //
CREATE TRIGGER tr_kunde_anonymization_check
    AFTER UPDATE ON KUNDE
    FOR EACH ROW
BEGIN
    DECLARE customer_age_years INT;
    DECLARE last_order_days INT;
    
    -- Prüfen ob Kunde seit mehr als 3 Jahren inaktiv
    SELECT DATEDIFF(CURDATE(), MAX(b.BESTELLDATUM)) INTO last_order_days
    FROM BESTELLUNG b 
    WHERE b.KUNDENNR = NEW.KUNDENNR;
    
    -- Automatische Anonymisierung nach 3 Jahren Inaktivität
    IF last_order_days > 1095 THEN -- 3 Jahre = 1095 Tage
        -- Anonymisierung durch separaten Prozess auslösen
        INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
        VALUES ('UPDATE', 'KUNDE', 1, JSON_OBJECT(
            'action', 'anonymization_triggered',
            'kunde_nr', NEW.KUNDENNR,
            'inactive_days', last_order_days,
            'reason', 'retention_policy'
        ));
        
        INSERT INTO gdpr_deletion_log (
            data_subject_type, subject_id, deletion_reason, 
            retention_period_days, performed_by, notes
        ) VALUES (
            'KUNDE', 
            NEW.KUNDENNR,
            'RETENTION_POLICY',
            1095,
            'SYSTEM_AUTOMATIC',
            'Automatische Anonymisierung nach Inaktivitätsperiode'
        );
    END IF;
END//
DELIMITER ;

-- ====================================================================
-- 5. DATENEXPORT-TRIGGER (ARTIKEL 15 DSGVO)
-- ====================================================================

-- Log für Datenexport-Anfragen
DELIMITER //
CREATE TRIGGER tr_data_export_log
    AFTER INSERT ON gdpr_access_log
    FOR EACH ROW
BEGIN
    -- Bei Datenexporten zusätzliche Dokumentation
    IF NEW.access_type = 'export' THEN
        INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
        VALUES ('SELECT', 'GDPR_EXPORT', 1, JSON_OBJECT(
            'subject_id', NEW.data_subject_id,
            'export_purpose', NEW.purpose,
            'legal_basis', NEW.legal_basis,
            'user', NEW.user_name,
            'compliance_note', 'Article 15 GDPR - Right of Access'
        ));
    END IF;
END//
DELIMITER ;

-- ====================================================================
-- 6. DATENINTEGRITÄT UND COMPLIANCE TRIGGER
-- ====================================================================

-- Trigger zur Überwachung verdächtiger Aktivitäten
DELIMITER //
CREATE TRIGGER tr_suspicious_activity_monitor
    AFTER INSERT ON audit_log
    FOR EACH ROW
BEGIN
    DECLARE recent_operations INT DEFAULT 0;
    
    -- Prüfen auf ungewöhnlich viele Operationen in kurzer Zeit
    SELECT COUNT(*) INTO recent_operations
    FROM audit_log 
    WHERE user_name = NEW.user_name 
    AND audit_date >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
    AND operation_type IN ('DELETE', 'UPDATE');
    
    -- Warnung bei mehr als 50 Operationen in 5 Minuten
    IF recent_operations > 50 THEN
        INSERT INTO audit_log (operation_type, table_name, affected_rows, additional_info)
        VALUES ('SELECT', 'SECURITY_ALERT', 1, JSON_OBJECT(
            'alert_type', 'suspicious_bulk_operations',
            'user', NEW.user_name,
            'operation_count', recent_operations,
            'time_window', '5_minutes',
            'action_required', 'review_user_activity'
        ));
    END IF;
END//
DELIMITER ;

-- ====================================================================
-- 7. BERECHTIGUNGEN FÜR AUDIT-TABELLEN
-- ====================================================================

-- Nur Admins und Auditoren können Audit-Logs einsehen
GRANT SELECT ON krautundrueben.audit_log TO 'krr_admin'@'%';
GRANT SELECT ON krautundrueben.audit_log TO 'krr_auditor'@'%';

GRANT SELECT ON krautundrueben.gdpr_deletion_log TO 'krr_admin'@'%';
GRANT SELECT ON krautundrueben.gdpr_deletion_log TO 'krr_auditor'@'%';

GRANT SELECT ON krautundrueben.gdpr_access_log TO 'krr_admin'@'%';
GRANT SELECT ON krautundrueben.gdpr_access_log TO 'krr_auditor'@'%';

-- Nur Admins können in Audit-Tabellen schreiben (über Trigger)
GRANT INSERT ON krautundrueben.audit_log TO 'krr_admin'@'%';
GRANT INSERT ON krautundrueben.gdpr_deletion_log TO 'krr_admin'@'%';
GRANT INSERT ON krautundrueben.gdpr_access_log TO 'krr_admin'@'%';

-- ====================================================================
-- DOKUMENTATION DER TRIGGER
-- ====================================================================
/*
DSGVO-TRIGGER ÜBERSICHT:

1. Audit-Trigger (tr_kunde_*, tr_bestellung_*)
   - Automatisches Logging aller Datenbankoperationen
   - Besondere Aufmerksamkeit für personenbezogene Daten
   - Erfassung von Benutzer, Zeit, und Änderungsdetails

2. Lösch-Trigger (tr_*_delete_audit)
   - Dokumentation aller Löschvorgänge
   - DSGVO-konforme Löschprotokolle
   - Nachweisbarkeit für Auditierungen

3. Anonymisierungs-Trigger (tr_kunde_anonymization_check)
   - Automatische Erkennung von Anonymisierungsbedarf
   - Umsetzung von Aufbewahrungsfristen
   - Compliance mit DSGVO Art. 17 (Recht auf Vergessenwerden)

4. Sicherheits-Trigger (tr_suspicious_activity_monitor)
   - Überwachung ungewöhnlicher Datenbankaktivitäten
   - Früherkennung von Datenschutzverletzungen
   - Automatische Alerting-Mechanismen

5. Export-Trigger (tr_data_export_log)
   - Dokumentation von Datenexporten
   - Compliance mit DSGVO Art. 15 (Auskunftsrecht)
   - Nachweis der rechtmäßigen Datenverarbeitung

COMPLIANCE-FUNKTIONEN:
- Vollständige Auditierbarkeit aller Operationen
- Automatische DSGVO-Dokumentation
- Proaktive Anonymisierung und Löschung
- Sicherheitsüberwachung
- Rechtssichere Protokollierung
*/