<?php

include_once("../classes/database.php");
require_once("common.php");

function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM pieces WHERE id=?", array($id));
	$query = "CALL piece_getFiles(?)";
	$unit = extend($unit, "files", $query, array($id));
	return $unit[0];
}

function handlePost($params){
	return Database::prepareAndExecute("call create_piece(:title, :composer_id, :category_id)", $params)[0];
}

handleRequest();