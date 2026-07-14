import { LightningElement, api } from 'lwc';

export default class ProductSelectionCmp extends LightningElement {
    @api products = [];


    connectedCallback() {

        console.log(this.products);
        this.products = JSON.parse(JSON.stringify(this.products));
        console.log(this.products);
        console.log(this.getUuid());
        var that = this;
        this.products.forEach(function(element){
            element.key = that.getUuid();
            element.Quantity__c = parseInt(element.Quantity__c);
            if(element.Device__c == 'SS_BT50') {
                element.disableDeviceType = false;
            } else
            {
                element.disableDeviceType = true;
                element.DeviceType__c = null;
            }
            if(element.Product__c== 'ClassicPlusWithPOS' && element.ContractTerm__c =='24Month') {
                element.disablePaymentServer = false;
            } else
            {
                element.disablePaymentServer = true;
                element.PaymentServer__c = null;
            }
        });
      }
    handleAddProduct() {
        this.template.querySelector('c-deal-item-modal').openModal();
    }
    saveItem(event) {
        console.log(event.detail.value);
        console.log(event.detail.productItem);
        const newProduct = event.detail.productItem;
        this.products = [...this.products, {
            key: this.getUuid(),
            Device__c: newProduct.Device__c,
            Product__c: newProduct.Product__c,
            ContractTerm__c: newProduct.ContractTerm__c,
            Quantity__c: newProduct.Quantity__c,
            DeviceType__c: newProduct.DeviceType__c,
            PaymentServer__c: newProduct.PaymentServer__c,
            BluetoothPrinterQuantity__c: newProduct.BluetoothPrinterQuantity__c,
            disableDeviceType: newProduct.disableDeviceType,
            disablePaymentServer: newProduct.disablePaymentServer,
        }];
        console.log(' After adding Record List ', this.products);
    }
    getUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    removeProduct(event) {
        const index = event.target.accessKey;
        console.log(index);
        //        this.records = this.records.splice(index, 1);
        this.products = this.products.filter(item => item.key !== index);
    }

    handleProduct(event) {
        const selectedProduct = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.products.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.products[index].Product__c = selectedProduct;
            if(selectedProduct == 'ClassicPlusWithPOS' && this.products[index].ContractTerm__c =='24Month') {
                this.products[index].disablePaymentServer = false;
                console.log(' After adding payment ', this.products);
            } else
            {
                this.products[index].disablePaymentServer = true;
                this.products[index].PaymentServer__c = null;
                console.log(' After removing payment ', this.products);
            }
        }
    }
    handleDevice(event) {
        const device = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.products.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.products[index].Device__c = device;
            if(device == 'SS_BT50') {
                this.products[index].disableDeviceType = false;
            } else
            {
                this.products[index].disableDeviceType = true;
                this.products[index].DeviceType__c = null;
            }
        }
    }
    handleDeviceType(event) {
        const deviceType = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.products.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.products[index].DeviceType__c = deviceType;
        }
    }
    handlePaymentServer(event) {
        const server = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.products.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.products[index].PaymentServer__c = server;
        }
    }
    handleTerm(event) {
        const term = event.target.value;

        const uuid = event.target.accessKey;
        const index = this.products.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.products[index].ContractTerm__c = term;
            if(this.products[index].Product__c == 'ClassicPlusWithPOS' && term =='24Month') {
                this.products[index].disablePaymentServer = false;
            } else
            {
                this.products[index].disablePaymentServer = true;
                this.products[index].PaymentServer__c = null;

            }
        }
    }
    handleQuantity(event) {
        const quantity = parseInt(event.target.value);

        const uuid = event.target.accessKey;
        const index = this.products.findIndex(item => item.key === uuid)
        if (index !== -1) {
            this.products[index].Quantity__c = quantity;
        }
    }

}