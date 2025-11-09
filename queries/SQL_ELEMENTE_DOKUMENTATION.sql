-- SQL-ELEMENTE DOKUMENTATION für Kraut und Rüben System
-- Diese Datei demonstriert alle geforderten SQL-Elemente mit praktischen Beispielen

-- ============================================================================
-- 1. INNER JOIN - Verbindung von Tabellen mit gemeinsamen Werten
-- ============================================================================

-- 1a) Basis INNER JOIN: Rezepte mit ihren Zutaten
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME as rezept_name,
    z.BEZEICHNUNG as zutat_name,
    rz.MENGE,
    rz.EINHEIT
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
ORDER BY r.REZEPTNAME, z.BEZEICHNUNG;

-- 1b) INNER JOIN mit Ernährungskategorien
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME as rezept_name,
    e.ERNAEHRUNGSKATEGORIENAME as kategorie_name
FROM REZEPT r
INNER JOIN REZEPTERNAEHRUNGSKATEGORIE rek ON r.REZEPTNR = rek.REZEPTNR
INNER JOIN ERNAEHRUNGSKATEGORIE e ON rek.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
ORDER BY e.ERNAEHRUNGSKATEGORIENAME, r.REZEPTNAME;

-- ============================================================================
-- 2. LEFT JOIN - Zeigt alle Datensätze aus der linken Tabelle
-- ============================================================================

-- 2a) LEFT JOIN: Alle Zutaten, auch wenn sie keinem Rezept zugeordnet sind
SELECT 
    z.ZUTATENNR,
    z.BEZEICHNUNG as zutat_name,
    COALESCE(rz.REZEPTNR, 'UNGENUTZT') as rezept_status,
    r.REZEPTNAME
FROM ZUTAT z
LEFT JOIN REZEPTZUTAT rz ON z.ZUTATENNR = rz.ZUTATENNR
LEFT JOIN REZEPT r ON rz.REZEPTNR = r.REZEPTNR
ORDER BY z.BEZEICHNUNG, r.REZEPTNAME;

-- 2b) LEFT JOIN: Alle Rezepte mit optionalen Ernährungskategorien
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME as rezept_name,
    r.ZUBEREITUNGSZEIT,
    COALESCE(e.ERNAEHRUNGSKATEGORIENAME, 'KEINE KATEGORIE') as kategorie
FROM REZEPT r
LEFT JOIN REZEPTERNAEHRUNGSKATEGORIE rek ON r.REZEPTNR = rek.REZEPTNR
LEFT JOIN ERNAEHRUNGSKATEGORIE e ON rek.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
ORDER BY r.REZEPTNAME;

-- ============================================================================
-- 3. RIGHT JOIN - Zeigt alle Datensätze aus der rechten Tabelle
-- ============================================================================

-- 3a) RIGHT JOIN: Alle Ernährungskategorien, auch ohne zugeordnete Rezepte
SELECT 
    e.ERNAEHRUNGSKATEGORIENR,
    e.ERNAEHRUNGSKATEGORIENAME as kategorie_name,
    COALESCE(r.REZEPTNAME, 'KEIN REZEPT ZUGEORDNET') as rezept_name,
    r.ZUBEREITUNGSZEIT
FROM REZEPTERNAEHRUNGSKATEGORIE rek
RIGHT JOIN ERNAEHRUNGSKATEGORIE e ON rek.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
LEFT JOIN REZEPT r ON rek.REZEPTNR = r.REZEPTNR
ORDER BY e.ERNAEHRUNGSKATEGORIENAME, r.REZEPTNAME;

-- 3b) RIGHT JOIN: Alle Lieferanten, auch ohne zugeordnete Zutaten
SELECT 
    l.LIEFERANTENNR,
    l.NAME as lieferant_name,
    COALESCE(z.BEZEICHNUNG, 'KEINE ZUTATEN') as zutat_name,
    z.NETTOPREIS,
    z.BESTAND
FROM ZUTAT z
RIGHT JOIN LIEFERANT l ON z.LIEFERANTENNR = l.LIEFERANTENNR
ORDER BY l.NAME, z.BEZEICHNUNG;

