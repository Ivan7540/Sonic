/**
 * Created by JurgitaG on 5/10/2021.
 */

import { LightningElement, track, wire, api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import checkIfCalculated from '@salesforce/apex/QuoteCalculationController.checkIfCalculationIsFinished';



export default class QuoteCalculation extends LightningElement {
    @track calculationDone = false;
    @api quoteId;
    @api dateSubmitted;
    @track progress = 1000;

    connectedCallback() {

        this._interval = setInterval(() => {
              this.checkIfQuoteCalculated();
              if ( this.calculationDone ) {
                  clearInterval(this._interval);
              }
          }, this.progress);

        }
        checkIfQuoteCalculated() {
                 checkIfCalculated({ quoteId: this.quoteId, dateSubmitted: this.dateSubmitted })
                     .then(result => {
                         this.calculationDone = result;
                         console.log(result);
                     })
                     .catch(error => {
                         this.error = error;
                         console.log(error);
                     });
                 }

    handleGoNext() {
        var navigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigationEvent);
    }
}