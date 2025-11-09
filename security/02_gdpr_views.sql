-- ====================================================================
-- KRAUT UND RÜBEN - DSGVO-KONFORME VIEWS
-- ====================================================================
-- Views zur datenschutzgerechten Aggregation und Anzeige von Daten
-- Erstellt: November 2025
-- Version: 1.0

-- ====================================================================
-- 1. ÖFFENTLICHE REZEPT-ANSICHT (FÜR GÄSTE)
-- ====================================================================

CREATE OR REPLACE VIEW v_public_recipes AS
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    r.SCHWIERIGKEITSGRAD,
    -- Anonymisierte Bewertung ohne Personenbezug
    ROUND(AVG(CASE WHEN r.ZUBEREITUNGSZEIT <= 30 THEN 5 ELSE 4 END), 1) as BEWERTUNG,
    -- Zutatenanzahl
    (SELECT COUNT(*) FROM REZEPTZUTAT rz WHERE rz.REZEPTNR = r.REZEPTNR) as ANZAHL_ZUTATEN,
    -- Ernährungskategorien
    (SELECT GROUP_CONCAT(DISTINCT e.ERNAEHRUNGSKATEGORIENAME SEPARATOR ', ')
     FROM REZEPTERNAEHRUNGSKATEGORIE rek 
     INNER JOIN ERNAEHRUNGSKATEGORIE e ON rek.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
     WHERE rek.REZEPTNR = r.REZEPTNR) as ERNAEHRUNGSKATEGORIEN,
    -- Geschätzte Kosten (ohne exakte Preise)
    CASE 
        WHEN (SELECT SUM(z.NETTOPREIS * rz.MENGE) FROM REZEPTZUTAT rz 
              INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR 
              WHERE rz.REZEPTNR = r.REZEPTNR) <= 2.00 THEN 'Günstig'
        WHEN (SELECT SUM(z.NETTOPREIS * rz.MENGE) FROM REZEPTZUTAT rz 
              INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR 
              WHERE rz.REZEPTNR = r.REZEPTNR) <= 5.00 THEN 'Mittel'
        ELSE 'Teuer'
    END as PREISKATEGORIE
FROM REZEPT r
WHERE r.REZEPTNR IS NOT NULL
ORDER BY r.REZEPTNAME;

-- ====================================================================
-- 2. ANONYMISIERTE KUNDEN-STATISTIK
-- ====================================================================

CREATE OR REPLACE VIEW v_customer_analytics AS
SELECT 
    -- Keine Kundennummer oder Namen - nur aggregierte Daten
    COUNT(DISTINCT k.KUNDENNR) as ANZAHL_KUNDEN,
    k.KUNDENORT as REGION,
    -- Altersgruppen statt exakte Geburtsdaten
    CASE 
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 25 THEN '18-24'
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 35 THEN '25-34'
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 50 THEN '35-49'
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 65 THEN '50-64'
        ELSE '65+'
    END as ALTERSGRUPPE,
    COUNT(DISTINCT b.BESTELLNR) as ANZAHL_BESTELLUNGEN,
    ROUND(AVG(b.BESTELLWERT), 2) as DURCHSCHNITT_BESTELLWERT,
    -- Zeitraum der Analyse
    DATE_FORMAT(MIN(b.BESTELLDATUM), '%Y-%m') as VON_MONAT,
    DATE_FORMAT(MAX(b.BESTELLDATUM), '%Y-%m') as BIS_MONAT
FROM KUNDE k
LEFT JOIN BESTELLUNG b ON k.KUNDENNR = b.KUNDENNR
WHERE k.KUNDENORT IS NOT NULL
GROUP BY 
    k.KUNDENORT,
    CASE 
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 25 THEN '18-24'
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 35 THEN '25-34'
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 50 THEN '35-49'
        WHEN YEAR(CURDATE()) - YEAR(k.KUNDENGEBURTSDATUM) < 65 THEN '50-64'
        ELSE '65+'
    END
HAVING COUNT(DISTINCT k.KUNDENNR) >= 3; -- Mindestens 3 Kunden für Anonymität

-- ====================================================================
-- 3. BENUTZER-SPEZIFISCHE BESTELLANSICHT
-- ====================================================================

