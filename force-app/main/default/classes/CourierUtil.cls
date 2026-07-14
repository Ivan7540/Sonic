/*
Date created: 29/09/2021
Developer: Ivan Vrtacnik
JIRA number: PS-1025
*/
global class CourierUtil 
{
    public static final String CIT_NAMESPACE = 'http://citjnb.co.za/citwebservices/';
    private static final String SITE_ID = 'Sureswipe';
    private static final String SUBSCRIBED_SERVICE = 'ONC';
    private static final String WAYBILL_PREFIX = 'WB';

    private static CourierLoginCallout.CITWebServicesSoap loginService = new CourierLoginCallout.CITWebServicesSoap();
    private static CourierTrackingLinkCallout.CITWebServicesSoap linkService = new CourierTrackingLinkCallout.CITWebServicesSoap();
    private static CourierStatusCallout.CITWebServicesSoap statusService = new CourierStatusCallout.CITWebServicesSoap();

    private static Service__mdt credentials
    {
        get 
        {
            if(credentials != null)
            {
                return credentials;
            }
            else
            {
                credentials = getServiceDetails();
                return credentials;
            }
        }
        set;
    }

    private static String token 
    {
        get 
        {
            if(token != null)
            {
                return token;
            }
            else
            {
                token = loginService.Login(credentials.Username__c, credentials.Password__c);
                return token;
            }
        }
        set;
    }   

    public static Service__mdt getServiceDetails()
    {
        return
        [
            SELECT  Endpoint__c, 
                    Password__c,
                    Username__c,
                    ErrorAddress__c,
                    SendErrorAlerts__c,
                    AccountNumber__c
            FROM Service__mdt
            WHERE DeveloperName = 'CourierIT'
            LIMIT 1
        ];
    }

    public static List<CourierAddressCallout.AddressDetails> getCourierAddresses(String postalCode, String city)
    {
        List<CourierAddressCallout.AddressDetails> addresses = CourierAddressCallout.getAddresses(credentials.Username__c, token, postalCode, postalCode, al.StringUtils.EMPTY, city, al.StringUtils.EMPTY);
        return addresses;
    }

    public static String createInstallationWaybill(CourierAddressCallout.AddressDetails address, WorkOrder__c workOrder)
    {
        String waybill = workOrder.Name.replace('WO-', WAYBILL_PREFIX);

        String collectionRef = CourierInstallationCallout.AddClientWaybillWithCollectionRequest(credentials.Username__c, 
        token, 
        SITE_ID, 
        waybill, 
        credentials.AccountNumber__c,
        workOrder.Account__r.Name, 
        workOrder.Account__r.ShippingStreet, 
        address.SuburbName, 
        address.CityName, 
        address.StreetCode, 
        workOrder.Contact__r.Name, 
        workOrder.Contact__r.Phone, 
        workOrder.Contact__r.MobilePhone, 
        workOrder.Contact__r.Email, 
        al.StringUtils.EMPTY, 
        SUBSCRIBED_SERVICE, 
        al.StringUtils.EMPTY, 
        'N', 
        'N', 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        'N', 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        DateUtil.formatDate(workOrder.AppointmentDate__c, 'dd-MM-yyyy') , 
        workOrder.Description__c);

        return waybill;
    }

    public static String createInstallationWaybill(CourierAddressCallout.AddressDetails address, Order workOrder)
    {
        String waybill = WAYBILL_PREFIX + workOrder.OrderNumber;

        String collectionRef = CourierInstallationCallout.AddClientWaybillWithCollectionRequest(credentials.Username__c, 
        token, 
        SITE_ID, 
        waybill, 
        credentials.AccountNumber__c,
        workOrder.Account.Name, 
        workOrder.Account.ShippingStreet, 
        address.SuburbName, 
        address.CityName, 
        address.StreetCode, 
        workOrder.ShipToContact.Name, 
        workOrder.ShipToContact.Phone, 
        workOrder.ShipToContact.MobilePhone, 
        workOrder.ShipToContact.Email, 
        al.StringUtils.EMPTY, 
        SUBSCRIBED_SERVICE, 
        al.StringUtils.EMPTY, 
        'N', 
        'N', 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        'N', 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        DateUtil.formatDate(workOrder.InstallationDate__c, 'dd-MM-yyyy') , 
        workOrder.Description);

        return waybill;
    }

    public static String createCollectionWaybill(CourierAddressCallout.AddressDetails address, WorkOrder__c workOrder)
    {
        return CourierCollectionCallout.AddClientWaybill(credentials.Username__c, 
        token, 
        SITE_ID, 
        al.StringUtils.EMPTY, 
        credentials.AccountNumber__c, 
        al.StringUtils.EMPTY, 
        workOrder.Account__r.Name, 
        workOrder.Account__r.ShippingStreet, 
        address.SuburbName, 
        address.CityName, 
        address.StreetCode, 
        workOrder.Contact__r.Name, 
        workOrder.Contact__r.Phone, 
        workOrder.Contact__r.MobilePhone, 
        workOrder.Contact__r.Email,
        SUBSCRIBED_SERVICE,  
        al.StringUtils.EMPTY,
        'N', 
        'N',  
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY, 
        al.StringUtils.EMPTY);
    }

    public static String getTrackingLink(String waybill)
    {
        return linkService.GetTrackingLink(credentials.Username__c, token, waybill, credentials.AccountNumber__c);        
    }

    public static String getShipmentStatus(String waybill)
    {
        return statusService.GetTrackingCurrentStatus(credentials.Username__c, token, waybill, credentials.AccountNumber__c);
    }
}