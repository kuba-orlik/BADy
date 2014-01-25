<?php

include_once("../classes/database.php");

function getOne($id){
	$unit = Database::prepareAndExecute("SELECT * FROM folders WHERE id=?", array($id));
	$users = Database::prepareAndExecute("SELECT user_id, username FROM folders LEFT JOIN usergroup on folders.id=usergroup.group_id LEFT JOIN users ON users.id=usergroup.user_id WHERE group_id=?", array($id));
	$unit[0]['users'] = array();
	foreach($users AS $user){
		$unit[0]['users'][]=$user;
	}
	return $unit[0];
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