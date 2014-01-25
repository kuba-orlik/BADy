<?php

include_once("../classes/database.php");

function getOne($id){
	$group = Database::prepareAndExecute("SELECT * FROM groups WHERE id=?", array($id));
	$users = Database::prepareAndExecute("SELECT user_id, username FROM groups LEFT JOIN usergroup on groups.id=usergroup.group_id LEFT JOIN users ON users.id=usergroup.user_id WHERE group_id=?", array($id));
	$group[0]['users'] = array();
	foreach($users AS $user){
		$group[0]['users'][]=$user;
	}
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

if(!isset($_GET["id"])){
	$ret = getAll();
}else{
	$ret = getOne($_GET["id"]);
}

echo json_encode($ret);