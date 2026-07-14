/**
 * Created by JurgitaG on 6/25/2021.
 */

import { LightningElement, api, track } from 'lwc';
import getDealId from '@salesforce/apex/DealApprovalInfoController.getDealId';
import getDealRates from '@salesforce/apex/DealApprovalInfoController.getDealRates';
import getDealProducts from '@salesforce/apex/DealApprovalInfoController.getDealRebates';
import getDealBundles from '@salesforce/apex/DealApprovalInfoController.getDealBundles';

const rateColumns = [
    { label: 'Rate', fieldName: 'product', type: 'text' },
    { label: 'Rate Percentage', fieldName: 'ratePercentage', type: 'number' },
    { label: 'Transaction Fee', fieldName: 'transactionFee', type: 'currency' },
    { label: 'Card Split', fieldName: 'cardSplit', type: 'number' }
];

export default class DealApprovalInfo extends LightningElement {

  isLoading = false;
  rateColumns = rateColumns;
  @api recordId; //approval process Id
  @track dealId;
  @track dealRates;
  @track dealProducts;
  @track dealBundles;
  error;

  allowMultipleSectionsOpen;

  connectedCallback() {
    this.isLoading = true;
    this.loadDealDetails()
      .catch(error => console.error(this.error = error))
      .finally(() => this.isLoading = false);
  }

  async loadDealDetails() {
    this.isLoading = true;
    const processId = this.recordId;
    this.dealRates = await getDealRates({ processId });
    this.dealProducts = await getDealProducts({ processId });
    this.dealBundles = await getDealBundles({ processId });
    console.log({
      dealRates: this.dealRates,
      dealProducts: this.dealProducts,
      dealBundles: this.dealBundles
    });
  }

  get shouldShowData() {
    return !this.error && !this.isLoading;
  }

  get rateLineColumns() {
    return [
      { label: 'Rebate Item', fieldName: 'rebateItem', type: 'text', hideDefaultActions: true },
      { label: 'Quantity', fieldName: 'rebatedQuantity', type: 'number' , hideDefaultActions: true},
      { label: 'Months', fieldName: 'rebateMonths', type: 'number', hideDefaultActions: true },
      { label: 'Rebate (%)', fieldName: 'rebateDiscountPercentage', type: 'percent', hideDefaultActions: true },
      { label: 'Rebate (R)', fieldName: 'rebateDiscountAmount', type: 'currency', hideDefaultActions: true },
      { label: 'Reason', fieldName: 'rebateReason', type: 'text', hideDefaultActions: true },
      { label: 'Motivation', fieldName: 'rebateMotivation', type: 'text', hideDefaultActions: true },
      { label: 'Discount (%)', fieldName: 'lineDiscount', type: 'percent', hideDefaultActions: true },
      { label: 'Discount (R)', fieldName: 'lineDiscountAmount', type: 'currency', hideDefaultActions: true },
    ]
  }
}