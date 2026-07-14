/**
 * Created by JurgitaG on 12/22/2021.
 */

import { LightningElement, api, track } from 'lwc';

export default class DealDeviceVasConfig extends LightningElement {
    @api deviceLineId;
    @api metadataId;
    @api objectApiName ='Deal_Line__c';
    @track configStep = "1";
    @api configurationFields = '';

    fields =[
        'MoretymeType__c',
        'GiftLoyaltyPaymentType__c',
        'CardDesignType__c'
    ]
    connectedCallback() {
       this.fields = this.configurationFields.split(",");
    }

    onBundleClosed(){
         const passEvent = new CustomEvent('bundleClose', {
             detail:{
                 metadataId:this.metadataSelected,
                 bundleId: this.bundleId,
             }
         });
         this.dispatchEvent(passEvent);
     }

     onBundleBack(event){
         console.log(event);
         const passEvent = new CustomEvent('bundleback', {
             detail:{
                    configStep:"2",
                }
         });
         this.dispatchEvent(passEvent);
     }

     onServiceSubmit(event){
          console.log(event);


          const passEvent = new CustomEvent('bundleforward', {
             detail:{
                   configStep:"4",
               }
          });
          this.dispatchEvent(passEvent);
      }
}