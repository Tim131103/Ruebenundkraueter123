-- Erstellen Sie zuerst die Zieltabelle (passen Sie die Spaltennamen und Typen an!)
CREATE TABLE Data_dq (
   Spalte1 VARCHAR(100),
   Spalte2 VARCHAR(100),
   Spalte3 VARCHAR(100),
   Spalte4 VARCHAR(100),
   Spalte5 VARCHAR(100)
);

-- Jetzt die CSV-Datei importieren
LOAD DATA LOCAL INFILE '/home/timl/Downloads/Test.csv'  -- Beachten Sie die Schrägstriche (/)
INTO TABLE Data_dq
FIELDS TERMINATED BY ','  -- Oder ';' wenn Ihre CSV Semikolons verwendet
ENCLOSED BY '"'
LINES TERMINATED BY '\n'  -- Für Windows oft '\r\n'

SELECT * FROM Data_dq;
