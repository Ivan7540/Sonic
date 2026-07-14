/**
 * Created by ViktorijaR on 12/21/2021.
 */

import { LightningElement, api } from 'lwc';

export default class DealServiceCheckbox extends LightningElement {

    @api recordId;
    @api itemKey;
    @api metadataId;
    @api isDisabled;
    @api value;

    connectedCallback() {

    }

//    getDeviceServiceConfig 

    getUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    handleCheckbox(event){

        const passEvent = new CustomEvent('vasselected', {
                    detail:{
                          vasKey:this.itemKey,
                          value:event.target.checked
                      }
                });
                this.dispatchEvent(passEvent);
    }

}