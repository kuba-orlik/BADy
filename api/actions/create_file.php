<?php

require_once("../../classes/database.php");
require_once("../common.php");

function handlePost($params){
	return Database::prepareAndExecute("call create_file(:user_id, :piece_id, :file_title, :filename, :filetype)", $params)[0];	
}

handleRequest();

