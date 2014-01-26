<?php

require_once("../../classes/database.php");
require_once("../common.php");

function handlePost($params){
	return Database::prepareAndExecute("call create_category(:name, :parent_id)", $params)[0];	
}

handleRequest();

