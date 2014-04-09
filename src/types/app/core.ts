/// <reference path="../angular.d.ts"/>

// Things used everywhere
module core {
  export interface IScope extends ng.IScope {
    vm: any;
  }
}