public inherited sharing class PermissionSetService {
    public static final String PROFILE_SYS_ADMIN = 'System Administrator';

    public PermissionSetService() {
    }

    public Map<String, Object> assignAdminPermissions(List<User> objList) {
        List<PermissionSetAssignment> assignment = new List<PermissionSetAssignment>();

        Map<Id, User> userList = new Map<Id, User>(objList);

        for (Id user : userList.keySet()) {
            for (PermissionSet perms : getAdminPermissionSets()) {
                assignment.add(new PermissionSetAssignment(PermissionSetId = perms.Id, AssigneeId = user));
            }
        }
        Database.SaveResult[] srList = Database.insert(assignment, false);
        return handlePermissionAssignmentResponse(srList);
    }

    private Map<String, Object> handlePermissionAssignmentResponse(Database.SaveResult[] srList) {
        Set<String> errorMsgs = new Set<String>();
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                errorMsgs.add(sr.getErrors()[0].getMessage());
            }
        }
        Map<String, Object> results = new Map<String, Object>();
        results.put('status', errorMsgs.size() > 0 ? false : true);
        if (errorMsgs.size() > 0) {
            results.put('errorsMessages', JSON.serialize(errorMsgs));
        }
        return results;
    }

    @TestVisible
    private List<PermissionSet> getAdminPermissionSets() {
        Set<String> permissionSets = new Set<String>{
            'Blackthorn_Events_Admin',
            'payment360_Adminv2',
            'Blackthorn_Storefront_Admin',
            'Blackthorn_Base_Admin'
        };
        List<PermissionSet> permSetLst = [SELECT Id, Name, Label FROM PermissionSet WHERE Name IN :permissionSets];
        return permSetLst;
    }
}
