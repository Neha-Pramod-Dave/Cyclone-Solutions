/***********************************************************************************************************
ClassName   : WidgetCreationClassTest
Description : Test Class to verrify the functional & technical implementation of createWidgetComponent server
              side - WidgetCreationClass class.
Author      : Neha Dave

Version History :
Author      Date         Description
Neha Dave   05-07-2021   Initial Draft of Test class.
Neha Dave   05-07-2021   Added methods to verify the functional & technical implementation of
                         WidgetCreationClass class.
************************************************************************************************************/
@isTest
public with sharing class WidgetCreationClassTest {

    // String values that are common within the class are refered using the below Static String variables.
    public static final string WIDGET_CREATED = 'Widget record is created.';
    public static final string METADATA_LIST_MUST_BE_EQUAL = 'The list size must be equal.';

    /*********************************************************************************************************
     Method Name : verifyCustomMetdataTest
     Description : Method to verify whether the custom metdata records is accessible to all the users.
          Author : Neha Dave
    **********************************************************************************************************/
    @isTest
    public static void verifyCustomMetdataTest(){
        User userExecutive = TestDataFactory.createUser(Constants.WIDGET_EXECUTIVE_USER,Constants.WIDGET_EXECUTIVE_USER);
        User userMaster = TestDataFactory.createUser(Constants.WIDGET_MASTER_USER,Constants.WIDGET_MASTER_USER);
        List<String_Nesting_Mapping__mdt> getMetadataExecutive = new List<String_Nesting_Mapping__mdt>();
        List<String_Nesting_Mapping__mdt> getMetadataMaster = new List<String_Nesting_Mapping__mdt>();
        List<String_Nesting_Mapping__mdt> nestingMappingList = [ SELECT Id
                                                                      , MasterLabel
                                                                      , Closing_Bracket__c
                                                                      , Opening_Bracket__c
                                                                   FROM String_Nesting_Mapping__mdt
                                                               ];

        System.Test.StartTest();
        System.RunAs(userExecutive){
           getMetadataExecutive = WidgetCreationClass.fetchNestingMappingRecords();
        }

        System.RunAs(userMaster){
           getMetadataMaster = WidgetCreationClass.fetchNestingMappingRecords();
        }
        System.Test.StopTest();

        System.assertEquals(nestingMappingList.size(), getMetadataExecutive.size(), METADATA_LIST_MUST_BE_EQUAL);
        System.assertEquals(nestingMappingList.size(), getMetadataMaster.size(), METADATA_LIST_MUST_BE_EQUAL);

        for(String_Nesting_Mapping__mdt nestingObj : nestingMappingList){
            System.assert(getMetadataExecutive.contains(nestingObj),true);
            System.assert(getMetadataMaster.contains(nestingObj),true);
        }
    }

    /*********************************************************************************************************
     Method Name : verifySuperUserTest
     Description : Method to verify whether the current logged in user is a super user.
          Author : Neha Dave
    **********************************************************************************************************/
    @isTest
    public static void verifySuperUserTest(){
        User userExecutive = TestDataFactory.createUser(Constants.WIDGET_EXECUTIVE_USER,Constants.WIDGET_EXECUTIVE_USER);
        User userMaster = TestDataFactory.createUser(Constants.WIDGET_MASTER_USER,Constants.WIDGET_MASTER_USER);
        Boolean isExecutiveSuperUser;
        Boolean isMasterSuperUser;

        System.Test.StartTest();
        System.RunAs(userMaster){
            TestDataFactory.createSuperUserCustomSetting();
        }

        System.RunAs(userExecutive){
            isExecutiveSuperUser = WidgetCreationClass.fetchSuperUserDetails();
        }

        System.RunAs(userMaster){
            isMasterSuperUser = WidgetCreationClass.fetchSuperUserDetails();
        }
        System.Test.StopTest();

        System.assertEquals(false, isExecutiveSuperUser, 'Widget Executive is not a Super User.');
        System.assertEquals(true, isMasterSuperUser, 'Widget Master is a Super User.');
    }

    /*********************************************************************************************************
     Method Name : createWidgetRecordTest
     Description : Method to verify whether the widget record is created.
          Author : Neha Dave
    **********************************************************************************************************/
    @isTest
    public static void createWidgetRecordTest(){
        User userExecutive = TestDataFactory.createUser(Constants.WIDGET_EXECUTIVE_USER,Constants.WIDGET_EXECUTIVE_USER);
        User userMaster = TestDataFactory.createUser(Constants.WIDGET_MASTER_USER,Constants.WIDGET_MASTER_USER);
        Widget__c widInsertExecObj = new Widget__c();
        widInsertExecObj.Value__c = '(abc)';

        Widget__c widInserMastertObj = new Widget__c();
        widInserMastertObj.Value__c = '(abc)';

        Widget__c widExecObj = new Widget__c();
        Widget__c widMasterObj = new Widget__c();

        System.Test.StartTest();
        System.RunAs(userExecutive){
            widExecObj = WidgetCreationClass.createWidgetRecord(widInsertExecObj);
        }

        System.RunAs(userMaster){
            widMasterObj = WidgetCreationClass.createWidgetRecord(widInserMastertObj);
        }
        System.Test.StopTest();

        System.assertEquals(true, widExecObj != null, WIDGET_CREATED);
        System.assertEquals(true, widMasterObj != null, WIDGET_CREATED);
    }
}