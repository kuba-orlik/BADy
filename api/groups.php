<?php
include_once("../classes/database.php");
require_once("common.php");

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

function handlePost($params){
	return Database::prepareAndExecute("call create_group(:name)", $params)[0];
}

handleRequest();
