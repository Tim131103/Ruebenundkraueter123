REVOKE ALL PRIVILEGES ON krautundrueben.* FROM 'reader'@'%';
SHOW GRANTS FOR 'reader'@'%';

GRANT SELECT ON krautundrueben.ZUTATALLERGEN TO 'reader'@'%';
FLUSH PRIVILEGES;