<?php

include_once("../classes/database.php");
require_once("common.php");

function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM files WHERE id=?", array($id));
	$query = "CALL file_getPiece(?)";
	$unit = extend($unit, "piece", $query, array($id));
	$query = "CALL file_getVersions(?)";
	$unit = extend($unit, "versions", $query, array($id));
	return $unit[0];
}

function handlePost($params){
	return Database::prepareAndExecute("call create_file(:user_id, :piece_id, :file_title, :filename, :type)", $params)[0];
}

handleRequest();

