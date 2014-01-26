<?php

include_once("../classes/database.php");
require_once("common.php");

DEFINE('TABLE_NAME', 'composers');

function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM composers WHERE id=?", array($id));
	$query = "CALL composer_getPieces(?)";
	$unit = extend($unit, "pieces", $query, array($id));
	return $unit[0];
}

function handlePost($params){
	return Database::prepareAndExecute("call create_composer(:name)", $params);
}

handleRequest();