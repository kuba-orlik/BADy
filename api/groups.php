<?php
include_once("../classes/database.php");

function getOne($id){
	$group = Database::prepareAndExecute("SELECT * FROM groups WHERE id=?", array($id));
	$users = Database::prepareAndExecute("CALL group_getUsers(?)", array($id));
	$group[0]['users'] = array();
	foreach($users AS $user){
		$group[0]['users'][]=$user;
	}
	$query = "call group_getFolders(?)";
	$group = extend($group, 'folders', $query, array($id));
	return $group[0];
}

function getAll(){
	$ids = Database::prepareAndExecute("SELECT id FROM groups WHERE 1");
	$ret = array();
	foreach($ids AS $id){
		$ret[]=getOne($id[0]);
	}
	return $ret;
}

function extend($orig_array, $attrib_name, $query, $query_params){
	$units = Database::prepareAndExecute($query, $query_params);
	$orig_array[0][$attrib_name] = array();
	foreach($units AS $user){
		$orig_array[0][$attrib_name][]=$user;
	}
	return $orig_array;
}

if(!isset($_GET["id"])){
	$ret = getAll();
}else{
	$ret = getOne($_GET["id"]);
}

echo json_encode($ret);