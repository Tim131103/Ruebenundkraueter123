-- ====================================================================
-- KRAUT UND RÜBEN - ZUGRIFFSKONZEPT: ROLLEN UND BERECHTIGUNGEN
-- ====================================================================
-- Implementierung von Rollen zur Steuerung von Berechtigungen gemäß DSGVO
-- Erstellt: November 2025
-- Version: 1.0

-- ====================================================================
-- 1. BENUTZER-ROLLEN ERSTELLEN
-- ====================================================================

-- Admin-Rolle: Vollzugriff auf alle Daten und Funktionen
CREATE ROLE IF NOT EXISTS 'krr_admin'@'%';

-- Nutzer-Rolle: Zugriff auf eigene Daten und öffentliche Rezepte
CREATE ROLE IF NOT EXISTS 'krr_user'@'%';

-- Gast-Rolle: Nur Lesezugriff auf öffentliche Rezeptdaten
CREATE ROLE IF NOT EXISTS 'krr_guest'@'%';

-- Audit-Rolle: Spezielle Rolle für Audit-Logs und DSGVO-Compliance
CREATE ROLE IF NOT EXISTS 'krr_auditor'@'%';

-- ====================================================================
-- 2. ADMIN-BERECHTIGUNGEN (Vollzugriff)
-- ====================================================================

-- Vollzugriff auf alle Tabellen
GRANT ALL PRIVILEGES ON krautundrueben.* TO 'krr_admin'@'%';

-- Berechtigung zur Erstellung und Verwaltung von Benutzern
GRANT CREATE USER ON *.* TO 'krr_admin'@'%';
GRANT GRANT OPTION ON krautundrueben.* TO 'krr_admin'@'%';

-- Berechtigung für Stored Procedures und Functions
GRANT CREATE ROUTINE ON krautundrueben.* TO 'krr_admin'@'%';
GRANT ALTER ROUTINE ON krautundrueben.* TO 'krr_admin'@'%';
GRANT EXECUTE ON krautundrueben.* TO 'krr_admin'@'%';

-- ====================================================================
-- 3. NUTZER-BERECHTIGUNGEN (Eingeschränkt auf eigene Daten)
-- ====================================================================

-- Lesezugriff auf Rezepte und öffentliche Daten
GRANT SELECT ON krautundrueben.REZEPT TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.ZUTAT TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.REZEPTZUTAT TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.ERNAEHRUNGSKATEGORIE TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.REZEPTERNAEHRUNGSKATEGORIE TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.ALLERGEN TO 'krr_user'@'%';
GRANT SELECT ON krautundrueben.ZUTATALLERGEN TO 'krr_user'@'%';

-- Vollzugriff auf eigene Bestellungen
GRANT SELECT, INSERT, UPDATE ON krautundrueben.BESTELLUNG TO 'krr_user'@'%';
GRANT SELECT, INSERT, UPDATE ON krautundrueben.BESTELLUNGZUTAT TO 'krr_user'@'%';

-- Lesezugriff auf Lieferanten (ohne sensible Daten)
GRANT SELECT(LIEFERANTENNR, LIEFERANTENNAME, LIEFERANTENORT) ON krautundrueben.LIEFERANT TO 'krr_user'@'%';

-- Zugriff auf anonymisierte Kundendaten (nur Views)
-- Kein direkter Zugriff auf KUNDE-Tabelle

-- Berechtigung für nutzer-spezifische Stored Procedures
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_user_recipes TO 'krr_user'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_user_orders TO 'krr_user'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_anonymize_user_data TO 'krr_user'@'%';

-- ====================================================================
-- 4. GAST-BERECHTIGUNGEN (Nur öffentliche Daten)
-- ====================================================================

-- Nur Lesezugriff auf öffentliche Rezeptdaten
GRANT SELECT ON krautundrueben.REZEPT TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.ZUTAT TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.REZEPTZUTAT TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.ERNAEHRUNGSKATEGORIE TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.REZEPTERNAEHRUNGSKATEGORIE TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.ALLERGEN TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.ZUTATALLERGEN TO 'krr_guest'@'%';

-- Zugriff nur auf öffentliche Views
GRANT SELECT ON krautundrueben.v_public_recipes TO 'krr_guest'@'%';
GRANT SELECT ON krautundrueben.v_recipe_overview TO 'krr_guest'@'%';

-- Berechtigung für öffentliche Stored Procedures
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_public_recipe_search TO 'krr_guest'@'%';

-- ====================================================================
-- 5. AUDITOR-BERECHTIGUNGEN (DSGVO-Compliance)
-- ====================================================================

