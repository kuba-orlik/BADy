<?php

include_once("../classes/database.php");
require_once("common.php");

DEFINE('TABLE_NAME', 'folders');

function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM folders WHERE id=?", array($id));
	$query = "CALL folder_getFiles(?)";
	$unit = extend($unit, "files", $query, array($id));
	$query = "CALL folder_getGroups(?)";
	$unit = extend($unit, "groups", $query, array($id));
	$query = "CALL folder_getOwners(?)";
	$unit = extend($unit, "owners", $query, array($id));
	return $unit[0];
}

function handlePost($params){
	return Database::prepareAndExecute("call create_folder(:name)", $params)[0];
}

handleRequest();
