<?php

require_once (dirname(__FILE__) . "/../config.php");

class Database{
	
	//private static $database_name = "ozorro";
	//private static $username = "rest";
	//private static $password = "rest";
	
	
	private static $database_name = DATABASE_NAME;
	private static $username = DATABASE_USR;
	private static $password = DATABASE_PWD;
	
	private static $connected = false;
	
	private static $pdo;
		
	
	
	public static function connectPDO(){
		if(self::$connected){
			return $self::$pdo;
		}else{
			$db = new PDO('mysql:host=127.0.0.1;dbname=' . self::$database_name . ';charset=utf8', self::$username, self::$password, array(PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION));
			return $db;			
		}
	}

	private static function replace_question_marks($query, $parameters){
		foreach($parameters AS $parameter){
			$query = preg_replace("/\?/", $parameter, $query, 1);
		}
		return $query;
	}

	private static function log($entry_content){
		$date = date('m/d/Y h:i:s a', time());
		$entry = "$date \t $entry_content \r\n";
		//file_put_contents(DIR_CLASSES . 'log.txt', $entry, FILE_APPEND);
	}

	private static function getTimestamp(){
		/*$utimestamp = microtime(true);
  		$timestamp = floor($utimestamp);
  		$milliseconds = round(($utimestamp - $timestamp) * 1000000);*/
  		return round(microtime(true) * 1000);
	}

	public static function prepareAndExecute($query_template, $attributes = array()){
		$timestamp = self::getTimestamp();
		$db = self::connectPDO();
		$prp = $db->prepare($query_template);
		$prp->execute($attributes);
		$time_passed = self::getTimestamp()-$timestamp;
		self::log(self::replace_question_marks($prp->queryString, $attributes) . ", time: $time_passed ms");
		//var_dump(strpos('UPDATE', strtoupper($query_template)));
		if(strpos(strtoupper($query_template), 'UPDATE')===false && strpos(strtoupper($query_template), 'INSERT')===false){
			$rows = $prp->fetchAll();			
		}
		return $rows;
	}

	public static function execute($query){
		$db = self::connectPDO();
		$stm = $db->query($query);
		self::log($query);
		$stm->execute();
		$rows = $stm->fetchAll();
		return $rows;
	}
}
