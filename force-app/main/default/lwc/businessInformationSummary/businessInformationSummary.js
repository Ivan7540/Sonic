/**
 * Created by JurgitaG on 2/28/2021.
 */

import { LightningElement, api } from 'lwc';

export default class BusinessInformationSummary extends LightningElement {
    @api registrationNumber;
    @api registeredName;
    @api placeOfBusiness;
    @api entityType;
    @api accName;
    @api bank;
    @api branchCode;
    @api accNumber;
    @api accType;
}