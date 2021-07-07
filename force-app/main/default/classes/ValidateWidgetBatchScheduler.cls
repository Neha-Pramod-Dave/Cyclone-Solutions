/*********************************************************************************************************
ClassName   : ValidateWidgetBatchScheduler
Description : Scheduler Class to schedule the ValidateWidgetBatch class on an hourly basis daily.
Author      : Neha Dave

Version History :
Author      Date         Description
Neha Dave   05-07-2021   Initial Draft of scheduler class.
Neha Dave   05-07-2021   Added methods to schedule the ValidateWidgetBatch class on an hourly basis daily.
**********************************************************************************************************/
public with sharing class ValidateWidgetBatchScheduler implements Schedulable{

    /*************************************************************************
     Method Name : scheduledBatchable
     Description : Method to to schedule the ValidateWidgetBatch class on an
                   hourly basis daily.
          Author : Neha Dave
    **************************************************************************/
    public void execute(SchedulableContext sc) {
        ValidateWidgetBatch batchObj = new ValidateWidgetBatch();
        database.executebatch(batchObj,Integer.valueOf(System.label.Batch_Size));
    }

}