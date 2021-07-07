/**********************************************************************************************************
ClassName   : ValidateWidgetBatch
Description : Batch Class to validate the nestings in the Value field present on Widget record and
              mark true if the data is valid or notify the owners regarding the invalid data.
Author      : Neha Dave

Version History :
Author      Date         Description
Neha Dave   01-07-2021   Initial Draft of batch class.
Neha Dave   01-07-2021   Added methods to batch class to validate the nestings in the value field on
                         widget record.
************************************************************************************************************/
public without sharing class ValidateWidgetBatch implements Database.Batchable<sObject>, Database.Stateful{

    public Map<String,List<Widget__c>> invalidValueMap = new Map<String,List<Widget__c>>();

    /*******************************************************************************************************
     Method Name : start
     Description : Method to fetch the new widget records and pass it in chunks to execute method.
          Author : Neha Dave
    ********************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){
       return Database.getQueryLocator(System.Label.WidgetRecordQuery);
    }

    /*******************************************************************************************************
     Method Name : execute
     Description : Method to validate the widget records and mark them as nested properly. Store the invalid
                   records into a variable map and pass it to finish method.
          Author : Neha Dave
    *******************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Widget__c> newWidgetList){

        // Fetch and store String_Nesting_Mapping__mdt into a map, i.e bracket values.
        // Create a map to store open bracket values as key and closing bracket as value.
        Map<String, String> openBracketMap = new Map<String, String>();
        for(String_Nesting_Mapping__mdt mdtObj :String_Nesting_Mapping__mdt.getAll().values()){
            openBracketMap.put(mdtObj.Opening_Bracket__c, mdtObj.Closing_Bracket__c);
        }

        List<String> strbracketList = new List<String>();
        Boolean isValid = true;

        for(Widget__c objWidget :newWidgetList){
            List<String> valueCharList = new List<String>();
            valueCharList = String.isEmpty(objWidget.Value__c) ? null : objWidget.Value__c.split('');

            //Logic to check the balanced nesting in the record value.
            if(valueCharList != null){
                for (String strObj :valueCharList) {
                    if (openBracketMap.containsKey(strObj)) {
                        strbracketList.add(openBracketMap.get(strObj));
                    } else if (openBracketMap.values().contains(strObj)) {
                        String strVal = strbracketList.isEmpty() ? null : strbracketList.remove(strbracketList.size()-1);
                        if (strObj != strVal) {
                            isValid = false;
                            break;
                        }
                    }
                }
            }else{
                isValid = false;
            }

            if(!strbracketList.isEmpty() || !isValid){
                isValid = false;
                if(!invalidValueMap.containsKey(objWidget.Owner.Email)){
                    List<Widget__c> invalidWidgetsList = new List<Widget__c>();
                    invalidWidgetsList.add(objWidget);
                    invalidValueMap.put(objWidget.Owner.Email,invalidWidgetsList);
                }else{
                    invalidValueMap.get(objWidget.Owner.Email).add(objWidget);
                }
            }

            objWidget.Is_Properly_Nested__c = isValid ? true : false;
            objWidget.Is_New__c = false;
        }
        List<Database.SaveResult> results = Database.update(newWidgetList, false);
    }

    /*******************************************************************************************************
     Method Name : finish
     Description : Method to send email to the widget owners with invalid records.
          Author : Neha Dave
    *******************************************************************************************************/
    public void finish(Database.BatchableContext bc){
        Set<String> widgetOwnerlist = new Set<String>();
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        widgetOwnerlist = invalidValueMap.keySet();

        for(String widOwner :widgetOwnerlist){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {widOwner};
            message.setToAddresses(toAddresses);
            message.setSenderDisplayName(System.label.Sender_Display_Name_Cyclone_Solutions);
            message.setReplyTo('no-reply@company.com');
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setSubject(System.Label.Email_Subject);
            String emailBody = System.Label.Html_Template_Cyclone_Solutions;
            Integer intRecordCount = 0;
            for(Widget__c objWid :invalidValueMap.get(widOwner)){
                intRecordCount++;
                emailBody = emailBody.replace('User', objWid.Owner.FirstName);
                emailBody = emailBody + '<p>' + '<b>'+intRecordCount+ '</b>' + '.'
                                      + '<a href=https://abcsolutions23-dev-ed.lightning.force.com/lightning/r/Widget__c/'
                                      + objWid.Id +'/view>'+objWid.Name+'</a></p>';
                message.settargetObjectId(objWid.OwnerId);
            }
            emailBody = emailBody + System.label.Html_Template_Footer_Cyclone_Solutions;
            message.setHtmlBody(emailBody);
            messageList.add(message);
        }

        Messaging.sendEmail(messageList);
    }
}