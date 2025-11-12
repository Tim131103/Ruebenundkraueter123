-- ====================================================================
-- CSV IMPORT IN ZUTAT-TABELLE - KRAUT UND RÜBEN SYSTEM
-- ====================================================================
-- Import von Zutaten-Daten aus CSV in die bestehende ZUTAT-Tabelle
-- CSV Format: BEZEICHNUNG;EINHEIT;LIEFERANT;Anschrift;BESTAND;KALORIEN;KOHLENHYDRATE;PROTEIN;NETTOPREIS

-- ====================================================================
-- 1. TEMPORÄRE IMPORT-TABELLE ERSTELLEN
-- ====================================================================

-- Temporäre Tabelle für CSV-Import
DROP TABLE IF EXISTS temp_zutat_import;
CREATE TABLE temp_zutat_import (
   BEZEICHNUNG VARCHAR(100),
   EINHEIT VARCHAR(50),
   LIEFERANT_NAME VARCHAR(100),
   ANSCHRIFT VARCHAR(255),
   BESTAND INT,
   KALORIEN DECIMAL(10,2),
   KOHLENHYDRATE DECIMAL(10,2),
   PROTEIN DECIMAL(10,2),
   NETTOPREIS DECIMAL(10,2)
);

-- ====================================================================
-- 2. CSV-DATEN IMPORTIEREN
-- ====================================================================

-- CSV mit Semikolon-Trennung und Header-Zeile überspringen
LOAD DATA LOCAL INFILE '/home/timl/Desktop/Ruebenundkraueter123/Test.csv'
INTO TABLE temp_zutat_import
FIELDS TERMINATED BY ';'
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(BEZEICHNUNG, EINHEIT, LIEFERANT_NAME, ANSCHRIFT, BESTAND, KALORIEN, KOHLENHYDRATE, PROTEIN, NETTOPREIS);

-- Import-Ergebnis prüfen
SELECT 'Temporärer Import erfolgreich:' as Status, COUNT(*) as Anzahl_Zeilen FROM temp_zutat_import;

-- ====================================================================
-- 3. LIEFERANTEN ZUORDNEN/ERSTELLEN
-- ====================================================================

-- Neue Lieferanten aus CSV in LIEFERANT-Tabelle einfügen (falls nicht vorhanden)
INSERT INTO LIEFERANT (LIEFERANTENNAME, LIEFERANTENORT, LIEFERANTENKONTAKT)
SELECT DISTINCT 
    ti.LIEFERANT_NAME,
    SUBSTRING_INDEX(ti.ANSCHRIFT, ',', 1) as ORT, -- Erster Teil der Anschrift als Ort
    ti.ANSCHRIFT as KONTAKT
FROM temp_zutat_import ti
WHERE NOT EXISTS (
    SELECT 1 FROM LIEFERANT l 
    WHERE l.LIEFERANTENNAME = ti.LIEFERANT_NAME
);

SELECT 'Neue Lieferanten hinzugefügt:' as Status, ROW_COUNT() as Anzahl;

-- ====================================================================
-- 4. ZUTATEN IN HAUPTTABELLE ÜBERTRAGEN
-- ====================================================================

-- Zutaten aus temporärer Tabelle in ZUTAT-Tabelle einfügen
INSERT INTO ZUTAT (
    BEZEICHNUNG, 
    EINHEIT, 
    LIEFERANTENNR, 
    BESTAND, 
    KALORIEN, 
    KOHLENHYDRATE, 
    PROTEIN, 
    NETTOPREIS
)
SELECT 
    ti.BEZEICHNUNG,
    ti.EINHEIT,
    l.LIEFERANTENNR, -- Lieferanten-ID aus Lookup
    ti.BESTAND,
    ti.KALORIEN,
    ti.KOHLENHYDRATE,
    ti.PROTEIN,
    ti.NETTOPREIS
FROM temp_zutat_import ti
INNER JOIN LIEFERANT l ON l.LIEFERANTENNAME = ti.LIEFERANT_NAME
WHERE NOT EXISTS (
    -- Verhindert Duplikate basierend auf Bezeichnung und Lieferant
    SELECT 1 FROM ZUTAT z 
    WHERE z.BEZEICHNUNG = ti.BEZEICHNUNG 
    AND z.LIEFERANTENNR = l.LIEFERANTENNR
);

SELECT 'Zutaten erfolgreich importiert:' as Status, ROW_COUNT() as Neue_Zutaten;

-- ====================================================================
-- 5. IMPORT-ERGEBNIS ÜBERPRÜFEN
-- ====================================================================

-- Übersicht der importierten Zutaten
SELECT 'Importierte Zutaten (Auswahl):' as Info;
SELECT 
    z.ZUTATENNR,
    z.BEZEICHNUNG,
    z.EINHEIT,
    l.LIEFERANTENNAME,
    z.BESTAND,
    z.KALORIEN,
    z.NETTOPREIS
FROM ZUTAT z
INNER JOIN LIEFERANT l ON z.LIEFERANTENNR = l.LIEFERANTENNR
WHERE l.LIEFERANTENNAME IN (
    SELECT DISTINCT LIEFERANT_NAME FROM temp_zutat_import
)
ORDER BY z.BEZEICHNUNG
LIMIT 10;

-- Statistiken
SELECT 'Import-Statistiken:' as Info;
SELECT 
    'Gesamtzahl Zutaten' as Kategorie,
    COUNT(*) as Anzahl
FROM ZUTAT
UNION ALL
SELECT 
    'Gesamtzahl Lieferanten' as Kategorie,
    COUNT(*) as Anzahl
FROM LIEFERANT
UNION ALL
SELECT 
    'Aus CSV importierte Zutaten (geschätzt)' as Kategorie,
    COUNT(*) as Anzahl
FROM temp_zutat_import;

-- ====================================================================
-- 6. CLEANUP - TEMPORÄRE TABELLE LÖSCHEN
-- ====================================================================

DROP TABLE IF EXISTS temp_zutat_import;

SELECT 'CSV-Import in ZUTAT-Tabelle abgeschlossen!' as Abschluss;



-- Löschen Sie die Tabelle, wenn sie bereits existiert
DROP TABLE IF EXISTS Data_dq;

-- Neue Zieltabelle mit passenden Spalten
CREATE TABLE Data_dq (
   BEZEICHNUNG VARCHAR(100),
   EINHEIT VARCHAR(50),
   LIEFERANT VARCHAR(100),
   ANSCHRIFT VARCHAR(255),
   BESTAND INT,
   KALORIEN DECIMAL(10,2),
   KOHLENHYDRATE DECIMAL(10,2),
   PROTEIN DECIMAL(10,2),
   NETTOPREIS DECIMAL(10,2)
);

-- Importieren Sie die CSV (mit Semikolon als Trennzeichen und Header überspringen)
LOAD DATA LOCAL INFILE '/home/timl/Downloads/Zutaten.CSV'
INTO TABLE Data_dq
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(BEZEICHNUNG, EINHEIT, LIEFERANT, ANSCHRIFT, BESTAND, KALORIEN, KOHLENHYDRATE, PROTEIN, NETTOPREIS);

SELECT * FROM Data_dq;

