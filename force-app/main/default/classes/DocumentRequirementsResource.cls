/*
Date created: 26/01/2022
Developer: Ivan Vrtacnik
JIRA number: PS-1456
*/
@RestResource(urlMapping='/documentRequirements/*')
global class DocumentRequirementsResource
{
    @HttpGet
    global static List<LCC_DocumentRequirementController.documentRequirement> getDocuments()
    {
        Map<String, String> requestParams = RestContext.request.params;
        String recordId = requestParams.get('id');
        List<String> hideDocuments = new List<String>{'Draft Contract'};
        String busType = LCC_DocumentRequirementController.getDealById(recordId).Account__r.BusinessType__c;

        LCC_DocumentRequirementController.documentRequirement ficaResult = LCC_DocumentRequirementController.getDocuments(recordId, 'Deal__c', 'FICA', busType, hideDocuments);

        return new List<LCC_DocumentRequirementController.documentRequirement>{ficaResult};
    }
}