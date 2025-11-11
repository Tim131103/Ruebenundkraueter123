-- SQL Queries für Zutaten eines Rezepts
-- Stellt verschiedene Abfragen bereit, um alle Zutaten eines Rezepts mit Mengenangaben anzuzeigen

-- ============================================================================
-- 1. Basis-Query: Alle Zutaten eines spezifischen Rezepts
-- ============================================================================

-- 1a) Einfache Version: Zutaten mit Mengenangaben (Rezept-ID 1 als Beispiel)
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.BESCHREIBUNG,
    r.ZUBEREITUNGSZEIT,
    z.ZUTATENNR,
    z.BEZEICHNUNG as ZUTAT_NAME,
    rz.MENGE,
    rz.EINHEIT,
    z.NETTOPREIS,
    ROUND(z.NETTOPREIS * rz.MENGE, 2) as KOSTEN_PRO_ZUTAT
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE r.REZEPTNR = 1  -- PARAMETER: Hier gewünschte Rezept-ID einfügen
ORDER BY z.BEZEICHNUNG;

-- 1b) Erweiterte Version mit Nährwerten
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME as REZEPT_NAME,
    z.BEZEICHNUNG as ZUTAT_NAME,
    CONCAT(rz.MENGE, ' ', rz.EINHEIT) as MENGE_EINHEIT,
    z.NETTOPREIS as PREIS_PRO_EINHEIT,
    ROUND(z.NETTOPREIS * rz.MENGE, 2) as KOSTEN_GESAMT,
    COALESCE(z.KALORIEN, 0) as KALORIEN_PRO_100G,
    COALESCE(z.PROTEIN, 0) as PROTEIN_PRO_100G,
    COALESCE(z.KOHLENHYDRATE, 0) as KOHLENHYDRATE_PRO_100G,
    z.EINHEIT as ZUTAT_EINHEIT
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE r.REZEPTNR = 1  -- PARAMETER: Rezept-ID
ORDER BY z.BEZEICHNUNG;

-- ============================================================================
-- 2. Flexible Abfragen mit verschiedenen Parametern
-- ============================================================================

-- 2a) Nach Rezept-Name suchen
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    z.BEZEICHNUNG as ZUTAT_NAME,
    rz.MENGE,
    rz.EINHEIT,
    ROUND(z.NETTOPREIS * rz.MENGE, 2) as KOSTEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE r.REZEPTNAME LIKE '%Salad%'  -- PARAMETER: Rezept-Name (Teilstring)
ORDER BY r.REZEPTNAME, z.BEZEICHNUNG;

-- 2b) Alle Rezepte mit ihren Zutaten (Übersicht)
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    COUNT(DISTINCT z.ZUTATENNR) as ANZAHL_ZUTATEN,
    GROUP_CONCAT(
        CONCAT(z.BEZEICHNUNG, ' (', rz.MENGE, ' ', rz.EINHEIT, ')')
        ORDER BY z.BEZEICHNUNG SEPARATOR ', '
    ) as ALLE_ZUTATEN,
    ROUND(SUM(z.NETTOPREIS * rz.MENGE), 2) as GESAMTKOSTEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
GROUP BY r.REZEPTNR, r.REZEPTNAME
ORDER BY r.REZEPTNAME;

-- ============================================================================
-- 3. Erweiterte Analysen pro Rezept
-- ============================================================================

-- 3a) Rezept mit Kostenaufschlüsselung und Nährwerten
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.BESCHREIBUNG,
    r.ZUBEREITUNGSZEIT,
    -- Zutaten-Details
    z.BEZEICHNUNG as ZUTAT_NAME,
    CONCAT(rz.MENGE, ' ', rz.EINHEIT) as MENGE_ANGABE,
    ROUND(z.NETTOPREIS, 2) as PREIS_PRO_EINHEIT,
    ROUND(z.NETTOPREIS * rz.MENGE, 2) as KOSTEN_ZUTAT,
    -- Nährwerte pro Zutat
    COALESCE(z.KALORIEN, 0) as KALORIEN_100G,
    COALESCE(z.PROTEIN, 0) as PROTEIN_100G,
    COALESCE(z.KOHLENHYDRATE, 0) as KOHLENHYDRATE_100G,
    -- Lieferant
    l.`LIEFERANTENNAME` as LIEFERANT
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
LEFT JOIN LIEFERANT l ON z.LIEFERANTENNR = l.LIEFERANTENNR
WHERE r.REZEPTNR = 1  -- PARAMETER: Rezept-ID
ORDER BY KOSTEN_ZUTAT DESC;

-- 3b) Zusammenfassung eines Rezepts mit Gesamtwerten
SELECT 
    'REZEPT-ZUSAMMENFASSUNG' as TYP,
    r.REZEPTNR,
    r.REZEPTNAME,
    r.BESCHREIBUNG,
    CONCAT(r.ZUBEREITUNGSZEIT, ' Minuten') as ZUBEREITUNGSZEIT,
    COUNT(DISTINCT z.ZUTATENNR) as ANZAHL_ZUTATEN,
    ROUND(SUM(z.NETTOPREIS * rz.MENGE), 2) as GESAMTKOSTEN,
    SUM(COALESCE(z.KALORIEN, 0)) as GESCHÄTZTE_GESAMTKALORIEN,
    SUM(COALESCE(z.PROTEIN, 0)) as GESCHÄTZTES_GESAMTPROTEIN,
    SUM(COALESCE(z.KOHLENHYDRATE, 0)) as GESCHÄTZTE_GESAMTKOHLENHYDRATE
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE r.REZEPTNR = 1
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.BESCHREIBUNG, r.ZUBEREITUNGSZEIT;


