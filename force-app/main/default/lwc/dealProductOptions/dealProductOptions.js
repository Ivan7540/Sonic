/**
 * Created by JurgitaG on 12/6/2021.
 */
import { LightningElement, api, track } from 'lwc';
import getAllVAS from '@salesforce/apex/DealProductController.getAllVAS';
import getDeviceLines from '@salesforce/apex/DealProductController.queryDeviceLines';
import getDeviceServiceConfig from '@salesforce/apex/DealProductController.getDeviceServiceConfig';
import createVasLines from '@salesforce/apex/DealProductController.createVasLines';

export default class DealProductOptions extends LightningElement {
    @api metadataId;
    @api bundleId;
    @api allOptions = [];
    @api allVAS = [];
    @track devices = [];
    @api deviceServiceSettings =[];
    @api items = [];
    @track configStep = "1";
    @track vasSelection=[,];
    @track errorMessage ='';
    @track configurationFields='';

//    devices = [
//        { label: 'Device 1', value: 'device1' },
//        { label: 'Device 2', value: 'device2' },
//    ];

    connectedCallback() {
        console.log(this.metadataId);
        getDeviceLines({
            bundleId:this.bundleId,
            metadataId:this.metadataId
        }).then(result => {
            var that = this;
            result.forEach(function(element) {
                console.log('element');
                console.log(element);
                element.key = that.getUuid();
                var deviceValue = element.lineId;
                var deviceLabel = element.label;
                that.devices = [...that.devices, element];
            });
            this.getDeviceServices();
        })
        .catch(error => {
            this.error = error;
            console.log(error);
        });
    }
    getDeviceServices(){
        let that = this;
        getDeviceServiceConfig({
                    metadataId:this.metadataId
                }).then(result => {
                    result.forEach(function(element) {
                        console.log('element');
                        console.log(element);
                        element.key = that.getUuid();
                        that.deviceServiceSettings = [...that.deviceServiceSettings, element];
                    });
                 })
                .catch(error => {
                    this.error = error;
                    console.log(error);
                });
    }


    getUuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    handleAddRow() {
        this.items = [...this.items, {
            key: this.getUuid()
        }];
        console.log(' After adding Record List ', this.items);
    }

    removeLine(event) {
        const uuid = event.detail.key;
        const index = this.items.findIndex(item => item.key === uuid);
        console.log(index);
        this.items = this.items.filter(item => item.key !== uuid);
        //                this.filterOptions();

        //           this.rebates.splice(index, 1);
    }

    handleSave(event) {
        console.log(JSON.parse(JSON.stringify(this.devices)));
        if (!this.isValidServices()) return;
        createVasLines({
            deviceInfoString: JSON.stringify(this.devices),
            bundleId: this.bundleId
        }).then(result => {
                console.log(result);
                this.configurationFields = result;
                        this.onOptionSaved();

        })
        .catch(error => {
            this.error = error;
            console.log(error);
        });
    }

    onOptionSaved() {
        let configStep ="3";
//        if(this.configurationFields){
//            configStep = "3";
//        } else
//            configStep ="4";
        const passEvent = new CustomEvent('optionsaved', {
            detail:{
                  configStep:configStep,
                  configurationFields:this.configurationFields
              }
        });
        this.dispatchEvent(passEvent);
    }

    onBundleBack(){
        const passEvent = new CustomEvent('bundleback', {
            detail:{
                  configStep:"1",
              }
        });
        this.dispatchEvent(passEvent);
        }

    handleVasSelected(event){
        let deviceKey = event.detail.deviceKey;
        let vasKey = event.detail.vasKey;
        console.log(event.detail.vasKey);
        console.log(this.deviceServiceSettings);
        console.log(JSON.parse(JSON.stringify(this.devices)));

        const deviceIndex = this.devices.findIndex(item => item.key === deviceKey);
        const vasIndex = this.deviceServiceSettings.findIndex(item => item.metadataId === vasKey);

        this.devices[deviceIndex].serviceList[vasIndex].value=event.detail.value;

//                let devicesServiceList =this.devices[deviceIndex].serviceList;
//                if(devicesServiceList[vasIndex].parentApiName){
//                     const vasParentIndex = this.deviceServiceSettings.findIndex(item => item.parentApiName === devicesServiceList[vasIndex].parentApiName);
//                     if(!deviceServiceSettings[vasParentIndex].value){
//                         this.errorMessage = 'Selected Services requires parent service to be selected!';
//                     }
//                }
        console.log(JSON.parse(JSON.stringify(this.devices)));

    }
    handleSelectAll(event){
        const vasKey = event.target.dataset.key;
        const vasIndex = this.deviceServiceSettings.findIndex(item => item.metadataId === vasKey);
        this.devices = this.devices.map(device => {
            let serviceList = [...device.serviceList];
            serviceList[vasIndex] = {
                ...serviceList[vasIndex],
                value: event.target.checked,
                defaultValue: event.target.checked
            }
            return { ...device, serviceList };
        });
    }
    isValidServices(){
        let validSoFar =true;
        this.errorMessage ='';
        for (let deviceKey in this.devices){
            let lineNumber = parseInt(deviceKey) + 1;
            let serviceList = JSON.parse(JSON.stringify(this.devices[deviceKey].serviceList));
              for (let vasKey in serviceList){
                  if(serviceList[vasKey].parentApiName && serviceList[vasKey].value){
                      const vasParentIndex = serviceList.findIndex(item => item.apiName === serviceList[vasKey].parentApiName);
                      if(!serviceList[vasParentIndex].value){
                          validSoFar = false;
                         this.errorMessage += "Error in line "+lineNumber+ "! "+ serviceList[vasParentIndex].name+" is required if "+ serviceList[vasKey].name + " is selected! ";
                      }
                  }
              }

        }
        return validSoFar;
    }
}