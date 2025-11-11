CREATE ROLE 'admin';
GRANT ALL PRIVILEGES ON *.* TO 'admin' WITH GRANT OPTION;
GRANT 'admin' TO 'admin'@'%';
SET DEFAULT ROLE 'admin' FOR 'admin'@'%';

CREATE ROLE 'editor';
GRANT SELECT, INSERT, UPDATE, DELETE ON krautundrueben.* TO 'editor';
GRANT 'editor' TO 'editor'@'%';
SET DEFAULT ROLE 'editor' FOR 'editor'@'%';

CREATE ROLE 'reader';

GRANT SELECT ON krautundrueben.ALLERGEN TO 'reader';
GRANT SELECT ON krautundrueben.BESTELLUNG TO 'reader';
GRANT SELECT ON krautundrueben.BESTELLUNGZUTAT TO 'reader';
GRANT SELECT ON krautundrueben.ERNAEHRUNGSKATEGORIE TO 'reader';
GRANT SELECT ON krautundrueben.LIEFERANT TO 'reader';
GRANT SELECT ON krautundrueben.REZEPT TO 'reader';
GRANT SELECT ON krautundrueben.REZEPTERNAEHRUNGSKATEGORIE TO 'reader';
GRANT SELECT ON krautundrueben.REZEPTZUTAT TO 'reader';
GRANT SELECT ON krautundrueben.ZUTAT TO 'reader';
GRANT SELECT ON krautundrueben.ZUTATALLERGEN TO 'reader';
GRANT SELECT ON krautundrueben.v_kunde_anonym TO 'reader';
GRANT 'reader' TO 'reader'@'%';
SET DEFAULT ROLE 'reader' FOR 'reader'@'%';

SELECT * FROM mysql.roles_mapping;
SHOW GRANTS FOR 'reader'@'%';
