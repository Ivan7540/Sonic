import { LightningElement, track, api} from 'lwc';

export default class RebateModal extends LightningElement {
     @track isModalOpen = false;
     @track readOnly = false;
    @api productItem={
             RebatedProduct__c: null,
             RebatedQuantity__c: null,
             RebateMonths__c: null,
             RebateDiscountPercentage__c: null ,
             RebateDiscountAmount__c: null,
         } ;

    @api
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
        handleChange(event) {
    //        this[event.target.name] = event.target.value;

               var finalValue = event.target.value;
               console.log(event.target);
               if(this.isNumeric(finalValue)){
                    finalValue =parseFloat(finalValue);
               }

                  this.productItem[event.target.fieldName] = finalValue;
                  if(finalValue == 'SS_INSTALL_TRAINING_FEE'){
                this.productItem.RebatedQuantity__c = 1;
                this.productItem.RebateMonths__c = 1;
                this.productItem.RebateDiscountPercentage__c = 100;
                this.productItem.RebateDiscountAmount__c = 0;
                this.readOnly = true;
                }

        }
            handleQuantity(event) {
        //        this[event.target.name] = event.target.value;
                                      var finalValue = event.target.value;

                   if(this.isNumeric(finalValue)){
                        finalValue =parseFloat(finalValue);
                   }
                    this.productItem[event.target.fieldName] = finalValue;


            }
            handleDiscount(event) {
        //        this[event.target.name] = event.target.value;
                   var finalValue = event.target.value;
                   console.log(event.target);
                   if(this.isNumeric(finalValue)){
                        finalValue =parseFloat(finalValue);
                   }


                      this.productItem[event.target.fieldName] = finalValue;


            }
            handleDiscountAmount(event) {
        //        this[event.target.name] = event.target.value;
                   var finalValue = event.target.value;
                   console.log(event.target);
                   if(this.isNumeric(finalValue)){
                        finalValue =parseFloat(finalValue);
                   }

                   this.productItem[event.target.fieldName] = finalValue;

            }
            isNumeric(num){
                  return !isNaN(num)
                }
            submitDetails() {
                    // to close modal set isModalOpen tarck value as false
                    //Add your code to call apex method or do some processing


                     console.log(this.productItem);

                    this.isModalOpen = false;
                    this.onProductSave();
                }

                onProductSave(){
                   const passEventr = new CustomEvent('addrebateevent', {
                     detail: { productItem: this.productItem }
                    });
                    this.dispatchEvent(passEventr);
                  }

}