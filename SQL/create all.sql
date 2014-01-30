
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_category`(IN `nameL` VARCHAR(50), IN `parent_idL` INT)
    NO SQL
proc_label:BEGIN
DECLARE parent_idTEMP int;
IF parent_idL IS NOT NULL
THEN
  SELECT id INTO parent_idTEMP FROM categories WHERE id=parent_idL;
  if (SELECT coalesce(parent_idTEMP, 0))=0
  THEN
    SELECT "1" AS error, "incorrect parent_id" AS message;
    LEAVE proc_label;
  END IF;
END IF;
INSERT INTO categories (name, parent_id) VALUES (nameL, parent_idL);
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_composer`(IN `nameL` VARCHAR(50))
    NO SQL
BEGIN
INSERT INTO composers (name) VALUES (nameL);
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_file`(IN `user_idL` INT, IN `piece_idL` INT, IN `file_titleL` INT, IN `filenameL` TEXT, IN `typeL` VARCHAR(10))
proc_label:BEGIN
DECLARE file_id int;
DECLARE piece_exists int;
DECLARE user_exists int;
SELECT COUNT(id) INTO piece_exists FROM pieces WHERE id=piece_idL;
if piece_exists=0
THEN
  SELECT "1" AS error, "incorrect piece id" AS message;
  LEAVE proc_label;
END IF;
SELECT COUNT(id) INTO user_exists FROM users WHERE id=user_idL;
if user_exists=0
THEN
  SELECT "2" AS error, "incorrect user id" AS message;
  LEAVE proc_label;
END IF;
INSERT INTO files (piece_id, name, type) VALUES (piece_idL, file_titleL, typeL);
SET file_id = LAST_INSERT_ID();
CALL create_fileVersion(user_idL, file_id, filenameL);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_fileVersion`(IN `user_idL` INT, IN `file_idL` INT, IN `filenameL` VARCHAR(30))
    MODIFIES SQL DATA
BEGIN
DECLARE rankTEMP int;
DECLARE approved boolean;
SELECT rank into rankTEMP FROM users WHERE id=user_idL;
if rankTemp>500 THEN SET approved = true; else SET approved = false; end if;
INSERT INTO fileversions (file_id, location, time_created, user_id, potwierdzony) VALUES (file_idL, filenameL, curtime(), user_idL, approved);
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_folder`(IN `nameL` VARCHAR(50))
    NO SQL
BEGIN
INSERT INTO folders (name) values (nameL);
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_group`(IN `name` VARCHAR(50))
    NO SQL
proc_label:BEGIN
if (SELEct length(name)<4)
then
    SElect "23" AS error, "name too short" AS message;
    LEAVE proc_label;
end if;    
INSERT INTO groups (name) VALUES (name);
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_piece`(IN `titleL` VARCHAR(100), IN `composer_idL` INT, IN `category_idL` INT)
    MODIFIES SQL DATA
proc_label:BEGIN
DECLARE composer_exists boolean;
DECLARE composer_idTEMP int;
DECLARE category_exists boolean;
DECLARE category_idTEMP int;
SET category_exists = 1;
SET composer_exists = 1;
SELECT id INTO composer_idTEMP FROM composers WHERE id=composer_idL;
SELECT id INTO category_idTEMP FROM categories WHERE id=category_idL;
if (SELECT COALESCE(composer_idTEMP, 0))=0
  THEN SET composer_exists=0;
END IF;
IF (SELECT COALESCE(category_idTEMP, 0))=0
  THEN SET category_exists = 0;
END IF;
IF NOT composer_exists
THEN
  SELECT "1" AS error, "composer does not exist" AS message;
  LEAVE proc_label;
END IF;
IF NOT category_exists
THEN
  SELECT "2" AS error, "category does not exist" AS message;
  LEAVE proc_label;
END IF;
INSERT INTO pieces (tytul, composer_id, category_id) VALUES (titleL, composer_idL, category_idL);
SELECT "0" AS error, "ok" as message;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_user`(IN `usernameL` VARCHAR(30), IN `password_hashL` TEXT)
    MODIFIES SQL DATA