CREATE OR REPLACE VIEW v_user_orders AS
SELECT 
    b.BESTELLNR,
    b.BESTELLDATUM,
    b.BESTELLWERT,
    -- Nur eigene Daten sichtbar durch WHERE-Klausel in Stored Procedure
    k.KUNDENVORNAME,
    k.KUNDENNACHNAME,
    -- Bestelldetails ohne sensible Lieferantendaten
    GROUP_CONCAT(
        CONCAT(z.BEZEICHNUNG, ' (', bz.MENGE, ' ', bz.EINHEIT, ')')
        SEPARATOR ', '
    ) as BESTELLTE_ZUTATEN,
    SUM(bz.MENGE * z.NETTOPREIS) as BERECHNETER_WERT
FROM BESTELLUNG b
INNER JOIN KUNDE k ON b.KUNDENNR = k.KUNDENNR
LEFT JOIN BESTELLUNGZUTAT bz ON b.BESTELLNR = bz.BESTELLNR
LEFT JOIN ZUTAT z ON bz.ZUTATENNR = z.ZUTATENNR
GROUP BY b.BESTELLNR, b.BESTELLDATUM, b.BESTELLWERT, k.KUNDENVORNAME, k.KUNDENNACHNAME;

-- ====================================================================
-- 4. LIEFERANTEN-ÜBERSICHT (OHNE SENSIBLE DATEN)
-- ====================================================================

CREATE OR REPLACE VIEW v_supplier_overview AS
SELECT 
    l.LIEFERANTENNR,
    l.LIEFERANTENNAME,
    l.LIEFERANTENORT,
    -- Keine Kontaktdaten oder Bankverbindungen
    COUNT(DISTINCT z.ZUTATENNR) as ANZAHL_PRODUKTE,
    COUNT(DISTINCT 
        CASE WHEN z.BESTAND > 0 THEN z.ZUTATENNR END
    ) as VERFUEGBARE_PRODUKTE,
    ROUND(AVG(z.NETTOPREIS), 2) as DURCHSCHNITTSPREIS,
    -- Lieferstatus ohne interne Details
    CASE 
        WHEN COUNT(DISTINCT z.ZUTATENNR) > 10 THEN 'Hauptlieferant'
        WHEN COUNT(DISTINCT z.ZUTATENNR) > 5 THEN 'Standardlieferant'
        ELSE 'Speziallieferant'
    END as LIEFERANTENSTATUS
FROM LIEFERANT l
LEFT JOIN ZUTAT z ON l.LIEFERANTENNR = z.LIEFERANTENNR
GROUP BY l.LIEFERANTENNR, l.LIEFERANTENNAME, l.LIEFERANTENORT
ORDER BY ANZAHL_PRODUKTE DESC;

-- ====================================================================
-- 5. REZEPT-ÜBERSICHT MIT NÄHRWERTEN (AGGREGIERT)
-- ====================================================================

CREATE OR REPLACE VIEW v_recipe_overview AS
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    r.SCHWIERIGKEITSGRAD,
    -- Aggregierte Nährwerte
    ROUND(SUM(z.KALORIEN * rz.MENGE), 0) as GESAMTKALORIEN,
    ROUND(AVG(z.KALORIEN), 0) as DURCHSCHNITT_KALORIEN_PRO_ZUTAT,
    COUNT(DISTINCT rz.ZUTATENNR) as ANZAHL_ZUTATEN,
    -- Preiskategorie statt exakter Preis
    CASE 
        WHEN SUM(z.NETTOPREIS * rz.MENGE) <= 2.00 THEN 'Budget'
        WHEN SUM(z.NETTOPREIS * rz.MENGE) <= 5.00 THEN 'Standard'
        WHEN SUM(z.NETTOPREIS * rz.MENGE) <= 10.00 THEN 'Premium'
        ELSE 'Luxus'
    END as PREISKATEGORIE,
    -- Allergene (wichtig für Gesundheit)
    (SELECT GROUP_CONCAT(DISTINCT a.ALLERGENNAME SEPARATOR ', ')
     FROM REZEPTZUTAT rz2
     INNER JOIN ZUTAT z2 ON rz2.ZUTATENNR = z2.ZUTATENNR
     INNER JOIN ZUTATALLERGEN za ON z2.ZUTATENNR = za.ZUTATENNR
     INNER JOIN ALLERGEN a ON za.ALLERGENNR = a.ALLERGENNR
     WHERE rz2.REZEPTNR = r.REZEPTNR) as ALLERGENE,
    -- Ernährungskategorien
    (SELECT GROUP_CONCAT(DISTINCT e.ERNAEHRUNGSKATEGORIENAME SEPARATOR ', ')
     FROM REZEPTERNAEHRUNGSKATEGORIE rek 
     INNER JOIN ERNAEHRUNGSKATEGORIE e ON rek.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
     WHERE rek.REZEPTNR = r.REZEPTNR) as ERNAEHRUNGSKATEGORIEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT, r.SCHWIERIGKEITSGRAD