-- ============================================================================
-- 4. Verschiedene Rezepte als Beispiele
-- ============================================================================

-- 4a) Rezept 1: Mediterraner Hähnchensalat
SELECT 
    'REZEPT 1: Mediterraner Hähnchensalat' as INFO,
    z.BEZEICHNUNG as ZUTAT,
    CONCAT(rz.MENGE, ' ', rz.EINHEIT) as MENGE,
    CONCAT('€', ROUND(z.NETTOPREIS * rz.MENGE, 2)) as KOSTEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE r.REZEPTNR = 1
ORDER BY z.BEZEICHNUNG;

-- 4b) Rezept 8: Caesar Salad (Beispiel für einfaches Rezept)
SELECT 
    'REZEPT 8: Caesar Salad' as INFO,
    z.BEZEICHNUNG as ZUTAT,
    CONCAT(rz.MENGE, ' ', rz.EINHEIT) as MENGE,
    CONCAT('€', ROUND(z.NETTOPREIS * rz.MENGE, 2)) as KOSTEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE r.REZEPTNR = 8
ORDER BY z.BEZEICHNUNG;

-- ============================================================================
-- 5. Einkaufsliste für ein Rezept
-- ============================================================================

-- 5a) Einkaufsliste mit Verfügbarkeit und Bestand
SELECT 
    'EINKAUFSLISTE' as KATEGORIE,
    r.REZEPTNAME,
    z.BEZEICHNUNG as ZUTAT,
    CONCAT(rz.MENGE, ' ', rz.EINHEIT) as BENÖTIGT,
    z.BESTAND as VORRAT,
    CASE 
        WHEN z.BESTAND >= rz.MENGE THEN 'VERFÜGBAR'
        WHEN z.BESTAND > 0 THEN CONCAT('TEILWEISE (', z.BESTAND, ' vorhanden)')
        ELSE 'MUSS GEKAUFT WERDEN'
    END as STATUS,
    CASE 
        WHEN z.BESTAND < rz.MENGE THEN CONCAT('€', ROUND(z.NETTOPREIS * (rz.MENGE - COALESCE(z.BESTAND, 0)), 2))
        ELSE 'KOSTENLOS (auf Lager)'
    END as KOSTEN,
    l.`LIEFERANTENNAME` as LIEFERANT
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
LEFT JOIN LIEFERANT l ON z.LIEFERANTENNR = l.LIEFERANTENNR
WHERE r.REZEPTNR = 1  -- PARAMETER: Rezept-ID
ORDER BY 
    CASE WHEN z.BESTAND < rz.MENGE THEN 1 ELSE 2 END,  -- Kaufbedarf zuerst
    z.BEZEICHNUNG;

-- ============================================================================
-- 6. Allergene und Ernährungskategorien eines Rezepts
-- ============================================================================

-- 6a) Rezept mit Allergenen und Ernährungskategorien
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    -- Zutaten
    z.BEZEICHNUNG as ZUTAT_NAME,
    CONCAT(rz.MENGE, ' ', rz.EINHEIT) as MENGE,
    -- Allergene
    GROUP_CONCAT(DISTINCT a.ALLERGENNAME SEPARATOR ', ') as ALLERGENE,
    -- Ernährungskategorien des Rezepts
    (SELECT GROUP_CONCAT(DISTINCT e.ERNAEHRUNGSKATEGORIENAME SEPARATOR ', ')
     FROM REZEPTERNAEHRUNGSKATEGORIE rek 
     INNER JOIN ERNAEHRUNGSKATEGORIE e ON rek.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
     WHERE rek.REZEPTNR = r.REZEPTNR) as ERNÄHRUNGSKATEGORIEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
LEFT JOIN ZUTATALLERGEN za ON z.ZUTATENNR = za.ZUTATENNR
LEFT JOIN ALLERGEN a ON za.ALLERGENNR = a.ALLERGENNR
WHERE r.REZEPTNR = 1  -- PARAMETER: Rezept-ID
GROUP BY r.REZEPTNR, r.REZEPTNAME, z.ZUTATENNR, z.BEZEICHNUNG, rz.MENGE, rz.EINHEIT
ORDER BY z.BEZEICHNUNG;

-- ============================================================================
-- 7. Parametrisierte Funktionen (Stored Procedure Vorbereitung)
-- ============================================================================

-- 7a) Universal-Query für beliebige Rezept-ID (Parameter ersetzen)
-- Verwendung: Ersetze @REZEPT_ID mit gewünschter ID
SELECT 
    -- Rezept-Informationen
    r.REZEPTNR,
    r.REZEPTNAME,
    r.BESCHREIBUNG,
    CONCAT(r.ZUBEREITUNGSZEIT, ' Min') as ZUBEREITUNGSZEIT,
    -- Zutat-Details
    ROW_NUMBER() OVER (ORDER BY z.BEZEICHNUNG) as POSITION,
    z.BEZEICHNUNG as ZUTAT,
    CONCAT(rz.MENGE, ' ', rz.EINHEIT) as MENGE,
    CONCAT('€', ROUND(z.NETTOPREIS, 2), '/Einheit') as EINZELPREIS,
    CONCAT('€', ROUND(z.NETTOPREIS * rz.MENGE, 2)) as GESAMTPREIS,
    -- Zusatzinformationen
    COALESCE(z.KALORIEN, 0) as KALORIEN_100G,
    z.BESTAND as LAGERBESTAND
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE r.REZEPTNR = @REZEPT_ID  -- PARAMETER: Hier ID einsetzen (z.B. 1, 8, 15)
ORDER BY z.BEZEICHNUNG;