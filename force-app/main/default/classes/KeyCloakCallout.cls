/*
Date created: 26/03/2021
Developer: Ivan Vrtacnik
JIRA number: PS-143
*/
public class KeyCloakCallout 
{
    public static Boolean resetUser(String email)
    {
        Service__mdt credentials = DAL_ServiceDetails.getServiceDetails('KeyCloak');
        String message = KeyCloakCallout.generateResetJSON(email);
        HttpResponse response = serviceCallout(message, credentials, 'POST', '/forgotpassword');

        if(response.getStatusCode() == 200) 
        {
            return true;
        } 
        else 
        {
            mail (message, response, credentials);
            return false;
        }
    }

    public static Boolean createUser(String email, String firstName, String lastName, Account conAccount, String contactId)
    {
        Service__mdt credentials = DAL_ServiceDetails.getServiceDetails('KeyCloak');
        String message = KeyCloakCallout.generateFullJSON(email, firstName, lastName, conAccount, false);
        HttpResponse response = serviceCallout(message, credentials, 'PUT', '?send_email=true');

        if(response.getStatusCode() == 200) 
        {
            keyCloakResponse deserializedResponse = (keyCloakResponse)System.JSON.deserialize(response.getBody(), keyCloakResponse.class);
            Contact cont = new Contact(Id = contactId);
            cont.External_ID__c = deserializedResponse.keycloakUuid;
            DAL_BaseObject.UpdateDBObject(cont);

            return true;
        } 
        else 
        {
            mail (message, response, credentials);
            return false;
        }
    }

    private static HttpResponse serviceCallout(String message, Service__mdt credentials, String method, String queryString)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(credentials.Endpoint__c + queryString);
        req.setMethod(method);
        req.setTimeout(90000);

        // Specify the required user name and password to access the endpoint
        // As well as the header, header information and body
        Blob headerValue = Blob.valueOf(credentials.Username__c + ':' + credentials.Password__c);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
        req.setBody(message);

        Http h = new Http();

        // Send the request, and return a response
        return h.send(req);
    }

    //Response List
    public class keyCloakResponse 
    {
        public String firstName;	
        public String lastName;	
        public String email;	
        public String keycloakUuid;	
        public Boolean enabled;
        public String accountId;	
        public Boolean exist;
    }

    public class KeyCloakRequest
    {
        public String firstName;
        public String lastName;
        public String email;
        public String accountId;
        public Boolean enabled;
        public String[] roles;
    }

    public static String generateFullJSON (String email, String firstName, String lastName, Account contactAcc, Boolean isFicaUser) 
    {
        KeyCloakRequest request = new KeyCloakRequest();
        List<String> roles = new List<String>();

        Boolean isAdumo = contactAcc.BusinessUnit__c == 'Adumo';

        if(isAdumo)
        {
            roles.add('AdumoClient');
        }  

        if(isFicaUser)
        {
            roles.add('ficaRequired');
        }

        request.firstName = firstName;
        request.lastName = lastName;
        request.email = email;
        request.accountId = contactAcc.Id;
        request.enabled = true;
        request.roles = roles;

        return JSON.serialize(request);
    }

    public static String generateResetJSON (String email) 
    {
        //Generate the JSON Object
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('email', email);
        gen.writeEndObject();
        String message = gen.getAsString();
        return message;
    }

    //Send mail on error with message and status
    public static void mail (String message, HttpResponse response, Service__mdt serviceCredential) 
    {
        String emailBodyTemplate = '<p><b>Message:</b> {0}</p><p><b>Response:</b> {1}</p><p><b>Status:</b> {2}</p><p><b>Status Code:</b> {3}</p><p><b>Headers:</b> {4}</p>';
        
        if(serviceCredential.SendErrorAlerts__c) 
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {serviceCredential.ErrorAddress__c};
            mail.setToAddresses(toAddresses);
            mail.setSubject('getKeyCloakId: Error calling the Service');
            String headers = compileHeaders(response);
            String[] arguments = new String[]{message, response.getBody(), response.getStatus(), String.valueOf(response.getStatusCode()), headers};
            mail.setHTMLBody(String.format(emailBodyTemplate, arguments));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    private static String compileHeaders(HttpResponse response)
    {
        al.StringBuffer builder = new al.StringBuffer();
        List<String> keys = response.getHeaderKeys();

        for(String key :keys)
        {
            builder.append(key);
            builder.append(':');
            builder.append(response.getHeader(key));
            builder.append('|');
        }

        return builder.toStr();
    }

    @future (callout=true)
    public static void serviceCalloutNew(Set<Id> contactIds, Boolean earlyRegister)
    {
        List<Contact> contLst = getContacts(contactIds);
                
        if(contLst.size() > 0)
        {
            Service__mdt credentials = DAL_ServiceDetails.getServiceDetails('KeyCloak');

            if(credentials != null)
            {
                for(Contact cont : contLst)
                {
                    if(cont.FirstName != null && cont.LastName != null && cont.Email != null && cont.AccountId != null)
                    {
                        String message = generateFullJSON(cont.Email, cont.FirstName, cont.LastName, cont.Account, earlyRegister);
                        HttpResponse response = serviceCallout(message, credentials, 'PUT', '?send_email=true');

                        if(response.getStatusCode() == 200) 
                        {
                            keyCloakResponse deserializedResponse = (keyCloakResponse)System.JSON.deserialize(response.getBody(), keyCloakResponse.class);
                            cont.External_ID__c = deserializedResponse.keycloakUuid;                            
                        } 
                        else 
                        {
                            mail(message, response, credentials);
                        }
                    }                
                }

                update contLst;
            }
        }
    }

    public static List<Contact> getContacts(Set<Id> contactIds)
    {
        return
        [
            SELECT  Id, 
                    FirstName, 
                    LastName, 
                    AccountId,
                    Account.BusinessUnit__c,
                    Email, 
                    KeyCloakIdentifier__c, 
                    External_ID__c 
            FROM Contact 
            WHERE Id IN :contactIds
        ];
    }
}