-- ============================================================================
-- 4. SUBSELECTS (Subqueries) - Verschachtelte Abfragen
-- ============================================================================

-- 4a) Subselect mit IN: Rezepte die eine bestimmte Zutat enthalten
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME as rezept_name,
    r.ZUBEREITUNGSZEIT
FROM REZEPT r
WHERE r.REZEPTNR IN (
    SELECT rz.REZEPTNR
    FROM REZEPTZUTAT rz
    WHERE rz.ZUTATENNR = (
        SELECT z.ZUTATENNR 
        FROM ZUTAT z 
        WHERE z.BEZEICHNUNG = 'Tomate'
    )
)
ORDER BY r.REZEPTNAME;

-- 4b) Subselect mit EXISTS: Rezepte mit mehr als 3 Zutaten
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME as rezept_name,
    r.ZUBEREITUNGSZEIT
FROM REZEPT r
WHERE EXISTS (
    SELECT 1
    FROM REZEPTZUTAT rz
    WHERE rz.REZEPTNR = r.REZEPTNR
    GROUP BY rz.REZEPTNR
    HAVING COUNT(rz.ZUTATENNR) > 3
)
ORDER BY r.REZEPTNAME;

-- 4c) Korrelierter Subselect: Rezepte mit Zutatenzahl
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME as rezept_name,
    r.ZUBEREITUNGSZEIT,
    (SELECT COUNT(*) 
     FROM REZEPTZUTAT rz 
     WHERE rz.REZEPTNR = r.REZEPTNR) as anzahl_zutaten
FROM REZEPT r
ORDER BY anzahl_zutaten DESC, r.REZEPTNAME;

-- 4d) Subselect im FROM (Derived Table): Durchschnittswerte
SELECT 
    kategorien_stats.kategorie_name,
    kategorien_stats.anzahl_rezepte,
    kategorien_stats.avg_zubereitungszeit
FROM (
    SELECT 
        e.ERNAEHRUNGSKATEGORIENAME as kategorie_name,
        COUNT(DISTINCT r.REZEPTNR) as anzahl_rezepte,
        ROUND(AVG(r.ZUBEREITUNGSZEIT), 2) as avg_zubereitungszeit
    FROM ERNAEHRUNGSKATEGORIE e
    INNER JOIN REZEPTERNAEHRUNGSKATEGORIE rek ON e.ERNAEHRUNGSKATEGORIENR = rek.ERNAEHRUNGSKATEGORIENR
    INNER JOIN REZEPT r ON rek.REZEPTNR = r.REZEPTNR
    GROUP BY e.ERNAEHRUNGSKATEGORIENAME
) as kategorien_stats
WHERE kategorien_stats.anzahl_rezepte > 2
ORDER BY kategorien_stats.avg_zubereitungszeit;

-- ============================================================================
-- 5. AGGREGATFUNKTIONEN - COUNT, SUM, AVG, MAX, MIN
-- ============================================================================

-- 5a) Alle Aggregatfunktionen: Statistik pro Ernährungskategorie
SELECT 
    e.ERNAEHRUNGSKATEGORIENAME as kategorie_name,
    COUNT(DISTINCT r.REZEPTNR) as anzahl_rezepte,
    AVG(r.ZUBEREITUNGSZEIT) as durchschnitt_zubereitungszeit,
    MIN(r.ZUBEREITUNGSZEIT) as min_zubereitungszeit,
    MAX(r.ZUBEREITUNGSZEIT) as max_zubereitungszeit,
    SUM(CASE WHEN r.ZUBEREITUNGSZEIT <= 30 THEN 1 ELSE 0 END) as schnelle_rezepte
FROM ERNAEHRUNGSKATEGORIE e
LEFT JOIN REZEPTERNAEHRUNGSKATEGORIE rek ON e.ERNAEHRUNGSKATEGORIENR = rek.ERNAEHRUNGSKATEGORIENR
LEFT JOIN REZEPT r ON rek.REZEPTNR = r.REZEPTNR
GROUP BY e.ERNAEHRUNGSKATEGORIENAME
HAVING COUNT(DISTINCT r.REZEPTNR) > 0
ORDER BY anzahl_rezepte DESC;

