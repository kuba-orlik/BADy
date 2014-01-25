<?php

include_once("../classes/database.php");

function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM composers WHERE id=?", array($id));
	$query = "CALL composer_getPieces(?)";
	$unit = extend($unit, "pieces", $query, array($id));
	return $unit[0];
}

function extend($orig_array, $attrib_name, $query, $query_params){
	$units = Database::prepareAndExecute($query, $query_params);
	$orig_array[0][$attrib_name] = array();
	foreach($units AS $user){
		$orig_array[0][$attrib_name][]=$user;
	}
	return $orig_array;
}

function getAll(){
	$ids = Database::prepareAndExecute("SELECT id FROM folders WHERE 1");
	$ret = array();
	foreach($ids AS $id){
		$ret[]=getOne($id[0]);
	}
	return $ret;
}

if(!isset($_GET["id"])){
	$ret = getAll();
}else{
	$ret = getOne($_GET["id"]);
}

echo json_encode($ret);