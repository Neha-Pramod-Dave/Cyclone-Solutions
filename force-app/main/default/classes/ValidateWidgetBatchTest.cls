/***********************************************************************************************************
ClassName   : ValidateWidgetBatchTest
Description : Test Class to verrify the functional & technical implementation of ValidateWidgetBatch class.
Author      : Neha Dave

Version History :
Author      Date         Description
Neha Dave   05-07-2021   Initial Draft of Test class.
Neha Dave   05-07-2021   Added methods to verify the functional & technical implementation of
                         ValidateWidgetBatch class.
************************************************************************************************************/
@isTest
public with sharing class ValidateWidgetBatchTest {

    // String values that are common within the class are refered using the below Static String variables.
    public static final string IS_NEW_WIDGET_MARKED_FALSE = 'The Is_New__c should be unchecked if the widget '
        +'record is processed in the batch.';

    /*********************************************************************************************************
     Method Name : validateWidgetRecords
     Description : Method to verify whether the valid records are marked as properly nested by creating Widget
                   Executives & Widget Masters to create records.
          Author : Neha Dave
    **********************************************************************************************************/
    @isTest
    public static void validateWidgetRecords(){
        Integer recordCount = 100;
        List<Widget__c> newWidgetListExecutive = TestDataFactory.createWidgetRecords(recordCount);
        User userExecutive = TestDataFactory.createUser(Constants.WIDGET_EXECUTIVE_USER,Constants.WIDGET_EXECUTIVE_USER);
        System.RunAs(userExecutive){
            insert newWidgetListExecutive;
        }

        List<Widget__c> newWidgetListMaster = TestDataFactory.createWidgetRecords(recordCount);
        User userMaster = TestDataFactory.createUser(Constants.WIDGET_MASTER_USER,Constants.WIDGET_MASTER_USER);
        System.RunAs(userMaster){
            insert newWidgetListMaster;
        }

        System.Test.startTest();
            ValidateWidgetBatch batchObj = new ValidateWidgetBatch();
            database.executebatch(batchObj,Integer.valueOf(System.label.Batch_Size));
        System.Test.stopTest();

        List<Widget__c> updatedWidgetList = [SELECT Id
                                                 , Name
                                                 , Value__c
                                                 , Is_Properly_Nested__c
                                                 , Is_New__c
                                              FROM Widget__c
                                             WHERE Is_Properly_Nested__c = true
                                               AND Is_New__c = false];

        System.AssertEquals(200, updatedWidgetList.size(), 'The record count returned by query '+
            'should be same as the number of valid records that were created.');
        for(Widget__c objWidget :updatedWidgetList){
            System.AssertEquals(true, objWidget.Is_Properly_Nested__c, 'The Is_Properly_Nested__c '+
                'should be checked if the widget record is valid');
            System.AssertEquals(false, objWidget.Is_New__c,IS_NEW_WIDGET_MARKED_FALSE);
        }
    }

    /*****************************************************************************************************
     Method Name : invalidateWidgetRecords
     Description : Method to verify whether the valid records are marked as false. The records are created
                   using Widget Executives & Widget Masters to test actual scenarios.
          Author : Neha Dave
    ******************************************************************************************************/
    @isTest
    public static void invalidateWidgetRecords(){
        Integer recordCount = 100;
        List<Widget__c> newWidgetList = TestDataFactory.createWidgetRecords(recordCount);

        for(Widget__c objWidget :newWidgetList){
            objWidget.Value__c = '(ABC)}(){}{}{})';
        }
        User userExecutive = TestDataFactory.createUser(Constants.WIDGET_EXECUTIVE_USER,Constants.WIDGET_EXECUTIVE_USER);
        System.RunAs(userExecutive){
            insert newWidgetList;
        }

        List<Widget__c> newWidgetListMaster = TestDataFactory.createWidgetRecords(recordCount);
        for(Widget__c objWidget :newWidgetList){
            objWidget.Value__c = '(';
        }
        User userMaster = TestDataFactory.createUser(Constants.WIDGET_MASTER_USER,Constants.WIDGET_MASTER_USER);
        System.RunAs(userMaster){
            insert newWidgetListMaster;
        }

        System.Test.startTest();
            ValidateWidgetBatch batchObj = new ValidateWidgetBatch();
            database.executebatch(batchObj,Integer.valueOf(System.label.Batch_Size));
        System.Test.stopTest();

        List<Widget__c> updatedWidgetList = [SELECT Id
                                                 , Name
                                                 , Value__c
                                                 , Is_Properly_Nested__c
                                                 , Is_New__c
                                              FROM Widget__c
                                             WHERE Is_Properly_Nested__c = true
                                               AND Is_New__c = false];

        System.AssertEquals(0, updatedWidgetList.size(), 'The record count returned by query should be 0 as'+
        'all the invalid test records were created.');

        for(Widget__c objWidget :updatedWidgetList){
            System.AssertEquals(false, objWidget.Is_Properly_Nested__c, 'The Is_Properly_Nested__c should be'+
                'unchecked if the widget record is invalid');
            System.AssertEquals(false, objWidget.Is_New__c, IS_NEW_WIDGET_MARKED_FALSE);
        }
    }
}