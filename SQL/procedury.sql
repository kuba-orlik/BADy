-- phpMyAdmin SQL Dump
-- version 4.0.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jan 25, 2014 at 04:25 PM
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
DROP PROCEDURE IF EXISTS `category_getPieces`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `category_getPieces`(IN `param` INT)
    READS SQL DATA
SELECT * FROM pieces WHERE category_id = param$$

DROP PROCEDURE IF EXISTS `composer_getPieces`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `composer_getPieces`(IN `composer_idL` INT)
    MODIFIES SQL DATA
SELECT * FROM pieces WHERE composer_id=composer_idL$$

DROP PROCEDURE IF EXISTS `group_getFolders`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `group_getFolders`(IN `group_idL` INT)
    READS SQL DATA
SELECT folders.id AS id, folders.name AS name FROM foldergroup LEFT JOIN folders ON foldergroup.folder_id = folders.id WHERE foldergroup.group_id=group_idL$$

DROP PROCEDURE IF EXISTS `group_getUsers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `group_getUsers`(IN `group_idL` INT)
    READS SQL DATA
SELECT * FROM users WHERE id IN (
	SELECT user_id FROM usergroup WHERE group_id=group_idL
)$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `category_hasParent`$$
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

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `parent_id`) VALUES
(1, 'Wg Nastroju', NULL),
(2, 'Wesołe', 1),
(3, 'Smutne', 1);

-- --------------------------------------------------------

--
-- Table structure for table `composers`
--

DROP TABLE IF EXISTS `composers`;
CREATE TABLE `composers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `composers`
--

INSERT INTO `composers` (`id`, `name`) VALUES
(1, 'Jan Sebastian Bach'),
(2, 'Fryderyk Chopin');

-- --------------------------------------------------------

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
CREATE TABLE `files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `piece_id` int(11) DEFAULT NULL,
  `name` varchar(40) NOT NULL,
  `type` varchar(12) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `piece_id` (`piece_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `files`
--

INSERT INTO `files` (`id`, `piece_id`, `name`, `type`) VALUES
(1, 1, 'piece1.pdf', 'piece1.pdf'),
(2, 2, 'piece2.midi', 'MIDI'),
(3, 3, 'piece3.txt', 'txt');

-- --------------------------------------------------------

--
-- Table structure for table `fileversions`
--

DROP TABLE IF EXISTS `fileversions`;
CREATE TABLE `fileversions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_id` int(11) DEFAULT NULL,
  `download_amount` int(11) NOT NULL,
  `location` text NOT NULL,
  `time_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_id` int(11) DEFAULT NULL,
  `potwierdzony` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `file_id` (`file_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `fileversions`
--

INSERT INTO `fileversions` (`id`, `file_id`, `download_amount`, `location`, `time_created`, `user_id`, `potwierdzony`) VALUES
(1, 1, 23, '/files/sadfasdfasdf.pdf', '2014-01-25 11:48:44', 1, 0),
(2, 2, 29, '/files/asdfojubw.midi', '2014-01-25 11:49:05', 2, 0),
(3, 3, 92, '/files/aoiheaiwbf.txt', '2014-01-25 11:49:28', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `folderadmin`
--

DROP TABLE IF EXISTS `folderadmin`;
CREATE TABLE `folderadmin` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `folder_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`folder_id`),
  KEY `folder_id` (`folder_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `folderadmin`
--

INSERT INTO `folderadmin` (`user_id`, `folder_id`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `folderfile`
--

DROP TABLE IF EXISTS `folderfile`;
CREATE TABLE `folderfile` (
  `file_id` int(11) NOT NULL DEFAULT '0',
  `folder_id` int(11) NOT NULL DEFAULT '0',
  `order` int(11) DEFAULT NULL,
  PRIMARY KEY (`file_id`,`folder_id`),
  KEY `folder_id` (`folder_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `folderfile`
--

INSERT INTO `folderfile` (`file_id`, `folder_id`, `order`) VALUES
(1, 1, 0),
(2, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `foldergroup`
--

DROP TABLE IF EXISTS `foldergroup`;
CREATE TABLE `foldergroup` (
  `folder_id` int(11) NOT NULL DEFAULT '0',
  `group_id` int(11) NOT NULL DEFAULT '0',
  `expires` date NOT NULL,
  PRIMARY KEY (`folder_id`,`group_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `foldergroup`
--

INSERT INTO `foldergroup` (`folder_id`, `group_id`, `expires`) VALUES
(1, 1, '2014-01-28');

-- --------------------------------------------------------

--
-- Table structure for table `folders`
--

DROP TABLE IF EXISTS `folders`;
CREATE TABLE `folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `folders`
--

INSERT INTO `folders` (`id`, `name`) VALUES
(1, 'Na Koncert z gier video');

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `name`) VALUES
(1, 'Mathes');

-- --------------------------------------------------------

--
-- Table structure for table `pieces`
--

DROP TABLE IF EXISTS `pieces`;
CREATE TABLE `pieces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tytul` varchar(100) NOT NULL,
  `composer_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `composer_id` (`composer_id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pieces`
--

INSERT INTO `pieces` (`id`, `tytul`, `composer_id`, `category_id`) VALUES
(1, 'Power Hungry Fool', 1, 2),
(2, 'Birabiruto', 2, 3),
(3, 'Super Mario Bros ', 2, 3);

-- --------------------------------------------------------

--
-- Table structure for table `usergroup`
--

DROP TABLE IF EXISTS `usergroup`;
CREATE TABLE `usergroup` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `group_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`group_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `usergroup`
--

INSERT INTO `usergroup` (`user_id`, `group_id`) VALUES
(1, 1),
(2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `password_hash` text NOT NULL,
  `rank` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `rank`) VALUES
(1, 'Kuba', 'kupa', 777),
(2, 'Arkadiusz', 'dupa', 777);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `categories`
--
ALTER TABLE `categories`
  ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`);

--
-- Constraints for table `files`
--
ALTER TABLE `files`
  ADD CONSTRAINT `files_ibfk_1` FOREIGN KEY (`piece_id`) REFERENCES `pieces` (`id`);

--
-- Constraints for table `fileversions`
--
ALTER TABLE `fileversions`
  ADD CONSTRAINT `fileversions_ibfk_1` FOREIGN KEY (`file_id`) REFERENCES `files` (`id`),
  ADD CONSTRAINT `fileversions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `folderadmin`
--
ALTER TABLE `folderadmin`
  ADD CONSTRAINT `folderadmin_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `folderadmin_ibfk_2` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`);

--
-- Constraints for table `folderfile`
--
ALTER TABLE `folderfile`
  ADD CONSTRAINT `folderfile_ibfk_1` FOREIGN KEY (`file_id`) REFERENCES `files` (`id`),
  ADD CONSTRAINT `folderfile_ibfk_2` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`);

--
-- Constraints for table `foldergroup`
--
ALTER TABLE `foldergroup`
  ADD CONSTRAINT `foldergroup_ibfk_1` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`),
  ADD CONSTRAINT `foldergroup_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`);

--
-- Constraints for table `pieces`
--
ALTER TABLE `pieces`
  ADD CONSTRAINT `pieces_ibfk_1` FOREIGN KEY (`composer_id`) REFERENCES `composers` (`id`),
  ADD CONSTRAINT `pieces_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- Constraints for table `usergroup`
--
ALTER TABLE `usergroup`
  ADD CONSTRAINT `usergroup_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `usergroup_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
