/**
 * Created by JurgitaG on 6/6/2021.
 */

import {api, LightningElement} from 'lwc';

export default class RebateLineItem extends LightningElement {
    @api availableOptions = [];
    @api recordId;
    @api rebatedItem;
    @api rebateQuantity = null;
    @api rebateMonths = null;
    @api rebateDiscount = null;
    @api rebateAmount = null;
    @api rebateMotivation = null;
    @api rebateReason = null;
    @api discount = null;
    @api discountAmount = null;
    @api bundleId;
    @api itemKey;
    @api selectedOption;
    @api selectedOptionLabel;
    @api maxQuantity;

    @api rebatedProduct;
    @api disableQuantity = false;
    @api disableMonths = false;
    @api disableDiscount = false;
    @api disableAmount = false;
    @api disableRebateDiscount = false;
    @api disableRebateAmount = false;


    handleRebate(event) {
        this.selectedOption = event.target.value;
        this.selectedOptionLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.onProductSelect();
    }
    onFieldChange() {
        const passEventr = new CustomEvent('fieldchange', {
            detail: {
                rebateQuantity: this.rebateQuantity,
                rebateMonths: this.rebateMonths,
                rebateDiscount: this.rebateDiscount,
                rebateAmount: this.rebateAmount,
                rebateMotivation: this.rebateMotivation,
                rebateReason: this.rebateReason,
                discount: this.discount,
                discountAmount: this.discountAmount,
                key: this.itemKey
            }
        });
        this.dispatchEvent(passEventr);
    }

    onProductSelect() {
        const passEventr = new CustomEvent('refreshoptions', {
            detail: {
                selected: this.selectedOption,
                selectedLabel: this.selectedOptionLabel,
                key: this.itemKey,
                rebateQuantity: this.rebateQuantity,
                rebateMonths: this.rebateMonths,
                rebateDiscount: this.rebateDiscount,
                rebateAmount: this.rebateAmount,
                rebateMotivation: this.rebateMotivation,
                rebateReason: this.rebateReason,
                discount: this.discount,
                discountAmount: this.discountAmount,

            }
        });
        this.dispatchEvent(passEventr);
    }

    onRebateDelete() {
        const passEventr = new CustomEvent('deleteline', {
            detail: {key: this.itemKey}
        });
        this.dispatchEvent(passEventr);
    }

    handleDelete() {
        this.onRebateDelete();
    }

    handleQuantity(event) {
        let finalValue = event.target.value;
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
        }
        this.rebateQuantity = finalValue;
        this.onFieldChange();
    }

    handleRebateDiscount(event) {
        let finalValue = event.target.value;
        console.log(event.target.value);
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
            this.disableRebateAmount = true;
            this.rebateAmount = 0;

        }
        if (isNaN(finalValue)) {
            this.disableRebateAmount = false;
        }
        this.rebateDiscount = finalValue;
        this.onFieldChange();
    }

    handleDiscount(event) {
        let finalValue = event.target.value;
        console.log(event.target);
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
            this.disableAmount = true;
            this.discountAmount = 0;
        }
        if (isNaN(finalValue)) {
            this.disableAmount = false;
        }
        this.discount = finalValue;
        this.onFieldChange();
    }

    handleRebateAmount(event) {
        let finalValue = event.target.value;
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
            this.disableRebateDiscount = true;
            this.rebateDiscount = 0;
        }
        if (isNaN(finalValue)) {
            this.disableRebateDiscount = false;
        }
        this.rebateAmount = finalValue;
        this.onFieldChange();

    }

    handleDiscountAmount(event) {
        let finalValue = event.target.value;
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
            this.disableDiscount = true;
            this.discount = 0;
        }
        console.log(finalValue);
        if (isNaN(finalValue)) {
            this.disableDiscount = false;

        }

        this.discountAmount = finalValue;
        this.onFieldChange();

    }

    handleMonths(event) {
        let finalValue = event.target.value;
        console.log(event.target);
        if (this.isNumeric(finalValue)) {
            finalValue = parseFloat(finalValue);
        }

        this.rebateMonths = finalValue;
        if (finalValue == 6) {
            this.rebateDiscount = 100;
            this.disableAmount = true;
            this.rebateAmount = 0;


        }
        this.onFieldChange();
    }

    handleMotivation(event) {
        this.rebateMotivation = event.target.value;
        this.onFieldChange();
    }

    handleRebateReason(event) {
        this.rebateReason = event.target.value;
        this.onFieldChange();
    }

    isInt(n) {
        return Number(n) === n && n % 1 === 0;
    }

    isFloat(n) {
        return Number(n) === n && n % 1 !== 0;
    }

    isNumeric(num) {
        return !isNaN(num)
    }

}