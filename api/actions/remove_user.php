<?php

require_once("../../classes/database.php");
require_once("../common.php");

function handlePost($params){
	return Database::prepareAndExecute("call group_removeUser(:group_id, :user_id)", $params)[0];	
}

handleRequest();

