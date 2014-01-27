<?php

DEFINE('TABLE_NAME', 'users');

include_once("../classes/database.php");
require_once("common.php");


function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM users WHERE id=?", array($id));
	$query = "CALL user_getFolders(?)";
	$unit = extend($unit, "folders", $query, array($id));
	$query = "CALL user_getFoldersOwned(?)";
	$unit = extend($unit, "folders_owned", $query, array($id));
	$query = "CALL user_getGroups(?)";
	$unit = extend($unit, "groups", $query, array($id));
	return $unit[0];
}

function handlePost($params){
	return Database::prepareAndExecute("call create_category(:name, :parent_id)", $params)[0];
}

handleRequest();