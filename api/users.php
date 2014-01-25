<?php

include_once("../classes/database.php");

function getUserInfo($id){
	$user = Database::prepareAndExecute("SELECT * FROM users WHERE id=?", array($id));
	$groups = Database::prepareAndExecute("SELECT groups.id AS group_id, groups.name AS group_name FROM users LEFT JOIN usergroup on users.id = usergroup.user_id LEFT JOIN groups ON groups.id=usergroup.group_id WHERE users.id=?", array($id));
	$user[0]['groups'] = array();
	foreach($groups AS $group){
		$user[0]['groups'][]=$group;
	}
	return $user[0];
}

function getAllUsersInfo(){
	$ids = Database::prepareAndExecute("SELECT id FROM users WHERE 1" );
	$ret = array();
	foreach($ids AS $id){
		$ret[]=getUserInfo($id[0]);
	}
	return $ret;
}

if(!isset($_GET["id"])){
	$ret = getAllUsersInfo();
}else{
	$ret = getUserInfo($_GET["id"]);
}

echo json_encode($ret);