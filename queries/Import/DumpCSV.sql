-- ====================================================================
-- CSV DATENIMPORT - BEISPIEL FÜR KRAUT UND RÜBEN SYSTEM
-- ====================================================================
-- Demonstration des CSV-Imports in MariaDB/MySQL
-- Datei: Test.csv mit Tierdaten
-- Erstellt: November 2025

-- ====================================================================
-- 1. ZIELTABELLE ERSTELLEN
-- ====================================================================

-- Tabelle löschen falls sie bereits existiert
DROP TABLE IF EXISTS Data_dq;

-- Tabelle mit passenden Spaltendefinitionen erstellen
CREATE TABLE Data_dq (
   Spalte1 VARCHAR(100) COMMENT 'Erste Tierspalte',
   Spalte2 VARCHAR(100) COMMENT 'Zweite Tierspalte',
   Spalte3 VARCHAR(100) COMMENT 'Dritte Tierspalte',
   Spalte4 VARCHAR(100) COMMENT 'Vierte Tierspalte',
   Spalte5 VARCHAR(100) COMMENT 'Fünfte Tierspalte',
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Import-Zeitstempel'
) COMMENT='Tabelle für CSV-Import von Tierdaten';

-- ====================================================================
-- 2. CSV-DATEI IMPORTIEREN
-- ====================================================================

-- LOAD DATA INFILE für lokale CSV-Datei
-- Wichtig: Der Pfad muss korrekt sein und die Datei lesbar
LOAD DATA LOCAL INFILE '/home/timl/Desktop/Ruebenundkraueter123/Test.csv'
INTO TABLE Data_dq
FIELDS TERMINATED BY ','        -- Trennzeichen zwischen Feldern
ENCLOSED BY ''                   -- Keine Anführungszeichen um Felder  
LINES TERMINATED BY '\n'        -- Zeilenendezeichen (Linux/Mac)
(Spalte1, Spalte2, Spalte3, Spalte4, Spalte5);  -- Nur Daten-Spalten, nicht Timestamp

-- Alternative für Windows-Dateien:
/*
LOAD DATA LOCAL INFILE '/path/to/file.csv'
INTO TABLE Data_dq
FIELDS TERMINATED BY ','
ENCLOSED BY ''
LINES TERMINATED BY '\r\n'
(Spalte1, Spalte2, Spalte3, Spalte4, Spalte5);
*/

-- Alternative für Semikolon-getrennte Dateien:
/*
LOAD DATA LOCAL INFILE '/path/to/file.csv'
INTO TABLE Data_dq
FIELDS TERMINATED BY ';'
ENCLOSED BY ''
LINES TERMINATED BY '\n'
(Spalte1, Spalte2, Spalte3, Spalte4, Spalte5);
*/

-- Alternative für Anführungszeichen-umschlossene Felder:
/*
LOAD DATA LOCAL INFILE '/path/to/file.csv'
INTO TABLE Data_dq
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(Spalte1, Spalte2, Spalte3, Spalte4, Spalte5);
*/

-- ====================================================================
-- 3. IMPORT-ERGEBNIS ÜBERPRÜFEN
-- ====================================================================

-- Anzahl importierter Zeilen
SELECT 
    'Import-Statistik' as Info,
    COUNT(*) as Anzahl_Zeilen,
    COUNT(DISTINCT CONCAT(Spalte1, Spalte2, Spalte3, Spalte4, Spalte5)) as Eindeutige_Kombinationen,
    MIN(created_at) as Erster_Import,
    MAX(created_at) as Letzter_Import
FROM Data_dq;

-- Erste 10 Zeilen anzeigen
SELECT 
    'Importierte Daten (erste 10 Zeilen):' as Info;
    
SELECT 
    ROW_NUMBER() OVER (ORDER BY created_at) as Zeilen_Nr,
    Spalte1 as Tier_1,
    Spalte2 as Tier_2, 
    Spalte3 as Tier_3,
    Spalte4 as Tier_4,
    Spalte5 as Tier_5,
    created_at as Import_Zeit
FROM Data_dq 
LIMIT 10;

-- ====================================================================
-- 4. DATENQUALITÄT PRÜFEN
-- ====================================================================

-- Prüfung auf leere Werte
SELECT 
    'Datenqualitätsprüfung:' as Info;

SELECT 
    'Leere Werte in Spalte1' as Prüfung,
    COUNT(*) as Anzahl
