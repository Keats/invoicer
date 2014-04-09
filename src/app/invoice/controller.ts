/// <reference path="../types.ts"/>

var invoiceController = angular.module('invoice.controller', []);


class InvoiceController implements invoice.IController {
  static $inject = [
    '$scope'
  ];

  invoice = {
    'number': 'ABC123',
    'companyInfo': {
      'name': 'ACME Corp',
      'companyNumber': '12423',
      'website': 'www.acme.world',
      'address1': '23 Infinite Street',
      'address2': 'Walala, Moon',
      'email': 'world@domination.com',
      'vatRegistrationNumber': '23-23-24'
    },
    'clientInfo': {
      'name': 'Client Inc',
      'address1': '10 Downing Street',
      'address2': 'SW1A 2AA, London, UK'
    },
    'currency': '£',
    'tax': 20,
    'date': '2014/04/01',
    'dueDate': '2014/04/15',
    'items': [
      {'description': 'Something invoiceable', 'price': 75, quantity:3}
    ],
    'paymentTerms': 'BLABLA'
   };

  constructor(private $scope: core.IScope) {
    $scope.vm = this;
  }

  calculateSubtotal() {
    var subtotal = 0;
    this.invoice.items.forEach(function(item) {
      subtotal += item.quantity * item.price;
    });
    return subtotal;
  }

  calculateTaxes() {
    return (this.calculateSubtotal() * this.invoice.tax) /100;
  }

  removeItem(item: invoice.IItem) {
    this.invoice.items.splice(this.invoice.items.indexOf(item), 1);
  }

  addItem() {
    this.invoice.items.push(
      {'description': 'New row', 'price': 0, 'quantity': 0}
    )
  }

}

invoiceController.controller('InvoiceController', InvoiceController);
