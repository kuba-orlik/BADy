<?php

require_once("../../classes/database.php");
require_once("../common.php");

function handlePost($params){
	return Database::prepareAndExecute("call group_addFolder(:group_id, :folder_id, :expires)", $params)[0];	
}

handleRequest();

