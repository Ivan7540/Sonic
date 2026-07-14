/**
 * Created by JurgitaG on 3/1/2021.
 */

import { LightningElement, track, api } from 'lwc';

export default class DealItemModal extends LightningElement {
    @track isModalOpen = false;
    @api productItem ;

    @api
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing

        this.productItem = {
             Device__c:this.template.querySelector('c-dependent-picklist-c-m-p').device,
             Product__c: this.template.querySelector('c-dependent-picklist-c-m-p').selectedProduct,
             ContractTerm__c: this.template.querySelector('c-dependent-picklist-c-m-p').contractTerm,
             Quantity__c: this.template.querySelector('c-dependent-picklist-c-m-p').quantity,
             DeviceType__c: this.template.querySelector('c-dependent-picklist-c-m-p').deviceType,
             PaymentServer__c: this.template.querySelector('c-dependent-picklist-c-m-p').paymentServer,
             BluetoothPrinterQuantity__c: this.template.querySelector('c-dependent-picklist-c-m-p').bluetoothPrinterQty,
             disableDeviceType: this.template.querySelector('c-dependent-picklist-c-m-p').disableDeviceType,
             disablePaymentServer: this.template.querySelector('c-dependent-picklist-c-m-p').disablePaymentServer,

         };
         console.log(this.productItem);

        this.isModalOpen = false;
        this.onProductSave();
    }

    onProductSave(){
       const passEventr = new CustomEvent('addproductevent', {
         detail: { productItem: this.productItem }
        });
        this.dispatchEvent(passEventr);
      }
}