BEGIN
DECLARE EXIT HANDLER FOR  SQLSTATE '23000' SELECT "3" AS error, "username taken" AS message;
INSERT INTO users (username, password_hash, rank) VALUES (usernameL, password_hashL, 0);
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `file_getPiece`(IN `param` INT)
    NO SQL
SELECT * FROM pieces WHERE id=(SELECT piece_id FROM files WHERE id=param)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `file_getVersions`(IN `param` INT)
    READS SQL DATA
SELECT * FROM fileversions WHERE file_id=param$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `folder_addOwner`(folder_idL int, user_idL int)
BEGIN
  -- DECLARE EXIT HANDLER FOR  SQLSTATE '23000' SELECT "3" AS error, "user already assigned to folder" AS message;
  INSERT INTO folderadmin VALUES(user_idL, folder_idL);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `folder_getFiles`(IN `folder_idL` INT)
    NO SQL
SELECT * FROM files WHERE id IN(
  SELECT folder_id FROM folderfile WHERE folder_id=folder_idL
)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `folder_getGroups`(IN `folder_idL` INT)
    NO SQL
SELECT * FROM groups WHERE id in (
    SELECT group_id FROM foldergroup WHERE folder_id=folder_idL AND expires>CURDATE()
    )$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `folder_getOwners`(IN `folder_idL` INT)
    NO SQL
proc_label:BEGIN
If (SELECT count(id)=0 FROM folders WHERE id=folder_idL)
THEN
  SELECT "1" AS error, "folder does not exist" AS message;
  LEAVE proc_label;
END IF;
SELECT user_id AS id, username FROM owners WHERE folder_id=folder_idL;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_addFolder`(IN `group_idL` INT, IN `folder_idL` INT, IN `dateL` DATE)
    NO SQL
proc_label:BEGIN
-- DECLARE EXIT HANDLER FOR  SQLSTATE '23000' SELECT "3" AS error, "folder already assigned to that group" AS message;
if (SELECT count(id)=0 from groups WHERE id=group_idL)
then
  SELECT "234" AS error, "group does not exist" AS message;
  LEAVE proc_label;
end if;
if (SELECT count(id)=0 from folders WHERE id=folder_idL)
then
  SELECT "235" AS error, "folder does not exist" AS message;
  LEAVE proc_label;
end if;
INSERT INTO foldergroup (folder_id, group_id, expires) VALUES (folder_idL, group_idL, dateL) ON DUPLICATE KEY UPDATE expires=dateL;
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_addUser`(IN `group_idL` INT, IN `user_idL` INT)
    NO SQL
label_proc:BEGIN
DECLARE EXIT HANDLER FOR  SQLSTATE '23000' SELECT "3" AS error, "user already in group" AS message;
if (SELECT count(id)=0 FROM users WhERE id=user_idL)
THEN
  SELECT "1" AS error, "incorrect user" AS message;
  LEAVE label_proc;
END IF;
if (SELECT count(id)=0 FROM groups WhERE id=group_idL)
THEN
  SELECT "1" AS error, "incorrect group" AS message;
  LEAVE label_proc;
END IF;
INSERT INTO usergroup (user_id, group_id) VALUES (user_idL, group_idL);
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_getFolders`(IN `group_idL` INT)
    READS SQL DATA
SELECT folders.id AS id, folders.name AS name FROM foldergroup LEFT JOIN folders ON foldergroup.folder_id = folders.id WHERE foldergroup.group_id=group_idL AND foldergroup.expires>CURDATE()$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_getUsers`(IN `group_idL` INT)
    READS SQL DATA
