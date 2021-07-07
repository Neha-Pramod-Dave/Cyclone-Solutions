/*********************************************************************************************************
FileName    : createWidgetRecordComponent.js
Description : Javascript Controller to handle the client side operations such as input validations &
              record submittion.
Author      : Neha Dave

Version History :
Author      Date         Description
Neha Dave   03-07-2021   Initial draft of batch class.
Neha Dave   03-07-2021   Added Code to display the validate the input values.
Neha Dave   04-07-2021   Added code to display a confirmation window for super users when they try to save a
                         invalid value and submit the record to create a new record in salesforce.
************************************************************************************************************/

import { LightningElement, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchNestingMappingRecords from '@salesforce/apex/WidgetCreationClass.fetchNestingMappingRecords';
import fetchSuperUserDetails from '@salesforce/apex/WidgetCreationClass.fetchSuperUserDetails';
import createWidgetRecord from '@salesforce/apex/WidgetCreationClass.createWidgetRecord';
import widgetValue from '@salesforce/schema/Widget__c.Value__c';

export default class CreateWidgetRecordComponent extends LightningElement {
    @track inputValue;
    @track arrayOpenBrackets = new Map();
    @track arrayCloseBrackets = [];
    @track arrayStringdata = [];
    @track displayConfirmationModal = false;
    @track getWidgetRecord = {
        Value__c : widgetValue,
    };

    //fetch metadata to store the bracket values.
    @wire( fetchNestingMappingRecords )
    wiredRecs( value ) {
        const { data, error } = value;
        if (data) {
            for ( var i = 0; i < data.length; i++ ) {
                this.arrayOpenBrackets.set(data[i].Opening_Bracket__c,data[i].Closing_Bracket__c);
                this.arrayCloseBrackets.push(data[i].Closing_Bracket__c);
            }
        }
    }

    //fetch metadata to check if the current logged in user is a super user.
    @wire( fetchSuperUserDetails )
    wiredRecords( value ) {
        const { data, error } = value;
        console.log(value);
        if (data != null || data != undefined) {
            this.isSuperUser = data;
        }
    }

    //Vaidate and display appropriate message in case of invalid input.
    //Display a confirmation screen if the current logged in user is a super user.
    validateWidget( ) {
        //Get input from screen and split it and store it in an array named arrayStringdata.
        var strVal = this.template.querySelector("lightning-input");
        this.inputValue = strVal.value;
        this.getWidgetRecord.Value__c = strVal.value;
        this.arrayStringdata = this.inputValue.split('');
        var arrayNestedData = [];
        var isValidInput = true;

        if(this.arrayStringdata.length == 0){
            const event = new ShowToastEvent({
                title: 'Wrong Input!',
                message: 'You cannot save a record with empty value. Please enter some text and try again!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }else{
            for( var i = 0; i < this.arrayStringdata.length; i++ ) {
                //Check if Arrayopenbrackets contains the character from arraystringdata.
                if(this.arrayOpenBrackets.has(this.arrayStringdata[i])) {
                //push closing bracket value for relevant openingbracketvalue.
                    arrayNestedData.push(this.arrayOpenBrackets.get(this.arrayStringdata[i]));
                }
                //Check if arrayclosebracket contains the character from arraystringdata
                else if(this.arrayCloseBrackets.includes(this.arrayStringdata[i])) {
                    if(arrayNestedData.length != 0){
                        let strVal = arrayNestedData.pop(arrayNestedData.length-1);
                        if (this.arrayStringdata[i].toString() != strVal) {
                            isValidInput = false;
                            break;
                        }
                    }else{
                        isValidInput = false;
                        break;
                    }
                }
            }

            if(arrayNestedData.length != 0 || !isValidInput) {
                if(!this.isSuperUser) {
                    const event = new ShowToastEvent({
                        title: 'Wrong Input!',
                        message: 'Please check the input value. Some of the brackets are not properly open or closed. Eg. {(abc)}',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                } else {
                    this.displayConfirmationModal = true;
                }
            }else{
                this.submitRecord();
            }
        }
    }

    SaveRecord(){
        this.displayConfirmationModal = false;
        this.submitRecord();
    }

    //Create a new widget record and display appropriate toaster message.
    submitRecord(){
        createWidgetRecord({widObj : this.getWidgetRecord})
        .then(result=>{
            this.getWidgetRecord = {};
            this.widgetId = result.Id;

            const toastEvent = new ShowToastEvent({
              title:'Success!',
              message:'Widget created successfully!',
              variant:'success'
            });
            this.dispatchEvent(toastEvent);
        })
        .catch(error=>{
           this.error=error.message;
           const toastEvent = new ShowToastEvent({
            title:'Error!',
            message: 'There was an error saving this record. Please contact your System Administrator!',
            variant:'error'
          });
          this.dispatchEvent(toastEvent);
        });

        this.allowReset();
    }

    //Reset the input fields after record submittion.
    allowReset() {
        const inputFields = this.template.querySelectorAll('lightning-input');
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = '';
            });
        }
     }

    closeModal() {
        this.displayConfirmationModal = false;
    }
}