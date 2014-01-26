var app = angular.module("app", ['ngResource', 'ngRoute']).config(
	['$routeProvider', function($routeProvider){
		$routeProvider
			.when('/users', {templateUrl: 'lists/users.html'})
			.when('/users/:id', {templateUrl: 'view_single/user.html'})
			.when('/groups', {templateUrl: 'lists/groups.html'})
			.when('/groups/:id', {templateUrl: 'view_single/group.html'})
			.when('/categories', {templateUrl: 'lists/categories.html'})
			.when('/categories/:id', {templateUrl: 'view_single/category.html'})
			.when('/composers', {templateUrl: 'lists/composers.html'})
			.when('/folders', {templateUrl: 'lists/folders.html'})
			.when('/files', {templateUrl: 'lists/files.html'})
			.when('/pieces', {templateUrl: 'lists/pieces.html'})
			.when('/pieces/:id', {templateUrl: 'view_single/piece.html'})
			.otherwise({redirectTo: '/users'});
	}]
);	;

app.controller('dataController', ['$http', '$scope', '$routeParams', function($http, $scope, $routeParams){

	$scope.source;

	$scope.setSource = function(source){
		$scope.source = source;
		$http.get(source).success(function(data){
			$scope.data = data;
		});
	}

	$scope.getSingle = function(source){
		var id = $routeParams.id;
		$http.get(source + "?id=" + id).success(function(data){
			$scope.data = data;
		});
	}

}]);