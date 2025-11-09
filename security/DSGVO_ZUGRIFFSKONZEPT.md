# DSGVO-Zugriffskonzept für Kraut und Rüben System

## Übersicht

Dieses Dokument beschreibt das umfassende Zugriffskonzept für das Kraut und Rüben Rezept-System, welches alle Anforderungen der Datenschutz-Grundverordnung (DSGVO) erfüllt. Das System implementiert ein mehrstufiges Sicherheitsmodell mit rollenbasierter Zugriffskontrolle, datenschutzkonformen Views, automatisierten Compliance-Triggern und auditierbaren Stored Procedures.

## Architektur-Komponenten

### 1. Rollen-basierte Zugriffskontrolle (RBAC)
- **Admin-Rolle (krr_admin)**: Vollzugriff auf alle Daten und Funktionen
- **Nutzer-Rolle (krr_user)**: Zugriff auf eigene Daten und öffentliche Rezepte  
- **Gast-Rolle (krr_guest)**: Lesezugriff auf öffentliche Rezeptdaten
- **Auditor-Rolle (krr_auditor)**: Spezielle Rolle für DSGVO-Compliance und Audit-Logs

### 2. DSGVO-konforme Views
- Datenschutzgerechte Aggregation und Anonymisierung
- Rollenbasierte Datensichtbarkeit
- Minimierung der Datenpreisgabe

### 3. Automatisierte Compliance-Trigger
- Löschprotokolle und Audit-Trails
- Automatische Anonymisierung
- Überwachung verdächtiger Aktivitäten

### 4. Auditierbare Stored Procedures
- Strukturierte Datenverarbeitung
- DSGVO-konforme Funktionen
- Vollständige Nachverfolgbarkeit

## Rollen und Berechtigungen

### Administrator (krr_admin)
**Berechtigungen:**
- Vollzugriff auf alle Tabellen und Views
- Benutzerverwaltung und Rollenzuweisung
- Ausführung aller Stored Procedures
- Zugriff auf alle Audit-Logs und Compliance-Berichte

**Verantwortlichkeiten:**
- Datenschutz-Compliance sicherstellen
- Benutzerverwaltung und Rollenzuweisungen
- Überwachung von Audit-Logs und Sicherheitsvorfällen
- Durchführung von Datenbereinigung und Anonymisierung

**Beispiel-SQL:**
```sql
-- Admin kann alle Kundendaten einsehen und verwalten
SELECT * FROM KUNDE WHERE KUNDENORT = 'Hamburg';

-- Admin kann DSGVO-Audit-Berichte erstellen
CALL sp_gdpr_audit_report('2024-01-01', '2024-12-31', 'FULL');
```

### Registrierter Nutzer (krr_user)
**Berechtigungen:**
- Lesezugriff auf öffentliche Rezeptdaten
- Vollzugriff auf eigene Bestellungen
- Ausführung nutzer-spezifischer Procedures
- Anfrage der eigenen Daten (DSGVO Art. 15)

**Beschränkungen:**
- Kein Zugriff auf andere Nutzerdaten
- Keine Admin-Funktionen
- Eingeschränkte Stored Procedure Ausführung

**Beispiel-SQL:**
```sql
-- Nutzer kann eigene Bestellungen einsehen
CALL sp_user_orders('12345', 'recipe_user');

-- Nutzer kann Rezepte suchen
CALL sp_user_recipe_search('krr_user', '12345', 'Pasta', 20);
```

### Gast (krr_guest)
**Berechtigungen:**
- Nur Lesezugriff auf öffentliche Rezepte
- Zugriff auf anonymisierte Views
- Minimale Stored Procedure Ausführung

**Beschränkungen:**
- Keine Personendaten-Zugriffe
- Begrenzte Suchergebnisse (max 10)
- Keine Preis- oder Detailinformationen

**Beispiel-SQL:**
```sql
-- Gast kann öffentliche Rezepte suchen (eingeschränkt)
CALL sp_user_recipe_search('krr_guest', NULL, 'Salat', 10);

-- Gast kann öffentliche Recipe-Übersicht einsehen
SELECT * FROM v_public_recipes WHERE PREISKATEGORIE = 'Günstig';
```

### Auditor (krr_auditor)
**Berechtigungen:**
- Zugriff auf alle Audit-Logs
- DSGVO-Compliance Überwachung
- Generierung von Datenschutz-Reports
- Lesezugriff auf DSGVO-relevante Tabellen

**Beschränkungen:**
- Keine Änderungsberechtigung an Produktivdaten
- Kein Zugriff auf sensible Kundendaten
- Nur Audit- und Compliance-Funktionen

## DSGVO-konforme Views

### v_public_recipes
Öffentliche Rezeptansicht ohne Personenbezug für Gäste und Nutzer.

