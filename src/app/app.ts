/// <reference path="types.ts"/>

var modules = [
  'templates',

  'invoicer.invoice',

  'ui.router.state'
];

var appModule = angular.module('invoicer', modules);

var appConfig = function($urlRouterProvider: ng.ui.IUrlRouterProvider) {
    $urlRouterProvider.otherwise('/');
};

appConfig.$inject = ['$urlRouterProvider'];
appModule.config(appConfig);
