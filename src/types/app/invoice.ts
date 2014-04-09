/// <reference path="../angular.d.ts"/>


module invoice {

  // MODELS
  export interface ICompanyInfo {
    name: string;
    companyNumber: string;
    website: string;
    address1: string;
    address2: string;
    email: string;
    additionalInfo: string;
    vatRegistrationNumber: string;
  }

  export interface IClientInfo {
    name: string;
    address1: string;
    address2: string;
  }

  export interface IInvoiceItem {
    description: string;
    quantity: number;
    price: number;
  }

  export interface IInvoice {
    number: string;
    companyInfo: ICompanyInfo;
    clientInfo: IClientInfo;
    currency: string;
    tax: number;
    date: string;
    dueDate: string;
    paymentTerms: string;
    items: IInvoiceItem[];
  }

  export interface IController {
    invoice: invoice.IInvoice;

    calculateSubtotal();
    calculateTaxes();
  }

}