**Funktionen:**
- Anonymisierte Bewertungen ohne Nutzerbezug
- Preiskategorien statt exakte Preise
- Ernährungskategorien und Zutatenlisten
- Keine sensiblen Daten

**Beispiel:**
```sql
SELECT REZEPTNAME, ZUBEREITUNGSZEIT, PREISKATEGORIE, ERNAEHRUNGSKATEGORIEN 
FROM v_public_recipes 
WHERE ANZAHL_ZUTATEN <= 5;
```

### v_customer_analytics
Anonymisierte Kundenstatistik für Business Intelligence.

**DSGVO-Compliance:**
- Keine individuellen Kundendaten
- Mindestens 3 Kunden pro Gruppe für Anonymität
- Altersgruppen statt exakte Geburtsdaten
- Regionale Aggregation ohne Adressen

### v_user_orders
Benutzer-spezifische Bestellansicht mit Zugriffskontrolle.

**Sicherheit:**
- Zugriff nur auf eigene Daten über Stored Procedures
- Keine sensiblen Lieferantendaten
- Auditierte Datenzugriffe

## Automatisierte DSGVO-Compliance

### Audit-Trigger
Automatische Protokollierung aller Datenbankoperationen:

```sql
-- Beispiel: Kunde wird aktualisiert
UPDATE KUNDE SET KUNDENORT = 'Berlin' WHERE KUNDENNR = '12345';
-- Trigger tr_kunde_update_audit protokolliert automatisch:
-- - Wer hat geändert
-- - Was wurde geändert  
-- - Wann wurde geändert
-- - Rechtliche Grundlage
```

### Löschprotokolle
Vollständige Dokumentation aller Löschvorgänge:

```sql
-- Bei Kundenlöschung wird automatisch protokolliert:
-- - Welche Daten gelöscht wurden
-- - Grund der Löschung (User Request, Retention Policy, etc.)
-- - Durchführende Person
-- - Zeitstempel und Verification Hash
```

### Anonymisierungstrigger
Proaktive Erkennung von Anonymisierungsbedarf:

```sql
-- Automatische Prüfung bei Kundenaktualisierung:
-- - Ist Kunde seit > 3 Jahren inaktiv?
-- - Anonymisierungsprozess einleiten
-- - DSGVO-konforme Protokollierung
```

## Stored Procedures für DSGVO-Compliance

### sp_user_data_export (Art. 15 DSGVO - Auskunftsrecht)
Vollständiger Export aller Nutzerdaten in strukturierter Form.

**Parameter:**
- `p_customer_id`: Kunden-ID für Datenexport
- `p_requesting_user`: Anfragender Benutzer
- `p_purpose`: Zweck des Datenexports

**Funktionalität:**
- Export aller persönlichen Daten
- Bestellhistorie und Transaktionsdaten
- DSGVO-konforme Protokollierung
- Strukturierte JSON/CSV Ausgabe

**Verwendung:**
```sql
CALL sp_user_data_export('12345', 'recipe_user', 'GDPR Article 15 Request');
```

### sp_anonymize_customer_data (Art. 17 DSGVO - Recht auf Vergessenwerden)
Sichere Anonymisierung von Kundendaten unter Erhalt der Datenintegrität.

**Parameter:**
- `p_customer_id`: Zu anonymisierende Kunden-ID
- `p_reason`: Grund der Anonymisierung
- `p_requesting_user`: Durchführende Person

**Funktionalität:**
- Ersetzung persönlicher Daten durch anonyme Werte
- Erhalt der Referential Integrity
- Generierung eindeutiger Anonymisierungs-IDs
- Vollständige Audit-Protokollierung

**Verwendung:**
```sql
CALL sp_anonymize_customer_data('12345', 'USER_REQUEST', 'admin_user');
```

### sp_gdpr_audit_report
Umfassende DSGVO-Audit-Berichte für Compliance-Überwachung.

**Report-Typen:**
- **FULL**: Vollständiger Compliance-Bericht
- **DELETIONS**: Löschungsprotokoll
- **EXPORTS**: Datenexport-Historie
- **VIOLATIONS**: Verdächtige Aktivitäten

**Verwendung:**
```sql
CALL sp_gdpr_audit_report('2024-01-01', '2024-12-31', 'FULL');
```

### sp_data_retention_cleanup
Automatische Datenbereinigung basierend auf Aufbewahrungsfristen.

**Funktionen:**
- Dry-Run Modus für Simulation
- Anonymisierung statt Löschung
- Compliance mit Aufbewahrungsfristen
- Vollständige Protokollierung

## Sicherheitsmaßnahmen

### Principle of Least Privilege
Jede Rolle erhält nur die minimal erforderlichen Berechtigungen:
- Gäste: Nur öffentliche Daten
- Nutzer: Eigene Daten + öffentliche Inhalte
- Admins: Vollzugriff mit Verantwortung
- Auditoren: Nur Compliance-relevante Daten

