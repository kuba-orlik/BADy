-- phpMyAdmin SQL Dump
-- version 4.0.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jan 25, 2014 at 06:14 PM
-- Server version: 5.6.12-log
-- PHP Version: 5.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `spiewnik`
--
CREATE DATABASE IF NOT EXISTS `spiewnik` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `spiewnik`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `category_getPieces`(IN `param` INT)
    READS SQL DATA
SELECT * FROM pieces WHERE category_id=param OR category_hasParent(category_id, param)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `composer_getPieces`(IN `composer_idL` INT)
    MODIFIES SQL DATA
SELECT * FROM pieces WHERE composer_id=composer_idL$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `file_getPiece`(IN `param` INT)
    NO SQL
SELECT * FROM pieces WHERE id=(SELECT piece_id FROM files WHERE id=param)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `file_getVersions`(IN `param` INT)
    READS SQL DATA
SELECT * FROM fileversions WHERE file_id=param$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_getFolders`(IN `group_idL` INT)
    READS SQL DATA
SELECT folders.id AS id, folders.name AS name FROM foldergroup LEFT JOIN folders ON foldergroup.folder_id = folders.id WHERE foldergroup.group_id=group_idL$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_getUsers`(IN `group_idL` INT)
    READS SQL DATA
SELECT * FROM users WHERE id IN (
	SELECT user_id FROM usergroup WHERE group_id=group_idL
)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `piece_getFiles`(IN `param` INT)
    READS SQL DATA
SELECT * FROM files WHERE piece_id=param$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `category_hasParent`(`category_id` INT, `parent_idL` INT) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
DECLARE parent_idTEMP int;
DECLARE current_id int;
DECLARE ret boolean;
SET current_id=category_id;
label1: LOOP
	SELECT parent_id INTO parent_idTEMP FROM categories WHERE id=current_id;
	if (SELECT COALESCE(parent_idTEMP, 0))=0
		THEN 
		set ret=false;
		LEAVE label1;
	end if;
	if parent_idTEMP=parent_idL
		THEN 
		set ret=true;
		LEAVE label1;
	end if;
	SET current_id=parent_idTEMP;
END loop label1;
return ret;
END$$

DELIMITER ;

