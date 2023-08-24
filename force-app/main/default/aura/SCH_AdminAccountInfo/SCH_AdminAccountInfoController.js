({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },
    handleAuthenticationClick: function (component, event, helper) {
        helper.handleAuthentication(component, helper);
    },
    openEditModal: function (component, event, helper) {
        component.set('v.openEditModal', true);
    },
    closeModel: function (component, event, helper) {
        component.set('v.openEditModal', false);
    },
    updateCredentials: function (component, event, helper) {
        helper.updateCredentialsJS(component, helper);
    },
    handleUnlockApiKey: function (component, event, helper) {
        var account = component.get("v.packageData.account");
        component.set("v.apiKey", account.apiKey + ' ');
        $A.util.toggleClass(component.find("apikeypanel"), "lock-unlock-key");
        var unlock = component.find("unlock");
        $A.util.addClass(unlock, "slds-hide");
        var lock = component.find("lock");
        $A.util.removeClass(lock, "slds-hide");
    },
    handleLockApiKey: function (component, event, helper) {
        component.set("v.apiKey", '****************');
        $A.util.toggleClass(component.find("apikeypanel"), "lock-unlock-key");

        var lock = component.find("lock");
        $A.util.addClass(lock, "slds-hide");

        var unlock = component.find("unlock");
        $A.util.removeClass(unlock, "slds-hide");
    },
    handleRegistrationYes: function (component, event, helper) {
        helper.toggleRegistrationModal(component);
        helper.toggleInputCredentialsModal(component);
    },
    handleRegistrationNo: function (component, event, helper) {
        helper.postRegistrationCheck(component);
    },
    handleInputCredentialsBack: function (component, event, helper) {
        helper.toggleInputCredentialsModal(component);
        helper.toggleRegistrationModal(component);
    },
    handleInputCredentialsSave: function (component, event, helper) {
        helper.handleInputCredentialsSave(component, helper);
    },
    handleActivationClick: function (component, event, helper) {
        var check = component.find("activateCheck");
        var isChecked = check.get("v.value");
        var confirmButton = component.find("activateButton");
        confirmButton.set("v.disabled", !isChecked);
    },
    handleProdRegistrationBack: function (component, event, helper) {
        helper.toggleProdRegistrationModal(component);
        helper.toggleRegistrationModal(component);
    },
    handleProdRegistrationActivate: function (component, event, helper) {
        helper.handleActivateNewAccount(component, helper);
    },
    handleSandboxRegistrationBack: function (component, event, helper) {
        helper.toggleSandboxRegistrationModal(component);
        helper.toggleRegistrationModal(component);
    },
    handleSandboxRegistrationEmail: function (component, event, helper) {
        window.open(component.get("v.packageData.helpLinks.BT_Support_Team"));
    },
    handleHasCredentialsChange: function (component, event, helper) {
        var hasCredentials = component.get("v.packageData.hasAccountCredentials");
        if (hasCredentials) {
            helper.updateTexteyAdministrationUI(component, helper);
        }
    },
    deleteAuthenticatedUser: function (component, event, helper) {
        var userId = event.getSource().get("v.name");
        helper.deleteAuthenticatedUser(component, helper, userId);
    },
})