### Automatische Überwachung
Trigger überwachen verdächtige Aktivitäten:
- Mehr als 50 Operationen in 5 Minuten
- Ungewöhnliche Löschaktivitäten
- Massenexporte von Daten
- Automatische Alerts an Administratoren

### Datenintegrität
Referentielle Integrität bei Anonymisierung:
- Foreign Key Constraints bleiben erhalten
- Anonyme IDs für Referenzen
- Keine Datenverluste in abhängigen Tabellen

## Implementierung und Deployment

### Schritt 1: Rollen erstellen
```sql
-- Ausführung der Datei: 01_roles_permissions.sql
source /path/to/security/01_roles_permissions.sql;
```

### Schritt 2: Views implementieren  
```sql
-- Ausführung der Datei: 02_gdpr_views.sql
source /path/to/security/02_gdpr_views.sql;
```

### Schritt 3: Trigger installieren
```sql
-- Ausführung der Datei: 03_gdpr_triggers.sql
source /path/to/security/03_gdpr_triggers.sql;
```

### Schritt 4: Stored Procedures deployen
```sql
-- Ausführung der Datei: 04_stored_procedures.sql  
source /path/to/security/04_stored_procedures.sql;
```

### Schritt 5: Benutzer zuweisen
```sql
-- Beispiel: Neuen Nutzer erstellen und Rolle zuweisen
CREATE USER 'new_user'@'%' IDENTIFIED BY 'SecurePassword2024!';
GRANT 'krr_user'@'%' TO 'new_user'@'%';
SET DEFAULT ROLE 'krr_user'@'%' TO 'new_user'@'%';
```

## Monitoring und Compliance

### Kontinuierliche Überwachung
- Tägliche Audit-Log Überprüfung
- Wöchentliche Compliance-Berichte
- Monatliche Zugriffsmuster-Analyse
- Quartalsweise Rollenberechtigung-Reviews

### Compliance-Checkliste
- [ ] Alle Datenzugriffe werden protokolliert
- [ ] Löschungen sind vollständig dokumentiert  
- [ ] Anonymisierungen erfolgen DSGVO-konform
- [ ] Aufbewahrungsfristen werden eingehalten
- [ ] Nutzer können eigene Daten exportieren
- [ ] Verdächtige Aktivitäten werden erkannt
- [ ] Audit-Trails sind unveränderbar

### Regelmäßige Tasks
```sql
-- Wöchentlicher Compliance-Check
CALL sp_gdpr_audit_report(DATE_SUB(CURDATE(), INTERVAL 7 DAY), CURDATE(), 'VIOLATIONS');

-- Monatliche Datenbereinigung (Simulation)
CALL sp_data_retention_cleanup(1095, TRUE); -- 3 Jahre Aufbewahrung, Dry-Run

-- Quartalsweise vollständiger Audit
CALL sp_gdpr_audit_report(DATE_SUB(CURDATE(), INTERVAL 3 MONTH), CURDATE(), 'FULL');
```

## Rechtliche Grundlagen

### DSGVO-Artikel Abdeckung
- **Art. 5**: Grundsätze für Verarbeitung (Datenminimierung, Zweckbindung)
- **Art. 15**: Auskunftsrecht (sp_user_data_export)
- **Art. 17**: Recht auf Vergessenwerden (sp_anonymize_customer_data)
- **Art. 25**: Datenschutz durch Technikgestaltung (Privacy by Design)
- **Art. 30**: Verzeichnis von Verarbeitungstätigkeiten (Audit-Logs)
- **Art. 32**: Sicherheit der Verarbeitung (Verschlüsselung, Zugriffskontrolle)

### Rechtmäßige Verarbeitungsgrundlagen
- **Vertragserfüllung**: Kundendaten für Bestellabwicklung
- **Berechtigte Interessen**: Anonyme Statistiken für Geschäftsoptimierung  
- **Rechtliche Verpflichtung**: Aufbewahrung für Steuerzwecke
- **Einwilligung**: Marketing und erweiterte Funktionen

## Wartung und Updates

### Regelmäßige Überprüfungen
1. **Monatlich**: Rollenberechtigung-Review
2. **Quartalsweise**: Compliance-Assessment  
3. **Halbjährlich**: Penetration Testing
4. **Jährlich**: Vollständige DSGVO-Auditierung

### Update-Prozess
1. Entwicklung in separater Test-Umgebung
2. DSGVO-Impact-Assessment für alle Änderungen
3. Staging-Tests mit Anonymisierten Daten  
4. Dokumentierte Deployment-Checkliste
5. Post-Deployment Compliance-Verifikation

Dieses Zugriffskonzept gewährleistet vollständige DSGVO-Compliance bei maximaler Funktionalität und Sicherheit für das Kraut und Rüben System.