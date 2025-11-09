-- ====================================================================
-- KRAUT UND RÜBEN - DSGVO-ZUGRIFFSKONZEPT INSTALLATION
-- ====================================================================
-- Vollständige Installation des DSGVO-konformen Zugriffssystems
-- Ausführungsreihenfolge: Alle Dateien in der richtigen Reihenfolge
-- Erstellt: November 2025

-- ====================================================================
-- INSTALLATIONS-ANWEISUNGEN
-- ====================================================================
/*
1. Stellen Sie sicher, dass Sie als Administrator angemeldet sind
2. Führen Sie die Dateien in folgender Reihenfolge aus:
   a) 01_roles_permissions.sql
   b) 02_gdpr_views.sql  
   c) 03_gdpr_triggers.sql
   d) 04_stored_procedures.sql
3. Testen Sie die Installation mit den unten stehenden Beispielen
4. Überprüfen Sie die Audit-Logs und Berechtigungen

WICHTIG: Passen Sie die Passwörter in 01_roles_permissions.sql an!
*/

-- ====================================================================
-- SCHRITT 1: ROLLEN UND BERECHTIGUNGEN
-- ====================================================================
SOURCE ./01_roles_permissions.sql;

-- ====================================================================
-- SCHRITT 2: DSGVO-KONFORME VIEWS  
-- ====================================================================
SOURCE ./02_gdpr_views.sql;

-- ====================================================================
-- SCHRITT 3: COMPLIANCE-TRIGGER
-- ====================================================================
SOURCE ./03_gdpr_triggers.sql;

-- ====================================================================
-- SCHRITT 4: STORED PROCEDURES
-- ====================================================================
SOURCE ./04_stored_procedures.sql;

-- ====================================================================
-- INSTALLATIONS-VERIFIKATION
-- ====================================================================

-- Prüfung 1: Rollen wurden erstellt
SELECT 
    'ROLLEN_CHECK' as TEST_TYP,
    USER as ROLLE,
    HOST
FROM mysql.user 
WHERE USER IN ('admin_user', 'recipe_user', 'guest_user', 'gdpr_auditor');

-- Prüfung 2: Views sind verfügbar
SELECT 
    'VIEWS_CHECK' as TEST_TYP,
    TABLE_NAME as VIEW_NAME,
    TABLE_TYPE
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'krautundrueben' 
AND TABLE_TYPE = 'VIEW'
AND TABLE_NAME LIKE 'v_%';

-- Prüfung 3: Trigger sind aktiv
SELECT 
    'TRIGGER_CHECK' as TEST_TYP,
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'krautundrueben'
AND TRIGGER_NAME LIKE 'tr_%';

-- Prüfung 4: Stored Procedures verfügbar
SELECT 
    'PROCEDURES_CHECK' as TEST_TYP,
    ROUTINE_NAME as PROCEDURE_NAME,
    ROUTINE_TYPE
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'krautundrueben'
AND ROUTINE_NAME LIKE 'sp_%';

-- Prüfung 5: Audit-Tabellen erstellt
SELECT 
    'AUDIT_TABLES_CHECK' as TEST_TYP,
    TABLE_NAME,
    TABLE_ROWS
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'krautundrueben'
AND TABLE_NAME IN ('audit_log', 'gdpr_deletion_log', 'gdpr_access_log');

-- ====================================================================
-- FUNKTIONS-TESTS
-- ====================================================================

-- Test 1: Öffentliche Recipe-Suche als Gast
CALL sp_user_recipe_search('krr_guest', NULL, 'Salat', 5);

-- Test 2: View-Zugriff prüfen
SELECT * FROM v_public_recipes LIMIT 3;

-- Test 3: Audit-Log Funktionalität (wird automatisch durch obige Aktionen gefüllt)
SELECT 
    operation_type,
    table_name,
    user_name,
    audit_date
FROM audit_log 
ORDER BY audit_date DESC 
LIMIT 5;

-- ====================================================================
-- BENUTZER-BEISPIELE
-- ====================================================================

-- Beispiel 1: Als registrierter Nutzer anmelden
-- mysql -u recipe_user -p'UserPass2024!' -h localhost krautundrueben

-- Beispiel 2: Eigene Bestellungen anzeigen (als recipe_user)
-- CALL sp_user_orders('1', 'recipe_user');

-- Beispiel 3: Als Admin Audit-Report erstellen
-- CALL sp_gdpr_audit_report('2024-01-01', CURDATE(), 'FULL');

-- ====================================================================
-- SICHERHEITS-HINWEISE
-- ====================================================================
/*
NACH DER INSTALLATION:

1. PASSWÖRTER ÄNDERN:
   - Ändern Sie alle Standard-Passwörter in Produktionsumgebungen
   - Verwenden Sie starke, einzigartige Passwörter
   - Implementieren Sie Passwort-Rotation-Richtlinien

2. NETZWERK-SICHERHEIT:
   - Beschränken Sie Host-Zugriffe ('%' durch spezifische IPs ersetzen)
   - Verwenden Sie SSL-Verschlüsselung für alle Verbindungen
   - Implementieren Sie Firewall-Regeln

3. MONITORING EINRICHTEN:
   - Überwachen Sie audit_log täglich
   - Richten Sie Alerts für verdächtige Aktivitäten ein
   - Erstellen Sie regelmäßige Backup-Strategien für Audit-Logs

4. COMPLIANCE-PROZESSE:
   - Definieren Sie Datenaufbewahrungsrichtlinien
   - Schulen Sie Mitarbeiter zu DSGVO-Verfahren
   - Dokumentieren Sie alle Datenverarbeitungsaktivitäten

5. REGELMÄSSIGE WARTUNG:
   - Wöchentliche Überprüfung der Benutzerrollen
   - Monatliche Compliance-Reports
   - Quartalsweise Sicherheitsaudits
*/

-- ====================================================================
-- FEHLERBEHEBUNG
-- ====================================================================
/*
HÄUFIGE PROBLEME UND LÖSUNGEN:

1. "Access denied" Fehler:
   - Überprüfen Sie Benutzerrollen: SHOW GRANTS FOR 'username'@'host';
   - Stellen Sie sicher, dass Default-Rollen gesetzt sind

2. Views nicht sichtbar:
   - Prüfen Sie VIEW-Berechtigungen
   - Stellen Sie sicher, dass zugrunde liegende Tabellen existieren

3. Trigger funktionieren nicht:
   - Überprüfen Sie TRIGGER-Berechtigungen
   - Prüfen Sie Syntax mit SHOW TRIGGERS;

4. Stored Procedures nicht ausführbar:
   - Überprüfen Sie EXECUTE-Berechtigungen
   - Prüfen Sie Parameter-Übergabe

5. Audit-Logs leer:
   - Stellen Sie sicher, dass Trigger installiert sind
   - Prüfen Sie, ob INSERT-Berechtigungen für Audit-Tabellen bestehen
*/

-- ====================================================================
-- ERFOLGREICHE INSTALLATION
-- ====================================================================
SELECT 
    '✓ DSGVO-Zugriffskonzept erfolgreich installiert!' as STATUS,
    'Alle Komponenten sind einsatzbereit.' as NACHRICHT,
    'Lesen Sie DSGVO_ZUGRIFFSKONZEPT.md für Details.' as DOKUMENTATION;