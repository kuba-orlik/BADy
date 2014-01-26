
DELIMITER $$
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `group_addFolder`(IN `group_idL` INT, IN `folder_idL` INT, IN `dateL` DATE)
    NO SQL
proc_label:BEGIN
DECLARE EXIT HANDLER FOR  SQLSTATE '23000' SELECT "3" AS error, "folder already assigned to that group" AS message;
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

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
