/***********************************************************************************************
ClassName   : WidgetCreationClass
Description : Class for performing server-side actions for createWidgetRecordComponent.
Author      : Neha Dave

Version History :
Author      Date         Description
Neha Dave   04-07-2021   Initial Draft of controller class.
Neha Dave   04-07-2021   Added method to fetch Metadata & create widget records.
************************************************************************************************/
public with sharing class WidgetCreationClass {


    /*************************************************************************
     Method Name : fetchNestingMappingRecords
     Description : Method to fetch String_Nesting_Mapping__mdt and return list
                   to the Js controller of createWidgetRecordComponent.
          Author : Neha Dave
    **************************************************************************/
    @AuraEnabled( cacheable=true )
    public static List <String_Nesting_Mapping__mdt> fetchNestingMappingRecords() {
        return [ SELECT Id
                      , MasterLabel
                      , Closing_Bracket__c
                      , Opening_Bracket__c
                  FROM String_Nesting_Mapping__mdt
                ];
    }

    /*************************************************************************
     Method Name : fetchSuperUserDetails
     Description : Method to check if the current user is a super user.
          Author : Neha Dave
    **************************************************************************/
    @AuraEnabled( cacheable=true )
    public static Boolean fetchSuperUserDetails() {
        return Super_Users__c.getinstance().Save_Invalid_Widgets__c;
    }

    /*************************************************************************
     Method Name : createWidgetRecord
     Description : Method to create Widget record.
          Author : Neha Dave
    **************************************************************************/
    @AuraEnabled
    public static Widget__c createWidgetRecord(Widget__c widObj){
        System.debug('createWidgetRecord'+widObj);
        try {
            insert widObj;
            return widObj;
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }

}