SELECT * FROM users WHERE id IN (
  SELECT user_id FROM usergroup WHERE group_id=group_idL
)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_removeUser`(IN `group_idL` INT, IN `user_idL` INT)
    NO SQL
label_proc:BEGIN
DECLARE EXIT HANDLER FOR  SQLSTATE '23000' SELECT "3" AS error, "user already in group" AS message;
if (SELECT count(id)=0 FROM users WhERE id=user_idL)
THEN
  SELECT "1" AS error, "incorrect user" AS message;
  LEAVE label_proc;
END IF;
if (SELECT count(id)=0 FROM groups WhERE id=group_idL)
THEN
  SELECT "1" AS error, "incorrect group" AS message;
  LEAVE label_proc;
END IF;
if (SELECT count(user_id)=0 FROM usergroup WhERE user_id=user_idL AND group_id=group_idL)
THEN
  SELECT "1" AS error, "user not present in the group" AS message;
  LEAVE label_proc;
END IF;
DELETE FROM usergroup WHERE user_id=user_idL AND group_id=group_idL;
SELECT "0" AS error, "ok" AS message;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `piece_getCategory`(IN `idL` INT)
    NO SQL
SELECT * FROM categories WHERE id=(SELECT category_id FROM pieces WHERE id=idL)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `piece_getComposer`(IN `idL` INT)
    NO SQL
SELECT * FROM composers WHERE id=(SELECT composer_id FROM pieces WHERE id=idL)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `piece_getFiles`(IN `param` INT)
    READS SQL DATA
SELECT * FROM files WHERE piece_id=param$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `user_getFolders`(IN `user_idL` INT)
    READS SQL DATA
proc_label:BEGIN
if (SELECT count(id)=0 FROM users WHERE id=user_idL)
THEN
  SELECT "1" AS error, "user does not exist" AS message;
  LEAVE proc_label;
END IF;
SELECT id, name FROM userfolder WHERE user_id=user_idL;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `user_getFoldersOwned`(IN `user_idL` INT)
    NO SQL
proc_label:BEGIN
if (SELECT count(id)=0 FROM users WHERE id=user_idL)
THEN
  SELECT "1" AS error, "incorrect user" AS message;
  LEAVE proc_label;
END IF;
SELECT * from owners WHERE user_id=user_idL;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `user_getGroups`(IN `user_idL` INT)
    NO SQL
proc_label:BEGIN
IF (SELECT count(id)=0 FROM users WHERE id=user_idL)
THEN
  SELECT "1" AS error, "invalid user id" AS message;
  LEAVE proc_label;
END IF;
SELECT group_id AS id, group_name AS name FROM usergroupview WHERE user_id=user_idL;
END$$

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

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE IF NOT EXISTS `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=12 ;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `parent_id`) VALUES
(1, 'Wg Nastroju', NULL),
(2, 'Wesołe', 1),
(3, 'Smutne', 1),
(5, 'bardzo wesołe', 2),
(6, 'barok', 1),
(7, 'bardzo smutne', 3),
(8, 'super', NULL),
(10, 'spoko', NULL),
(11, 'badowe takie wow', 2);

--
-- Triggers `categories`
--
DROP TRIGGER IF EXISTS `trywialneLubWulgarne`;
DELIMITER //
CREATE TRIGGER `trywialneLubWulgarne` BEFORE INSERT ON `categories`
 FOR EACH ROW BEGIN
DECLARE new_name text;
DECLARE msg VARCHAR(255);
SELECT lcase(NEW.name) INTO new_name;
if(SELECT new_name LIKE "%kurw%" OR new_name LIKE "%fajn%" OR new_name LIKE "%chuj%" OR new_name LIKE "%zajeb%" OR new_name LIKE "%jebn%")
then
  set msg = "the category name you provided is against the rules";
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = msg;
end if;

END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `composers`
--

