/*
Date created: 07/06/2021
Developer: Ivan Vrtacnik
JIRA number: PS-569
*/
global class IncludeAttachmentController 
{
    global String PageContents{get; set;}
    global String workOrderObjectId{get; 
        set 
        {
            UpdateContents(value);
        } 
    }

    public void UpdateContents(String workOrderObjectId) 
    {
        try 
        {
            PageReference pageRef = Page.VF_WorkOrder;
            pageRef.getParameters().put('workOrderId', workOrderObjectId);
        
            PageContents = pageRef.getContent().toString().replace('<html style="display:none !important;">', '<html>');
        } 
        catch(exception ex) 
        { 
            PageContents = 'An error has occurred while trying to generate this work order.';
        }
    }
}