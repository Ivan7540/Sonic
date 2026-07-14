/*
Date created: 07/06/2021
Developer: Ivan Vrtacnik
JIRA number: PS-569
*/
public class WorkOrderController 
{
    public Id workOrderId {get; set;}
    public WorkOrder__c workOrder {get; set;}
    public String arrivalTime {get; set;}
    public String departTime {get; set;}
    public Integer machineCounter {get; set;}
    public Integer modemCounter {get; set;}

    public WorkOrderController()
    {
        workOrderId = ApexPages.currentPage().getParameters().get('workOrderId');

        if(workOrderId != null && workOrder == null)
        {
            workOrder = getWorkOrder();
            setTimes();
        }
    }

    private WorkOrder__c getWorkOrder()
    {
        return
        [
            SELECT  Id,
                    Name,
                    Owner.Name,
                    Account__r.Name,
                    Account__r.ShippingStreet,
                    Account__r.ShippingCity,
                    Account__r.ShippingCountry,
                    Account__r.ShippingPostalCode,
                    Account__r.DebtorCode__c,
                    Contact__r.Name,
                    Contact__r.Phone,
                    Contact__r.MobilePhone,
                    Contact__r.Email,
                    ProductFamily__c,
                    Type__c,
                    AppointmentDate__c,
                    Technician__c,
                    Technician__r.Name
            FROM WorkOrder__c
            WHERE Id = :workOrderId
            LIMIT 1
        ];
    }

    public String getMerchantAddress()
    {
        if(workOrder != null)
        {
            String addressTemplate = '{0}, {1}, {2}, {3}';
            String[] shippingAddressComp =  new String[]{workOrder.Account__r.ShippingStreet, 
                                    workOrder.Account__r.ShippingCity,
                                    workOrder.Account__r.ShippingCountry,
                                    workOrder.Account__r.ShippingPostalCode};
            return String.format(addressTemplate, shippingAddressComp);
        }
        else 
        {
            return null;
        }                
    }

    public List<Asset> getInstalledStock()
    {
        List<WorkOrderLineItem__c> lines =
        [
            SELECT  Id,
                    Asset__c,
                    Asset__r.AssignedStock__r.Component__c
            FROM WorkOrderLineItem__c
            WHERE WorkOrder__c = :workOrderId
        ];

        Set<Id> assetIds = new Set<Id>();

        for(WorkOrderLineItem__c line :lines)
        {
            assetIds.add(line.Asset__c);

            if(line.Asset__r.AssignedStock__r.Component__c == 'Modem')
            {
                if(modemCounter == null)
                {
                    modemCounter = 1;
                }
                else 
                {
                    modemCounter++;
                }
            }

            if(line.Asset__r.AssignedStock__r.Component__c == 'Machine')
            {
                if(machineCounter == null)
                {
                    machineCounter = 1;
                }
                else 
                {
                    machineCounter++;
                }
            }
        }

        return
        [
            SELECT  Id,
                    SerialNumber,
                    AssignedStock__r.Name,
                    AssignedStock__r.Model__c,
                    AssignedStock__r.Component__c,
                    AssignedStock__r.Serial_Number__c,
                    AssignedStock__r.Status__c
            FROM Asset
            WHERE Id IN :assetIds
        ];
    }

    private void setTimes()
    {        
        String checkIn = 'Check-in at merchant';
        String complete = 'Complete Work Order';
        List<String> actionNames = new List<String>{checkIn, complete};

        List<WorkOrderAction__c> actions = 
        [
            SELECT  Id,
                    Name,
                    Complete__c,
                    TimeCompleted__c
            FROM WorkOrderAction__c
            WHERE WorkOrder__c = :workOrderId
            AND Name IN :actionNames
            AND TimeCompleted__c != null
            ORDER BY LastModifiedDate ASC
        ];

        for(WorkOrderAction__c action :actions)
        {
            if(action.Name == checkIn && arrivalTime == null)
            {
                arrivalTime = timeText(action.TimeCompleted__c.time());
            }

            if(action.Name == complete && departTime == null)
            {
                departTime = timeText(action.TimeCompleted__c.time());
            }
        }

        // Due to order of execution, the completed time on 
        // the Complete action will only be set after the email
        // is sent. We use the fact that email is sent at the
        // same time as the action completion to work around this
        if(departTime == null)
        {
            departTime = timeText(Datetime.now().time()); 
        }
    }

    private String timeText(Time timeObj)
    {
        String timeTemplate = '{0}:{1}';
        String[] args = new String[]{String.valueOf(timeObj.hour()), String.valueOf(timeObj.minute())};
        return String.format(timeTemplate, args);
    }
}