CREATE TABLE IF NOT EXISTS `composers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `composers`
--

INSERT INTO `composers` (`id`, `name`) VALUES
(1, 'Jan Sebastian Bach'),
(2, 'Fryderyk Chopin'),
(3, 'Koji Kondo'),
(4, 'Koji Kondo'),
(5, 'Józef Pi?sudski');

-- --------------------------------------------------------

--
-- Table structure for table `files`
--

CREATE TABLE IF NOT EXISTS `files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `piece_id` int(11) DEFAULT NULL,
  `name` varchar(40) NOT NULL,
  `type` varchar(12) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `piece_id` (`piece_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=23 ;

--
-- Dumping data for table `files`
--

INSERT INTO `files` (`id`, `piece_id`, `name`, `type`) VALUES
(1, 1, 'piece1.pdf', 'piece1.pdf'),
(2, 2, 'piece2.midi', 'MIDI'),
(3, 3, 'piece3.txt', 'txt'),
(4, 1, 'tekst.txt', 'TXT'),
(5, 1, 'tekts.txt', 'txt'),
(6, 1, '1234', '1234'),
(7, 1, '12314515', 'txt'),
(8, 1, 'title', 'TXT'),
(9, 1, 'kupa', 'kup'),
(10, 1, 'test', 'test'),
(11, 1, 'ijijijijij', 'ijijijjij'),
(12, 1, 'origjpowiugrpiuh', 'iuhpusghp'),
(13, 1, 'oooooooo', 'oooooo'),
(17, 1, '23', '23'),
(18, 1, '23', '23'),
(19, 1, '23', '23'),
(20, 1, '0', 'pdf'),
(21, 1, '0', 'pdf'),
(22, 1, '0', 'pdf');

-- --------------------------------------------------------

--
-- Table structure for table `fileversions`
--

CREATE TABLE IF NOT EXISTS `fileversions` (
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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=18 ;

--
-- Dumping data for table `fileversions`
--

INSERT INTO `fileversions` (`id`, `file_id`, `download_amount`, `location`, `time_created`, `user_id`, `potwierdzony`) VALUES
(1, 1, 23, '/files/sadfasdfasdf.pdf', '2014-01-25 11:48:44', 1, 0),
(2, 2, 29, '/files/asdfojubw.midi', '2014-01-25 11:49:05', 2, 0),
(3, 3, 92, '/files/aoiheaiwbf.txt', '2014-01-25 11:49:28', 1, 0),
(4, 1, 0, 'hamsrer.tes', '2014-01-24 23:00:00', 1, 1),
(5, 2, 0, 'niepotwierdzony.pdf', '2014-01-24 23:00:00', 3, 0),
(7, 1, 0, '2', '2014-01-25 19:16:33', 1, 1),
(8, NULL, 0, 'origjpowiugrpiuh', '2014-01-25 19:38:12', 1, 1),
(9, 13, 0, 'oooooooo', '2014-01-25 19:41:00', 1, 1),
(11, 18, 0, '23', '2014-01-26 11:50:29', 1, 1),
(12, 19, 0, '23', '2014-01-26 11:51:08', 1, 1),
(13, 20, 0, 'alty.pdf', '2014-01-30 18:41:30', 1, 1),
(14, 21, 0, 'alty.pdf', '2014-01-30 18:41:33', 1, 1),
(15, 22, 0, 'alty.pdf', '2014-01-30 18:47:13', 3, 0),
(16, 1, 0, '', '2014-01-30 19:44:16', 3, 0),
(17, 1, 0, '', '2014-01-30 19:44:52', 1, 1);

--
-- Triggers `fileversions`
--
DROP TRIGGER IF EXISTS `potwierdzenie`;
DELIMITER //
CREATE TRIGGER `potwierdzenie` BEFORE INSERT ON `fileversions`
 FOR EACH ROW begin
  if (SELECT rank<500 FROM users WHERE id=NEW.user_id)
  THEN
    SET NEW.potwierdzony = 0;
  else
    SET NEW.potwierdzony = 1;
  END IF;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `folderadmin`
--

CREATE TABLE IF NOT EXISTS `folderadmin` (
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

CREATE TABLE IF NOT EXISTS `folderfile` (
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

CREATE TABLE IF NOT EXISTS `foldergroup` (
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
(1, 1, '2012-03-03'),
(1, 2, '2012-03-03'),
(1, 3, '2014-04-04'),
(1, 9, '2014-04-04');

-- --------------------------------------------------------

--
-- Table structure for table `folders`
--

CREATE TABLE IF NOT EXISTS `folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `folders`
--

INSERT INTO `folders` (`id`, `name`) VALUES
(1, 'Na Koncert z gier video'),
(3, 'Nowszy folder');

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE IF NOT EXISTS `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `name`) VALUES
(1, 'Mathes'),
(2, 'Lubimy placki'),
(3, 'nowa grupa'),
(9, 'WMI fans'),
(10, 'Bashowcy');

-- --------------------------------------------------------

--
-- Stand-in structure for view `owners`
--
CREATE TABLE IF NOT EXISTS `owners` (
`folder_id` int(11)
,`name` varchar(50)
,`user_id` int(11)
,`username` varchar(30)
,`rank` int(11)
);
-- --------------------------------------------------------

--
-- Table structure for table `pieces`
--

CREATE TABLE IF NOT EXISTS `pieces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tytul` varchar(100) NOT NULL,
  `composer_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `composer_id` (`composer_id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `pieces`
--

INSERT INTO `pieces` (`id`, `tytul`, `composer_id`, `category_id`) VALUES
(1, 'Power Hungry Fool', 1, 2),
(2, 'Birabiruto', 2, 3),
(3, 'Super Mario Bros ', 2, 3),
(4, 'Sin and Punishment', 3, 3),
(5, 'Hamster, a dentist', 1, 1),
(7, 'TROLOLOLO', 3, 3);

-- --------------------------------------------------------

--
-- Stand-in structure for view `userfolder`
--
CREATE TABLE IF NOT EXISTS `userfolder` (
`user_id` int(11)
,`username` varchar(30)
,`id` int(11)
,`name` varchar(50)
);
-- --------------------------------------------------------

--
-- Table structure for table `usergroup`
--

CREATE TABLE IF NOT EXISTS `usergroup` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `group_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`group_id`),
  KEY `usergroup_ibfk_2` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `usergroup`
--

INSERT INTO `usergroup` (`user_id`, `group_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(2, 2),
(4, 2),
(1, 3),
(1, 9),
(2, 9),
(3, 9),
(4, 10),
(7, 10);

-- --------------------------------------------------------

--
-- Stand-in structure for view `usergroupview`
--
CREATE TABLE IF NOT EXISTS `usergroupview` (
`group_id` int(11)
,`group_name` varchar(50)
,`username` varchar(30)
,`user_id` int(11)
);
-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(30) NOT NULL,
  `password_hash` text NOT NULL,
  `rank` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password_hash`, `rank`) VALUES
(1, 'Kuba', 'kupa', 777),
(2, 'Arkadiusz', 'dupa', 777),
(3, 'groovy354', 'zupa', 0),
(4, 'bash-sh', 'handsome', 0),
(7, 'bash-sh2', 'handsome', 0),
(8, 'hamster', 'a dentist', 0),
(9, 'nowy_nieistniejacy', 'haslohaslo', 0);

-- --------------------------------------------------------

--
-- Structure for view `owners`
--
DROP TABLE IF EXISTS `owners`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `owners` AS select `folders`.`id` AS `folder_id`,`folders`.`name` AS `name`,`users`.`id` AS `user_id`,`users`.`username` AS `username`,`users`.`rank` AS `rank` from ((`folders` left join `folderadmin` on((`folderadmin`.`folder_id` = `folders`.`id`))) left join `users` on((`folderadmin`.`user_id` = `users`.`id`)));

-- --------------------------------------------------------

--
-- Structure for view `userfolder`
--
DROP TABLE IF EXISTS `userfolder`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `userfolder` AS select distinct `users`.`id` AS `user_id`,`users`.`username` AS `username`,`folders`.`id` AS `id`,`folders`.`name` AS `name` from ((((`users` left join `usergroup` on((`users`.`id` = `usergroup`.`user_id`))) left join `groups` on((`groups`.`id` = `usergroup`.`group_id`))) left join `foldergroup` on((`foldergroup`.`group_id` = `groups`.`id`))) left join `folders` on((`foldergroup`.`folder_id` = `folders`.`id`))) where (`foldergroup`.`folder_id` is not null);

-- --------------------------------------------------------

--
-- Structure for view `usergroupview`
--
DROP TABLE IF EXISTS `usergroupview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usergroupview` AS select `groups`.`id` AS `group_id`,`groups`.`name` AS `group_name`,`users`.`username` AS `username`,`users`.`id` AS `user_id` from ((`groups` left join `usergroup` on((`usergroup`.`group_id` = `groups`.`id`))) left join `users` on((`users`.`id` = `usergroup`.`user_id`)));

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
  ADD CONSTRAINT `usergroup_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
