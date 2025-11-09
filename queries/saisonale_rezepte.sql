-- SQL Queries für Rezepte mit saisonalen Zutaten
-- Diese Queries helfen beim nachhaltigen Kochen mit saisonalen Produkten

-- 1. Grundquery: Rezepte mit bestimmten saisonalen Zutaten
-- Beispiel für Herbst/Winter-Saison
SELECT DISTINCT
    r.REZEPTNR,
    r.REZEPTNAME,
    r.BESCHREIBUNG,
    r.ZUBEREITUNGSZEIT,
    COUNT(DISTINCT rz.ZUTATENNR) as ANZAHL_ZUTATEN,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as ALLE_ZUTATEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE z.BEZEICHNUNG IN (
    -- Herbst/Winter saisonale Zutaten
    'Kürbis', 'Rote Beete', 'Sellerie', 'Lauch', 'Porree', 
    'Karotte', 'Blumenkohl', 'Brokkoli', 'Spinat', 'Kohl',
    'Süßkartoffel', 'Rotkohl', 'Wirsing', 'Pastinake'
)
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.BESCHREIBUNG, r.ZUBEREITUNGSZEIT
ORDER BY r.REZEPTNAME;

-- 2. Flexible saisonale Query mit Parameter-Platzhaltern
-- Ersetze die Zutatenliste je nach gewünschter Saison
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    COUNT(DISTINCT rz.ZUTATENNR) as GESAMT_ZUTATEN,
    COUNT(DISTINCT CASE WHEN z.BEZEICHNUNG IN (
        -- SAISON_PARAMETER: Hier saisonale Zutaten einfügen
        'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
        'Brokkoli', 'Spinat', 'Süßkartoffel'
    ) THEN z.ZUTATENNR END) as SAISONALE_ZUTATEN,
    ROUND(
        COUNT(DISTINCT CASE WHEN z.BEZEICHNUNG IN (
            'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
            'Brokkoli', 'Spinat', 'Süßkartoffel'
        ) THEN z.ZUTATENNR END) * 100.0 / COUNT(DISTINCT rz.ZUTATENNR), 
        2
    ) as SAISONALER_ANTEIL_PROZENT,
    GROUP_CONCAT(DISTINCT 
        CASE WHEN z.BEZEICHNUNG IN (
            'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
            'Brokkoli', 'Spinat', 'Süßkartoffel'
        ) THEN z.BEZEICHNUNG END 
        ORDER BY z.BEZEICHNUNG SEPARATOR ', '
    ) as SAISONALE_ZUTATEN_LISTE
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT
HAVING SAISONALE_ZUTATEN > 0
ORDER BY SAISONALER_ANTEIL_PROZENT DESC, SAISONALE_ZUTATEN DESC;

-- 3. Herbst-Rezepte (November spezifisch)
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    COUNT(DISTINCT rz.ZUTATENNR) as ANZAHL_ZUTATEN,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as ZUTATEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE z.BEZEICHNUNG IN (
    -- November-Saison (Herbst/Übergang Winter)
    'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
    'Brokkoli', 'Spinat', 'Lauch', 'Porree', 'Süßkartoffel'
)
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT
ORDER BY COUNT(DISTINCT rz.ZUTATENNR), r.REZEPTNAME;

-- 4. Frühling-Rezepte (Beispiel für andere Saison)
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    COUNT(DISTINCT rz.ZUTATENNR) as ANZAHL_ZUTATEN,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as ZUTATEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE z.BEZEICHNUNG IN (
    -- Frühling-Saison
    'Spargel', 'Radieschen', 'Rucola', 'Spinat', 'Kresse',
    'Schnittlauch', 'Petersilie', 'Basilikum', 'Gurke'
)
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT
ORDER BY COUNT(DISTINCT rz.ZUTATENNR), r.REZEPTNAME;

-- 5. Sommer-Rezepte 
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    COUNT(DISTINCT rz.ZUTATENNR) as ANZAHL_ZUTATEN,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as ZUTATEN
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE z.BEZEICHNUNG IN (
    -- Sommer-Saison
    'Tomate', 'Paprika', 'Aubergine', 'Gurke', 'Salatkopf',
    'Basilikum', 'Rucola', 'Fenchel'
)
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT
ORDER BY COUNT(DISTINCT rz.ZUTATENNR), r.REZEPTNAME;