-- 5b) Aggregation mit Kalorien-Berechnung
SELECT 
    r.REZEPTNAME as rezept_name,
    COUNT(DISTINCT rz.ZUTATENNR) as anzahl_zutaten,
    SUM(COALESCE(z.KALORIEN, 0)) as gesamt_kalorien,
    AVG(COALESCE(z.KALORIEN, 0)) as durchschnitt_kalorien_pro_zutat,
    MIN(COALESCE(z.KALORIEN, 0)) as niedrigste_kalorien,
    MAX(COALESCE(z.KALORIEN, 0)) as höchste_kalorien
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
GROUP BY r.REZEPTNR, r.REZEPTNAME
ORDER BY gesamt_kalorien;

-- ============================================================================
-- 6. KOMBINIERTE ABFRAGE - Alle Elemente in einer Query!
-- ============================================================================

-- Ultimative Query: Kategorien-Analyse mit allen SQL-Elementen
SELECT 
    e.ERNAEHRUNGSKATEGORIENAME as kategorie_name,
    COUNT(DISTINCT r.REZEPTNR) as anzahl_rezepte,
    AVG(r.ZUBEREITUNGSZEIT) as durchschnitt_zubereitungszeit,
    AVG(kalorien_pro_rezept.gesamt_kalorien) as durchschnitt_kalorien,
    MIN(r.ZUBEREITUNGSZEIT) as schnellstes_rezept_minuten,
    MAX(r.ZUBEREITUNGSZEIT) as langsamstes_rezept_minuten,
    (SELECT z.BEZEICHNUNG 
     FROM ZUTAT z 
     INNER JOIN REZEPTZUTAT rz ON z.ZUTATENNR = rz.ZUTATENNR
     INNER JOIN REZEPT r_sub ON rz.REZEPTNR = r_sub.REZEPTNR
     INNER JOIN REZEPTERNAEHRUNGSKATEGORIE rek_sub ON r_sub.REZEPTNR = rek_sub.REZEPTNR
     WHERE rek_sub.ERNAEHRUNGSKATEGORIENR = e.ERNAEHRUNGSKATEGORIENR
     GROUP BY z.ZUTATENNR, z.BEZEICHNUNG
     ORDER BY COUNT(*) DESC
     LIMIT 1) as häufigste_zutat,
    GROUP_CONCAT(DISTINCT r.REZEPTNAME ORDER BY r.REZEPTNAME SEPARATOR ', ') as alle_rezepte
FROM ERNAEHRUNGSKATEGORIE e
LEFT JOIN REZEPTERNAEHRUNGSKATEGORIE rek ON e.ERNAEHRUNGSKATEGORIENR = rek.ERNAEHRUNGSKATEGORIENR
LEFT JOIN REZEPT r ON rek.REZEPTNR = r.REZEPTNR
LEFT JOIN (
    -- Subselect: Kalorien pro Rezept berechnen
    SELECT 
        r_inner.REZEPTNR,
        SUM(COALESCE(z_inner.KALORIEN, 0)) as gesamt_kalorien
    FROM REZEPT r_inner
    INNER JOIN REZEPTZUTAT rz_inner ON r_inner.REZEPTNR = rz_inner.REZEPTNR
    INNER JOIN ZUTAT z_inner ON rz_inner.ZUTATENNR = z_inner.ZUTATENNR
    GROUP BY r_inner.REZEPTNR
) as kalorien_pro_rezept ON r.REZEPTNR = kalorien_pro_rezept.REZEPTNR
WHERE r.REZEPTNR IN (
    -- Subselect: Nur Rezepte mit bestimmten Eigenschaften
    SELECT rz_filter.REZEPTNR
    FROM REZEPTZUTAT rz_filter
    WHERE rz_filter.ZUTATENNR IN (
        SELECT z_filter.ZUTATENNR 
        FROM ZUTAT z_filter 
        WHERE z_filter.KALORIEN > 0
    )
    GROUP BY rz_filter.REZEPTNR
    HAVING COUNT(rz_filter.ZUTATENNR) >= 2
)
GROUP BY e.ERNAEHRUNGSKATEGORIENR, e.ERNAEHRUNGSKATEGORIENAME
HAVING anzahl_rezepte > 0
ORDER BY durchschnitt_zubereitungszeit, anzahl_rezepte DESC;

