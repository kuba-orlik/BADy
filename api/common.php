<?php

function extend($orig_array, $attrib_name, $query, $query_params){
	$units = Database::prepareAndExecute($query, $query_params);
	$orig_array[0][$attrib_name] = array();
	foreach($units AS $user){
		$orig_array[0][$attrib_name][]=$user;
	}
	return $orig_array;
}

function getAll(){
	$ids = Database::prepareAndExecute("SELECT id FROM " . TABLE_NAME . " WHERE 1");
	//var_dump($ids);
	$ret = array();
	foreach($ids AS $id){
		$ret[]=getOne($id[0]);
	}
	return $ret;
}

function parametrize($array){
	$new_arr = array();
	foreach($array AS $key=>$element){
		$new_arr[":".$key] = $element;
	}
	return $new_arr;
}

function handleRequest(){
	$method = $_SERVER['REQUEST_METHOD'];

	if($method=="GET"){
		if(!isset($_GET["id"])){
			$ret = getAll();
		}else{
			$ret = getOne($_GET["id"]);
		}	
	}
	if($method=="POST"){
		if(stripos($_SERVER["CONTENT_TYPE"], "application/json") === 0) {
			$_POST = json_decode(file_get_contents("php://input"), true);
		}
		$params = parametrize($_POST);
		try{
			$ret = handlePost($params);			
		}catch(Exception $e){
			$code = $e->errorInfo[0];
			switch($code){
				case "HY093":
					$ret = array();	
					$ret['error']= 42;
					$ret['message'] = "some required parameters missing";
					break;
				case "HY000":
					$ret = array();
					$ret['error'] = 43;
					$ret['message'] = "no parameters specified";
					break;
				case "45001":
					$ret = array();
					$ret['error'] = '1';
					$ret['message'] = $e->errorInfo[2];
					break;
				default:
					echo $code;
					var_dump($e);
					break;
			}
		}
	}

	echo json_encode($ret);	
}