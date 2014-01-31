use spiewnik;

SELECT * FROM pieces;

-- wyświetlanie np użytkowników
SELECT * FROM users;

-- wyświetlanie grup, od których należy dany użytkownik

-- --użytkownik istnieje:
		CALL user_getGroups(12);

-- --użytkownik nie istnieje (błąd):
		CALL user_getGroups(354);


-- utworzenie pliku

-- -- utworzenie przez użytkownika o wysokiej randze
	CALL create_file(12, 1, 'opracowanie', 'opracowanie.pdf', 'pdf');
	SELECT * FROM fileversions;
--	jak widać, nowo utworzony plik jest automatycznie oznaczony jako "potwierdzony"

-- --przez użytkownika o niskiej randze
	SELECt * FROM users WHERE rank=0;
	CALL create_file(15, 1, 'opracowanie2', 'opracowanie2.pdf', 'pdf');
	SELECT * FROM fileversions;
--	jak widać, nowo utworzony plik jest oznaczony jako "wymagający potwierdzenia"



-- utworzenie użytkownika
	CALL create_user('nowy_nieistniejacy', 'haslohaslo');

--	 jeżeli nazwa jest już zajęta:
	CALL create_user('groovy354', 'asdgsadga');

-- zczytanie utworów należących do danej kategorii, a także do wszystkich podkategorii danej kategorii (STRUKTURA DRZEWIASTA WOW)
	CALL category_getPieces(1);


-- stworzenie niecenzuralnej/trywialnej nazwy kategorii
	CALL create_category("fajne", NULL); -- rzuca Wyjątek :3

-- dodanie folderu do grupy 
id_gr, id_folder
	CALL group_addFolder(1, 1, '2014-03-03');

-- teraz dodamy folder do grupy, ale z nieaktualną datą ważności 
	CALL group_addFolder(1, 1, '2012-03-03');
--	-- wyświetlamy aktywne foldery dla danej grupy:
	call group_getFolders(1);


-- demonstracja triggera na potwierdzanie plików

SELECT * FROM users; -- szukamy użytkownika o rankingu <500
INSERT INTO fileversions (file_id, user_id) VALUES (1, 14);
SELECT * FROM fileversions; -- najnowszy plik jest niepotwierdzony

SELECT * FROM users; -- szukamy użytkownika o rankingu >500
INSERT INTO fileversions (file_id, user_id) VALUES (1, 13);
SELECT * FROM fileversions; -- najnowszy plik jest potwierdzony