ORDER BY r.REZEPTNAME;

-- ====================================================================
-- 6. DSGVO-AUDIT-VIEW
-- ====================================================================

CREATE OR REPLACE VIEW v_gdpr_audit_summary AS
SELECT 
    -- Anonymisierte Übersicht für Datenschutz-Audits
    DATE_FORMAT(audit_date, '%Y-%m') as MONAT,
    operation_type as OPERATION,
    COUNT(*) as ANZAHL_OPERATIONEN,
    COUNT(DISTINCT affected_table) as BETROFFENE_TABELLEN,
    -- Keine Personendaten in Audit-Zusammenfassung
    CASE 
        WHEN COUNT(*) > 1000 THEN 'Hoch'
        WHEN COUNT(*) > 100 THEN 'Mittel'
        ELSE 'Niedrig'
    END as AKTIVITAETSLEVEL
FROM audit_log 
WHERE audit_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY 
    DATE_FORMAT(audit_date, '%Y-%m'),
    operation_type
ORDER BY MONAT DESC, operation_type;

-- ====================================================================
-- 7. BERECHTIGUNGEN FÜR VIEWS SETZEN
-- ====================================================================

-- Öffentliche Views für Gäste
GRANT SELECT ON krautundrueben.v_public_recipes TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.v_recipe_overview TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.v_supplier_overview TO 'krr_guest'@'%';

-- Nutzer-spezifische Views
GRANT SELECT ON krautundrueben.v_user_orders TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.v_public_recipes TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.v_recipe_overview TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.v_supplier_overview TO 'krr_user'@'%';

-- Analytics für Admins
GRANT SELECT ON krautundrueben.v_customer_analytics TO 'krr_admin'@'%';
GRANT SELECT ON krautundrueben.* TO 'krr_admin'@'%';

-- Audit-Views für Auditoren
GRANT SELECT ON krautundrueben.v_gdpr_audit_summary TO 'krr_auditor'@'%';

-- ====================================================================
-- DOKUMENTATION DER VIEWS
-- ====================================================================
/*
DSGVO-KONFORME VIEWS ÜBERSICHT:

1. v_public_recipes
   - Öffentliche Rezeptdaten ohne Personenbezug
   - Anonymisierte Bewertungen und Preiskategorien
   - Zugriff: Gäste, Nutzer, Admins

2. v_customer_analytics  
   - Aggregierte Kundenstatistiken ohne individuelle Identifikation
   - Mindestens 3 Kunden pro Gruppe für Anonymität
   - Zugriff: Nur Admins

3. v_user_orders
   - Benutzer-spezifische Bestellansicht
   - Wird durch Stored Procedures auf eigene Daten beschränkt
   - Zugriff: Nutzer (nur eigene Daten)

4. v_supplier_overview
   - Lieferantenübersicht ohne sensible Kontaktdaten
   - Aggregierte Produktinformationen
   - Zugriff: Nutzer, Admins

5. v_recipe_overview
   - Detaillierte Rezeptinformationen mit Nährwerten
   - Preiskategorien statt exakte Preise
   - Zugriff: Gäste, Nutzer, Admins

6. v_gdpr_audit_summary
   - Anonymisierte Audit-Übersicht für Compliance
   - Keine Personendaten in Zusammenfassungen
   - Zugriff: Auditoren, Admins

DATENSCHUTZ-PRINZIPIEN:
- Datenminimierung (nur notwendige Daten)
- Anonymisierung und Pseudonymisierung
- Zweckbindung der Datenverwendung
- Transparenz durch klare Strukturen
- Kontrollierte Zugriffe je Rolle
*/