-- ============================================================================
-- 7. ERWEITERTE BEISPIELE - Spezielle Anwendungsfälle
-- ============================================================================

-- 7a) Window Functions mit Aggregaten (falls MySQL 8.0+)
SELECT 
    r.REZEPTNAME as rezept_name,
    r.ZUBEREITUNGSZEIT,
    COUNT(rz.ZUTATENNR) as anzahl_zutaten,
    AVG(COUNT(rz.ZUTATENNR)) OVER() as durchschnitt_zutaten_gesamt,
    RANK() OVER(ORDER BY COUNT(rz.ZUTATENNR)) as rang_nach_zutatenanzahl
FROM REZEPT r
LEFT JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT
ORDER BY anzahl_zutaten;

-- 7b) Rekursive Abfrage für Lieferanten-Hierarchien (konzeptionell)
-- WITH RECURSIVE lieferanten_hierarchie (lieferant_id, name, level) AS (
--     SELECT LIEFERANTENNR, NAME, 0
--     FROM LIEFERANT
--     WHERE LIEFERANTENNR = 1  -- Hauptlieferant
--     UNION ALL
--     SELECT l.LIEFERANTENNR, l.NAME, lh.level + 1
--     FROM LIEFERANT l
--     INNER JOIN lieferanten_hierarchie lh ON l.parent_id = lh.lieferant_id  -- Falls parent_id existiert
-- )
-- SELECT * FROM lieferanten_hierarchie;

-- 7c) CASE WHEN mit Aggregaten: Kategorisierung
SELECT 
    z.BEZEICHNUNG as zutat_name,
    z.KALORIEN,
    COUNT(DISTINCT rz.REZEPTNR) as verwendung_anzahl,
    CASE 
        WHEN z.KALORIEN <= 20 THEN 'SEHR KALORIENARM'
        WHEN z.KALORIEN <= 50 THEN 'KALORIENARM'
        WHEN z.KALORIEN <= 100 THEN 'MITTEL'
        ELSE 'KALORIENREICH'
    END as kalorien_kategorie,
    CASE 
        WHEN COUNT(DISTINCT rz.REZEPTNR) = 0 THEN 'UNGENUTZT'
        WHEN COUNT(DISTINCT rz.REZEPTNR) <= 2 THEN 'SELTEN GENUTZT'
        WHEN COUNT(DISTINCT rz.REZEPTNR) <= 5 THEN 'NORMAL GENUTZT'
        ELSE 'HÄUFIG GENUTZT'
    END as nutzungs_kategorie
FROM ZUTAT z
LEFT JOIN REZEPTZUTAT rz ON z.ZUTATENNR = rz.ZUTATENNR
GROUP BY z.ZUTATENNR, z.BEZEICHNUNG, z.KALORIEN
ORDER BY verwendung_anzahl DESC, z.KALORIEN;

-- ============================================================================
-- SQL-ELEMENTE CHECKLIST ✓
-- ============================================================================
-- [✓] INNER JOIN - Mehrfach verwendet
-- [✓] LEFT JOIN - Mehrfach verwendet  
-- [✓] RIGHT JOIN - Implementiert
-- [✓] Subselects - IN, EXISTS, Korreliert, Derived Tables
-- [✓] Aggregatfunktionen - COUNT, SUM, AVG, MIN, MAX
-- [✓] GROUP BY - Umfangreich verwendet
-- [✓] HAVING - Mit Aggregaten
-- [✓] CASE WHEN - Kategorisierung
-- [✓] Kombinierte Query - Alle Elemente zusammen
-- ============================================================================