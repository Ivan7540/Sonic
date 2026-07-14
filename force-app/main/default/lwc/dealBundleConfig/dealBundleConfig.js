/**
 * Created by JurgitaG on 12/6/2021.
 */

import { LightningElement, api, track } from 'lwc';

export default class DealBundleConfig extends LightningElement {
    @api recordId;
    @api bundleId;
    @api configurationFields;
    @track selectedMetadataId;
    @track configStep = "1";
    @api objectApiName ='Deal_Line__c'

    @api showEditor;

//    @track bundleId;

     handleBundleSaved(event) {
         console.log(event.detail.metadataId);
         console.log(event.detail.bundleId);
         this.selectedMetadataId = event.detail.metadataId;
         this.bundleId = event.detail.bundleId;
         this.configStep = "2";
         console.log('ciaa 2');
     }
     handleOptionSaved(event){
         this.configStep = event.detail.configStep;
     }
     handleNavigation(event){
         this.configStep = event.detail.configStep;
     }
     handleServiceSaved(event){
         console.log('c');
         this.configStep = event.detail.configStep;
         this.configurationFields = event.detail.configurationFields;
     }

     get isProductSelection() { return (this.configStep == "1");}
     get isOptionSelection() { return (this.configStep == "2");}
     get isServiceConfig() { return (this.configStep == "3");}
     get isDiscountSelection() { return (this.configStep == "4");}

     onBundleClosed(){
         const passEvent = new CustomEvent('bundleclose', {
             detail:{
                 metadataId:this.metadataSelected,
                 bundleId: this.bundleId,
             }
         });
         this.dispatchEvent(passEvent);
     }

     onBundleBack(event){
         console.log(event);
         console.log('event back');
         const passEvent = new CustomEvent('bundleBack', {
//                      detail:{
//                          configStep:"2",
//                      }
                  });
         this.dispatchEvent(passEvent);
         console.log(this.configStep);
         console.log('step 2');
         this.configStep = "3";
     }
}