-- Lesezugriff auf Audit-Logs und DSGVO-relevante Tabellen
GRANT SELECT ON krautundrueben.audit_log TO 'krr_auditor'@'%';
GRANT SELECT ON krautundrueben.gdpr_deletion_log TO 'krr_auditor'@'%';
GRANT SELECT ON krautundrueben.gdpr_access_log TO 'krr_auditor'@'%';

-- Berechtigung für DSGVO-spezifische Procedures
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_gdpr_data_export TO 'krr_auditor'@'%';
GRANT EXECUTE ON PROCEDURE krautundrueben.sp_gdpr_audit_report TO 'krr_auditor'@'%';

-- ====================================================================
-- 6. BEISPIEL-BENUTZER ERSTELLEN
-- ====================================================================

-- Admin-Benutzer
CREATE USER IF NOT EXISTS 'admin_user'@'%' IDENTIFIED BY 'AdminPass2024!';
GRANT 'krr_admin'@'%' TO 'admin_user'@'%';
SET DEFAULT ROLE 'krr_admin'@'%' TO 'admin_user'@'%';

-- Normaler Benutzer
CREATE USER IF NOT EXISTS 'recipe_user'@'%' IDENTIFIED BY 'UserPass2024!';
GRANT 'krr_user'@'%' TO 'recipe_user'@'%';
SET DEFAULT ROLE 'krr_user'@'%' TO 'recipe_user'@'%';

-- Gast-Benutzer
CREATE USER IF NOT EXISTS 'guest_user'@'%' IDENTIFIED BY 'GuestPass2024!';
GRANT 'krr_guest'@'%' TO 'guest_user'@'%';
SET DEFAULT ROLE 'krr_guest'@'%' TO 'guest_user'@'%';

-- Auditor
CREATE USER IF NOT EXISTS 'gdpr_auditor'@'%' IDENTIFIED BY 'AuditPass2024!';
GRANT 'krr_auditor'@'%' TO 'gdpr_auditor'@'%';
SET DEFAULT ROLE 'krr_auditor'@'%' TO 'gdpr_auditor'@'%';

-- ====================================================================
-- 7. SICHERHEITSRICHTLINIEN
-- ====================================================================

-- Passwort-Validierung aktivieren
-- SET GLOBAL validate_password.policy = MEDIUM;
-- SET GLOBAL validate_password.length = 12;

-- Session-Timeout für Sicherheit
-- SET GLOBAL interactive_timeout = 1800; -- 30 Minuten
-- SET GLOBAL wait_timeout = 1800;

-- ====================================================================
-- 8. BERECHTIGUNGEN ANZEIGEN (Kontroll-Queries)
-- ====================================================================

-- Alle Rollen anzeigen
-- SHOW GRANTS FOR 'krr_admin'@'%';
-- SHOW GRANTS FOR 'krr_user'@'%';
-- SHOW GRANTS FOR 'krr_guest'@'%';
-- SHOW GRANTS FOR 'krr_auditor'@'%';

-- Aktuelle Benutzer-Rollen prüfen
-- SELECT USER, HOST, DEFAULT_ROLE FROM mysql.user WHERE USER LIKE 'krr_%' OR USER LIKE '%_user' OR USER LIKE 'gdpr_auditor';

-- ====================================================================
-- DOKUMENTATION DER ROLLEN-HIERARCHIE
-- ====================================================================
/*
ROLLEN-ÜBERSICHT:

1. krr_admin (Administrator)
   - Vollzugriff auf alle Daten und Funktionen
   - Kann Benutzer erstellen und verwalten
   - Zugriff auf alle Stored Procedures
   - DSGVO: Verantwortlich für Datenschutz-Compliance

2. krr_user (Registrierter Nutzer)
   - Lesezugriff auf öffentliche Rezeptdaten
   - Vollzugriff auf eigene Bestellungen
   - Kein Zugriff auf andere Nutzerdaten
   - DSGVO: Kann eigene Daten anonymisieren/löschen

3. krr_guest (Gast)
   - Nur Lesezugriff auf öffentliche Rezepte
   - Keine Personendaten-Zugriffe
   - Minimale Berechtigungen
   - DSGVO: Keine persönlichen Daten verarbeitet

4. krr_auditor (Datenschutz-Auditor)
   - Zugriff auf Audit-Logs
   - DSGVO-Compliance Überwachung
   - Berechtigung für Datenschutz-Reports
   - Keine Änderungsberechtigung an Produktivdaten

SICHERHEITSPRINZIPIEN:
- Principle of Least Privilege (minimale erforderliche Berechtigungen)
- Role-based Access Control (RBAC)
- Datenschutz by Design
- Auditierbarkeit aller Datenzugriffe
*/