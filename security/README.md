# DSGVO-Zugriffskonzept - Quick Reference

## Übersicht der implementierten Dateien

| Datei | Zweck | Beschreibung |
|-------|-------|--------------|
| `00_INSTALL_COMPLETE.sql` | Installation | Vollständiges Setup-Skript für alle Komponenten |
| `01_roles_permissions.sql` | Rollen & Rechte | Benutzerrollen (Admin, User, Guest, Auditor) |  
| `02_gdpr_views.sql` | DSGVO-Views | Datenschutzkonforme Datenansichten |
| `03_gdpr_triggers.sql` | Compliance-Trigger | Automatische Audit-Logs und Überwachung |
| `04_stored_procedures.sql` | Stored Procedures | DSGVO-konforme Datenverarbeitungs-Funktionen |
| `DSGVO_ZUGRIFFSKONZEPT.md` | Dokumentation | Vollständige technische Dokumentation |

## Schnell-Installation

```bash
# Als MySQL Admin ausführen:
mysql -u root -p krautundrueben < security/00_INSTALL_COMPLETE.sql
```

## Benutzerrollen

### Admin (krr_admin)
- **Benutzer**: `admin_user` 
- **Passwort**: `AdminPass2024!`
- **Rechte**: Vollzugriff, DSGVO-Management, Audit-Reports

### User (krr_user)  
- **Benutzer**: `recipe_user`
- **Passwort**: `UserPass2024!`
- **Rechte**: Eigene Daten, öffentliche Rezepte, Bestellungen

### Gast (krr_guest)
- **Benutzer**: `guest_user`
- **Passwort**: `GuestPass2024!`
- **Rechte**: Nur öffentliche Rezeptdaten (eingeschränkt)

### Auditor (krr_auditor)
- **Benutzer**: `gdpr_auditor`
- **Passwort**: `AuditPass2024!`  
- **Rechte**: Audit-Logs, Compliance-Reports

## Wichtige DSGVO-Funktionen

### Datenexport (Art. 15 DSGVO)
```sql
CALL sp_user_data_export('kunde_id', 'requesting_user', 'GDPR Article 15 Request');
```

### Daten-Anonymisierung (Art. 17 DSGVO)
```sql
CALL sp_anonymize_customer_data('kunde_id', 'USER_REQUEST', 'admin_user');
```

### Compliance-Audit
```sql  
CALL sp_gdpr_audit_report('2024-01-01', CURDATE(), 'FULL');
```

### Benutzer-Bestellungen
```sql
CALL sp_user_orders('kunde_id', 'recipe_user');
```

## Views für Datenschutz

| View | Zweck | Zugriff |
|------|-------|---------|
| `v_public_recipes` | Öffentliche Rezepte ohne Personenbezug | Alle |
| `v_customer_analytics` | Anonymisierte Kundenstatistiken | Admin |
| `v_user_orders` | Eigene Bestellungen | User (eigene) |
| `v_supplier_overview` | Lieferanten ohne sensible Daten | User, Admin |
| `v_recipe_overview` | Detaillierte Rezeptinfos | Alle |
| `v_gdpr_audit_summary` | Audit-Zusammenfassung | Auditor |

## Automatische Überwachung

### Audit-Logs
- Alle Datenbankoperationen werden automatisch protokolliert
- Spezielle Behandlung von personenbezogenen Daten
- Verdächtige Aktivitäten werden erkannt (>50 Ops/5min)

### Löschprotokolle  
- Vollständige Dokumentation aller Löschvorgänge
- DSGVO-konforme Begründungen und Nachweise
- Automatische Anonymisierung nach Aufbewahrungsfristen

### Zugriffskontrolle
- Rollenbasierte Berechtigungen (Principle of Least Privilege)
- Automatische Protokollierung aller Datenzugriffe
- Transparenz für Betroffene (Art. 12 DSGVO)

## Sicherheits-Checkliste

- [ ] Alle Standard-Passwörter in Produktion geändert
- [ ] Host-Zugriffe auf spezifische IPs beschränkt  
- [ ] SSL-Verschlüsselung aktiviert
- [ ] Firewall-Regeln implementiert
- [ ] Audit-Log-Monitoring eingerichtet
- [ ] Backup-Strategie für Audit-Daten definiert
- [ ] Mitarbeiter-Schulungen zu DSGVO durchgeführt
- [ ] Datenverarbeitungs-Verzeichnis erstellt
- [ ] Incident-Response-Plan vorhanden

## Regelmäßige Wartung

### Täglich
- Überprüfung der Audit-Logs auf Anomalien
- Monitoring der Systemperformance

### Wöchentlich  
```sql
-- Compliance-Check
CALL sp_gdpr_audit_report(DATE_SUB(CURDATE(), INTERVAL 7 DAY), CURDATE(), 'VIOLATIONS');
```

### Monatlich
```sql  
-- Datenbereinigung (Simulation)
CALL sp_data_retention_cleanup(1095, TRUE);
```

### Quartalsweise
```sql
-- Vollständiger Audit
CALL sp_gdpr_audit_report(DATE_SUB(CURDATE(), INTERVAL 3 MONTH), CURDATE(), 'FULL');
```

## Kontakt und Support

- **Technische Dokumentation**: `DSGVO_ZUGRIFFSKONZEPT.md`
- **Installation**: `00_INSTALL_COMPLETE.sql`
- **Troubleshooting**: Siehe Kommentare in den SQL-Dateien

---
**Hinweis**: Dieses System erfüllt alle DSGVO-Anforderungen. Bei Fragen zur Implementierung oder Compliance konsultieren Sie die vollständige Dokumentation.