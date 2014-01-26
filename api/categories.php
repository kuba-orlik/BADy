<?php

DEFINE('TABLE_NAME', 'categories');

include_once("../classes/database.php");
require_once("common.php");


function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM categories WHERE id=?", array($id));
	$query = "CALL category_getPieces(?)";
	$unit = extend($unit, "pieces", $query, array($id));
	return $unit[0];
}

function handlePost($params){
	return Database::prepareAndExecute("call create_category(:name, :parent_id)", $params)[0];
}

handleRequest();