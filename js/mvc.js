var app = angular.module("app", ['ngResource', 'ngRoute']).config(
	['$routeProvider', function($routeProvider){
		$routeProvider
			.when('/users', {templateUrl: 'lists/users.html'})
			.when('/groups', {templateUrl: 'lists/groups.html'})
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