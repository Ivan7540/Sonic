import { LightningElement,wire, api, track  } from 'lwc';

 export default class DependentPicklistCmp extends LightningElement {
     @api selectedProduct;
     @api contractTerm;
     @api deviceType;
     @api paymentServer;
     @api device;
     @api quantity;
     @api showDeviceType;
     @api showPaymentServer;
     @api showBluetooth;
     @api bluetoothPrinterQty;


     handleProduct(event){
        this.selectedProduct = event.target.value;
        if(this.selectedProduct == 'ClassicPlusWithPOS' && this.contractTerm =='24Month') {
            this.showPaymentServer = true;
        } else
        {
            this.showPaymentServer = false;
            this.paymentServer =null;
        }
        if(this.selectedProduct == 'Lite') {
            this.showBluetooth = true;
        } else
        {
            this.showBluetooth = false;
            this.bluetoothPrinterQty =null;
        }
     }
     handleDevice(event){
        this.device = event.target.value;
        if(this.device == 'SS_BT50') {
            this.showDeviceType = true;
        } else
        {
            this.showDeviceType = false;
            this.deviceType = null;
        }
     }
     handleTerm(event){
        this.contractTerm = event.target.value;
        if(this.selectedProduct == 'ClassicPlusWithPOS' && this.contractTerm =='24Month') {
            this.showPaymentServer = true;
        } else
        {
            this.showPaymentServer = false;
            this.paymentServer =null;
        }
     }
      handleDeviceType(event){
        this.deviceType = event.target.value;
     }
     handlePaymentServer(event){
        this.paymentServer = event.target.value;
     }
     handleQuantity(event){
       this.quantity = event.target.value;
    }
    handleBluetoothPrinterQty(event){
        this.bluetoothPrinterQty = event.target.value;
    }
 }