var app = angular.module("app", ['ngResource', 'ngRoute']).config(
	['$routeProvider', function($routeProvider){
		$routeProvider
			.when('/users', {templateUrl: 'lists/users.html'})
			.when('/groups', {templateUrl: 'lists/groups.html'})
			.when('/categories', {templateUrl: 'lists/categories.html'})
			.when('/composers', {templateUrl: 'lists/composers.html'})
			.when('/folders', {templateUrl: 'lists/folders.html'})
			.when('/files', {templateUrl: 'lists/files.html'})
			.when('/pieces', {templateUrl: 'lists/pieces.html'})			
			.otherwise({redirectTo: '/users'});
	}]
);	;

app.controller('dataController', ['$http', '$scope', function($http, $scope){

	$scope.source;

	$scope.setSource = function(source){
		$scope.source = source;
		$http.get(source).success(function(data){
			$scope.data = data;
		});
	}

}]);