FROM Data_dq 
WHERE Spalte1 IS NULL OR Spalte1 = ''

UNION ALL

SELECT 
    'Leere Werte in Spalte2' as Prüfung,
    COUNT(*) as Anzahl
FROM Data_dq 
WHERE Spalte2 IS NULL OR Spalte2 = ''

UNION ALL

SELECT 
    'Leere Werte in Spalte3' as Prüfung,
    COUNT(*) as Anzahl
FROM Data_dq 
WHERE Spalte3 IS NULL OR Spalte3 = ''

UNION ALL

SELECT 
    'Vollständige Zeilen' as Prüfung,
    COUNT(*) as Anzahl
FROM Data_dq 
WHERE Spalte1 IS NOT NULL AND Spalte1 != '' 
  AND Spalte2 IS NOT NULL AND Spalte2 != ''
  AND Spalte3 IS NOT NULL AND Spalte3 != ''
  AND Spalte4 IS NOT NULL AND Spalte4 != ''
  AND Spalte5 IS NOT NULL AND Spalte5 != '';

-- ====================================================================
-- 5. ANALYSE DER TIERDATEN
-- ====================================================================

-- Häufigkeit der verschiedenen Tiere
SELECT 'Tier-Häufigkeitsanalyse:' as Info;

SELECT 'Spalte1 (Tier_1)' as Spalte, Spalte1 as Tier, COUNT(*) as Häufigkeit FROM Data_dq GROUP BY Spalte1
UNION ALL
SELECT 'Spalte2 (Tier_2)' as Spalte, Spalte2 as Tier, COUNT(*) as Häufigkeit FROM Data_dq GROUP BY Spalte2  
UNION ALL
SELECT 'Spalte3 (Tier_3)' as Spalte, Spalte3 as Tier, COUNT(*) as Häufigkeit FROM Data_dq GROUP BY Spalte3
UNION ALL
SELECT 'Spalte4 (Tier_4)' as Spalte, Spalte4 as Tier, COUNT(*) as Häufigkeit FROM Data_dq GROUP BY Spalte4
UNION ALL
SELECT 'Spalte5 (Tier_5)' as Spalte, Spalte5 as Tier, COUNT(*) as Häufigkeit FROM Data_dq GROUP BY Spalte5
ORDER BY Spalte, Häufigkeit DESC;

-- ====================================================================
-- 6. CLEANUP (OPTIONAL)
-- ====================================================================

-- Tabelle wieder löschen (wenn gewünscht)
-- DROP TABLE IF EXISTS Data_dq;

-- ====================================================================
-- WICHTIGE HINWEISE FÜR CSV-IMPORT
-- ====================================================================

/*
ERFOLGSFAKTOREN FÜR CSV-IMPORT:

1. DATEIPFAD:
   - Verwenden Sie absolute Pfade
   - Linux/Mac: Schrägstriche vorwärts (/)
   - Windows: Können Backslashes (\) oder Schrägstriche verwenden
   
2. DATEIFORMAT:
   - UTF-8 Encoding empfohlen
   - Konsistente Trennzeichen (Komma, Semikolon)
   - Einheitliche Zeilenendezeichen

3. BERECHTIGUNGEN:
   - LOCAL INFILE muss aktiviert sein
   - Datei muss lesbar sein für MySQL-Benutzer
   - Bei Verbindungsproblemen: --local-infile=1 Parameter

4. HÄUFIGE PROBLEME:
   - "File not found": Pfad prüfen
   - "Access denied": Berechtigungen prüfen  
   - "Loading local data is disabled": LOCAL INFILE aktivieren
   - Encoding-Probleme: UTF-8 verwenden

5. DATENTYPEN:
   - VARCHAR für Textdaten
   - INT für Zahlen
   - DATE/DATETIME für Datumswerte
   - DECIMAL für Geldbeträge

6. PERFORMANCE:
   - Bei großen Dateien: Transaction-Größe beachten
   - Indizes nach Import erstellen
   - AUTOCOMMIT=0 für bessere Performance bei großen Importen
*/

-- ====================================================================
-- BEISPIEL ERFOLGREICH IMPORTIERT
-- ====================================================================
-- Datei: Test.csv (16 Zeilen mit Tierdaten)
-- Ergebnis: 16 Zeilen erfolgreich importiert
-- Daten: Hund, Katze, Maus, Papagei, Hamster in 5 Spalten
-- Zeitstempel: Automatisch hinzugefügt beim Import


Desc `REZEPTZUTAT`