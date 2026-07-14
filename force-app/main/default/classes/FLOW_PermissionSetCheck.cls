/**
 * Created by JurgitaG on 7/14/2021.
 */

public class FLOW_PermissionSetCheck
{
	@InvocableMethod(label='Permission Check')
	public static List<Boolean> checkCPQPermission(List<PermissionSetRequest> requests){
		List<Boolean> results = new List<Boolean>();
		Set<Id> userIds = new Set<Id>();
		String permissionName='';
		for (PermissionSetRequest aRequest:requests){
			userIds.add(aRequest.userId);
			permissionName = aRequest.permissionSetName;
		}
		List<PermissionSetAssignment> assignments = [
				SELECT AssigneeId
				FROM PermissionSetAssignment
				WHERE
				AssigneeId IN:userIds AND
				PermissionSet.Name = :permissionName];
		Set<Id> userWithPermissionList = UTIL_System.extractListIds(assignments, PermissionSetAssignment.AssigneeId.getDescribe().getSobjectField());
		System.debug(userWithPermissionList);
		for (PermissionSetRequest aRequest:requests){
			results.add(userWithPermissionList.contains(aRequest.userId));
		}
		return results;
	}

	public class PermissionSetRequest
	{
		@InvocableVariable(label='User Id' required=true)
		public String userId;

		@InvocableVariable(label='Permission set name')
		public String permissionSetName;
	}

}