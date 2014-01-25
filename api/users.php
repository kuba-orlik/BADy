<?php

include_once("../classes/database.php");
if(!isset($_GET["id"])){
	$query = "SELECT username, rank, groups.id AS group_id, groups.name AS group_name FROM users LEFT JOIN usergroup on users.id = usergroup.user_id LEFT JOIN groups ON groups.id=usergroup.group_id";	
	$rows = Database::prepareAndExecute($query, array());
}else{
	$query = "SELECT username, rank, groups.id AS group_id, groups.name AS group_name FROM users LEFT JOIN usergroup on users.id = usergroup.user_id LEFT JOIN groups ON groups.id=usergroup.group_id WHERE users.id=?";
	$rows = Database::prepareAndExecute($query, array($_GET['id']));
}

echo json_encode($rows);