/// <reference path="../types.ts"/>

var modules = [
  'ui.router.state'
];

var invoice = angular.module('invoicer.invoice', modules);

var invoiceConfig = function($stateProvider:ng.ui.IStateProvider) {
  $stateProvider.state('invoice', {
    url: '/',
    controller: 'InvoiceController',
    templateUrl: 'invoice/default.html'
  });
};

invoiceConfig.$inject = ['$stateProvider'];
invoice.config(invoiceConfig);