-- 6. Hochsaisonale Rezepte: Mindestens 50% saisonale Zutaten
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    COUNT(DISTINCT rz.ZUTATENNR) as GESAMT_ZUTATEN,
    COUNT(DISTINCT CASE WHEN z.BEZEICHNUNG IN (
        -- Aktuelle Saison (November): Herbst/Winter-Zutaten
        'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
        'Brokkoli', 'Spinat', 'Lauch', 'Porree', 'Süßkartoffel'
    ) THEN z.ZUTATENNR END) as SAISONALE_ZUTATEN,
    ROUND(
        COUNT(DISTINCT CASE WHEN z.BEZEICHNUNG IN (
            'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
            'Brokkoli', 'Spinat', 'Lauch', 'Porree', 'Süßkartoffel'
        ) THEN z.ZUTATENNR END) * 100.0 / COUNT(DISTINCT rz.ZUTATENNR), 
        2
    ) as SAISONALER_ANTEIL_PROZENT
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT
HAVING SAISONALER_ANTEIL_PROZENT >= 50
ORDER BY SAISONALER_ANTEIL_PROZENT DESC;

-- 7. Kombiniert: Einfache UND saisonale Rezepte (< 5 Zutaten + saisonal)
SELECT 
    r.REZEPTNR,
    r.REZEPTNAME,
    r.ZUBEREITUNGSZEIT,
    COUNT(DISTINCT rz.ZUTATENNR) as ANZAHL_ZUTATEN,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as ZUTATEN,
    'EINFACH + SAISONAL' as KATEGORIE
FROM REZEPT r
INNER JOIN REZEPTZUTAT rz ON r.REZEPTNR = rz.REZEPTNR
INNER JOIN ZUTAT z ON rz.ZUTATENNR = z.ZUTATENNR
WHERE z.BEZEICHNUNG IN (
    -- November-Saison
    'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
    'Brokkoli', 'Spinat', 'Lauch', 'Porree', 'Süßkartoffel'
)
GROUP BY r.REZEPTNR, r.REZEPTNAME, r.ZUBEREITUNGSZEIT
HAVING COUNT(DISTINCT rz.ZUTATENNR) < 5
ORDER BY COUNT(DISTINCT rz.ZUTATENNR), r.REZEPTNAME;

-- 8. Saison-Übersicht: Verfügbare Zutaten nach Kategorien
SELECT 
    'HERBST/WINTER (Nov-Feb)' as SAISON,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as VERFÜGBARE_ZUTATEN,
    COUNT(DISTINCT z.ZUTATENNR) as ANZAHL_ZUTATEN
FROM ZUTAT z
WHERE z.BEZEICHNUNG IN (
    'Rote Beete', 'Sellerie', 'Karotte', 'Blumenkohl', 
    'Brokkoli', 'Spinat', 'Lauch', 'Porree', 'Süßkartoffel'
)

UNION ALL

SELECT 
    'FRÜHLING (Mar-Mai)' as SAISON,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as VERFÜGBARE_ZUTATEN,
    COUNT(DISTINCT z.ZUTATENNR) as ANZAHL_ZUTATEN
FROM ZUTAT z
WHERE z.BEZEICHNUNG IN (
    'Spargel', 'Radieschen', 'Rucola', 'Spinat', 'Kresse',
    'Schnittlauch', 'Petersilie', 'Basilikum', 'Gurke'
)

UNION ALL

SELECT 
    'SOMMER (Jun-Aug)' as SAISON,
    GROUP_CONCAT(DISTINCT z.BEZEICHNUNG ORDER BY z.BEZEICHNUNG SEPARATOR ', ') as VERFÜGBARE_ZUTATEN,
    COUNT(DISTINCT z.ZUTATENNR) as ANZAHL_ZUTATEN
FROM ZUTAT z
WHERE z.BEZEICHNUNG IN (
    'Tomate', 'Paprika', 'Aubergine', 'Gurke', 'Salatkopf',
    'Basilikum', 'Rucola', 'Fenchel'
);