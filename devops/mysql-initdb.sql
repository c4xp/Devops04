CREATE DATABASE IF NOT EXISTS `db1`;
USE `db1`;
DROP TABLE IF EXISTS `friends`;
CREATE TABLE IF NOT EXISTS `friends` (id INT(10) unsigned NOT NULL AUTO_INCREMENT, name VARCHAR(256), age INT, gender VARCHAR(3), PRIMARY KEY (`id`));
INSERT INTO `friends` VALUES (1, 'John Smith', 32, 'm');
INSERT INTO `friends` VALUES (2, 'Lilian Worksmith', 29, 'f');
INSERT INTO `friends` VALUES (3, 'Michael Rupert', 27, 'm');