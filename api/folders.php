<?php

include_once("../classes/database.php");
require_once("common.php");

function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM folders WHERE id=?", array($id));
	$query = "CALL folder_getFiles(?)";
	$unit = extend($unit, "files", $query, array($id));
	return $unit[0];
}

function handlePost($params){
	return Database::prepareAndExecute("call create_folder(:name)", $params)[0];
}

handleRequest();
