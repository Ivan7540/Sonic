/**
 * Created by ViktorijaR on 12/21/2021.
 */

import { LightningElement, api } from 'lwc';
import getAllVAS from '@salesforce/apex/DealProductController.getAllVAS';
import getDeviceServiceConfig from '@salesforce/apex/DealProductController.getDeviceServiceConfig';

export default class DealServiceDevice extends LightningElement {
    @api metadataId;
    @api recordId;
    @api deviceId;
    @api itemKey;
    @api deviceLabel;
    @api lineNumber;
    @api allDeviceServConf = [];


    vas = [
        { label: 'Acquiring', value: 'option1' },
        { label: 'SwitchPay', value: 'option2' },
        { label: 'MoreTyme', value: 'option3' },
        { label: 'MasterPass', value: 'option4' },
        { label: 'Gift & Loyalty', value: 'option5' },
    ];

    connectedCallback() {
        console.log(this.lineNumber);
        this.lineNumber++;// = this.lineNumber + 1;
        console.log(this.lineNumber);
//        console.log('dealServiceDevice');
//        console.log(this.vas);
//        console.log(this.devices);
    }
//    getDeviceServiceConfig
//    getDeviceServiceConfig({
//        metadataId: this.metadataId
//    }).then(result => {
//        var that = this;
//        result.forEach(function(element) {
//            element.key = that.getUuid();
//            var serviceDefaultValue = element.defaultValue;
//            var serviceIsDisabled = element.isDisabled;
//            that.allDeviceServConf = [...that.allDeviceServConf, {
//                key: element.key,
//                defaultValue: serviceDefaultValue,
//                isDisabled: serviceIsDisabled
//            }];
//        });
//    })
//    .catch(error => {
//        this.error = error;
//        console.log(error);
//    });

    handleCheckbox(event){
         let vasKey = event.detail.vasKey;
         let value = event.detail.value;
         const passEvent = new CustomEvent('devicevasselected', {
                 detail:{
                       vasKey:vasKey,
                       value:value,
                       deviceKey:this.itemKey
                   }
             });
             this.dispatchEvent(passEvent);
    }

    getUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
}