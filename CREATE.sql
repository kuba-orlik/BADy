CREATE DATABASE spiewnik;

USE spiewnik;


CREATE TABLE Users(
	id INT PRIMARY KEY AUTO_INCREMENT,
	username varchar(30) UNIQUE NOT NULL,
	password_hash text  NOT NULL,
	rank INT  NOT NULL
);

CREATE TABLE Groups(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name varchar(50)  NOT NULL
);

CREATE TABLE UserGroup(
	user_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(id),
	group_id INT,
    FOREIGN KEY (group_id) REFERENCES Groups(id),
	PRIMARY KEY (user_id, group_id)
);

CREATE TABLE Folders(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name varchar(50) NOT NULL
);

CREATE TABLE FolderGroup(
	folder_id INT,
	FOREIGN KEY (folder_id) REFERENCES Folders(id),
	group_id INT,
	FOREIGN KEY (group_id) REFERENCES Groups(id),
	expires DATE  NOT NULL,
	PRIMARY KEY(folder_id, group_id)
);

CREATE TABLE FolderAdmin(
	user_id INT,
	FOREIGN KEY (user_id) REFERENCES Users(id),
	folder_id INT,
	FOREIGN KEY (folder_id) REFERENCES Folders(id),
	PRIMARY KEY (user_id, folder_id)
);

CREATE TABLE Composers(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name varchar(50)  NOT NULL
);

CREATE TABLE Categories(
	id int PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(50)  NOT NULL,
	parent_id INT,
	FOREIGN KEY (parent_id) REFERENCES Categories(id)
);

CREATE TABLE Pieces(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tytul VARCHAR(100)  NOT NULL,
	composer_id INT,
	FOREIGN KEY (composer_id) REFERENCES Composers(id),
	category_id INT,
	FOREIGN KEY (category_id) REFERENCES Categories(id)
);

CREATE TABLE Files(
	id INT PRIMARY KEY AUTO_INCREMENT,
	piece_id INT,
	FOREIGN KEY (piece_id) REFERENCES Pieces(id),
	name VARCHAR(40)  NOT NULL,
	type varchar(12)  NOT NULL
);

CREATE TABLE FolderFile(
	file_id INT,
	FOREIGN KEY (file_id) REFERENCES Files(id),
	folder_id INT,
	`order` INT,
	FOREIGN KEY (folder_id) REFERENCES Folders(id),
	PRIMARY KEY (file_id, folder_id)
);

CREATE TABLE FileVersions(
	id INT PRIMARY KEY AUTO_INCREMENT,
	file_id INT,
	FOREIGN KEY (file_id) REFERENCES Files(id),
	download_amount INT  NOT NULL,
	location TEXT  NOT NULL,
	time_created TIMESTAMP  NOT NULL,
	user_id INT,
	FOREIGN KEY (user_id) REFERENCES Users(id)
);