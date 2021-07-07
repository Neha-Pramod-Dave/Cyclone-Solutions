/*********************************************************************************************************
ClassName   : TestDataFactory
Description : Class to create dummy records for test classes.
Author      : Neha Dave

Version History :
Author      Date         Description
Neha Dave   05-07-2021   Initial Draft of TestDataFactory class.
Neha Dave   05-07-2021   Added method to create widget records & required users.
**********************************************************************************************************/
public with sharing class TestDataFactory {

    /*****************************************************************************************************
     Method Name : createWidgetRecords
     Description : Method to create dummy test records for widgets based on the parameter count passed to
                   the method.
          Author : Neha Dave
    ******************************************************************************************************/
    public static List<Widget__c> createWidgetRecords(Integer recordCount){
        List<Widget__c> widgetList = new List<Widget__c>();
            for(Integer i=0; i<recordCount; i++){
                Widget__c objWidget = new Widget__c();
                objWidget.Value__c = '{(abc)}';
                widgetList.add(objWidget);
            }
        return widgetList;
    }

    /*****************************************************************************************************
     Method Name : createUser
     Description : Method to create dummy test user records to test the real scenarios based on various
                   users.
          Author : Neha Dave
    ******************************************************************************************************/
    public static User createUser(String ProfileName, String RoleName){
        UserRole role = new UserRole(Name = RoleName);
        if(role != null){
            insert role;
        }

        User objUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :ProfileName].Id,
            FirstName = 'Test',
            LastName = ProfileName,
            Email = 'test.User@cyclonesolutions.com',
            Username = 'test.User@cyclonesolutions.com' + System.currentTimeMillis(),
            CompanyName = 'Cyclone Solutions',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = role.Id
        );

        if(objUser != null){
            insert objUser;
        }

        return objUser;
    }

    /*****************************************************************************************************
     Method Name : createSuperUserCustomSetting
     Description : Method to create dummy custom setting records to test the real scenarios based on various
                   users.
          Author : Neha Dave
    ******************************************************************************************************/
    public static void createSuperUserCustomSetting(){
        List<Super_Users__c> superUsers = new List<Super_Users__c>();
        Super_Users__c superUserExeObj = new Super_Users__c();
        superUserExeObj.SetupOwnerId  = [SELECT Id FROM Profile WHERE Name = :Constants.WIDGET_EXECUTIVE_USER].Id;
        superUserExeObj.Save_Invalid_Widgets__c = false;
        superUsers.add(superUserExeObj);

        Super_Users__c superUserMasterObj = new Super_Users__c();
        superUserMasterObj.SetupOwnerId  = [SELECT Id FROM Profile WHERE Name = :Constants.WIDGET_MASTER_USER].Id;
        superUserMasterObj.Save_Invalid_Widgets__c = true;
        superUsers.add(superUserMasterObj);

        if(!superUsers.isEmpty()){
            insert superUsers;
        }
    }
}