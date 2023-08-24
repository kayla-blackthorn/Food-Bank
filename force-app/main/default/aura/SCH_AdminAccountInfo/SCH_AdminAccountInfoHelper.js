({
    jsDoInit: function (component, helper) {
        var packageData = component.get("v.packageData");
        if (packageData) {
            helper._processAccount(component);
        }
    },
    handleAuthentication: function (component, helper) {
        component.set("v.spinner", "main-loading");
        helper.serverConnect(component, helper, 'getAuthenticationLink', {
            retUrl: window.location.href
        }, helper._AuthenticationJSHelper);
    },
    _AuthenticationJSHelper: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        var urlEvent = $A.get("e.force:navigateToURL");
        if (urlEvent) {
            urlEvent.setParams({
                url: result
            });
            urlEvent.fire();
        } else {
            window.open(result);
        }
        component.set("v.spinner", "");
    },
    updateTexteyAdministrationUI: function (component, helper) {
        helper.fetchAccount(component, helper);
    },

    fetchAccount: function (component, helper) {
        this.showSpinner(component);
        var action = component.get("c.getAccount");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.packageData.account", result);
                // at the time of fetching account details
                helper._processAccount(component);
            } else if (component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMessage = errors[0].message.toLowerCase();
                        if (errorMessage.indexOf('not authorized') >= 0) {
                            component.set("v.packageData.hasAccountCredentials", false);
                            this.showToast(component, $A.get("$Label.c.SCH_Acc_Invalid_Credentials"), 10000, "error");
                        } else {
                            this.showToast(component, errors[0].message, 10000, "error");
                        }
                    }
                } else {
                    console.log($A.get("$Label.c.SCH_apex_unknow_error"), errors);
                    this.showToast(component, $A.get("$Label.c.SCH_apex_unknow_error"), 1000, 'error');
                }
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    _processAccount: function (cmp) {
        this.hideSpinner(cmp);
        let account = cmp.get('v.packageData.account');
        if (account) {
            let authUsers = [];
            if (account.authenticatedUser && account.authenticatedUser.email) {
                authUsers.push(account.authenticatedUser);
            }
            this.processAccountClientSide(account);
            cmp.set("v.activeStep", (authUsers.length > 0 ? 2 : 1));
            cmp.set("v.authUsers", authUsers);
            cmp.set("v.packageData.account", account)
        }
    },
    fetchAccountCredentials: function (component, helper) {
        helper.serverConnect(component, helper, 'hasAccountCredentials', {}, helper._AccountCredentialsJSHelper);
    },
    _AccountCredentialsJSHelper: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        component.set("v.packageData.hasAccountCredentials", result);
    },
    showToast: function (component, message, duration, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent != 'undefined' && toastEvent != undefined) {
            toastEvent.setParams({
                "title": 'Smart Scheduler',
                "message": message,
                "duration": duration,
                "type": type
            });
            toastEvent.fire();
        } else {
            var customToast = component.find("customToast");
            if (type == "success") {
                type = 'info';
            }
            component.set("v.msgType", type);
            component.set("v.msgToShow", message);
            $A.util.removeClass(customToast, "slds-hide");
            window.setTimeout($A.getCallback(function () {
                component.set("v.msgType", '');
                component.set("v.msgToShow", '');
            }), duration)
        }
    },
    toggleRegistrationModal: function (component) {
        var registrationModal = component.find("registrationModal");
        this.toggleShow(component, registrationModal);
    },
    toggleShow: function (component, el) {
        $A.util.toggleClass(el, "slds-hide");
    },
    toggleInputCredentialsModal: function (component) {
        var inputCredentialsModal = component.find("inputCredentialsModal");
        this.toggleShow(component, inputCredentialsModal);

        var accountNumberInput = component.find("inputCredentialsAccountNumber");
        var apiKey = component.find("inputCredentialsApiKey");

        accountNumberInput.set("v.value", "");
        apiKey.set("v.value", "");
    },
    postRegistrationCheck: function (component) {
        this.toggleRegistrationModal(component);
        let isSandbox = component.get("v.packageData.isSandbox");
        let helpLinks = component.get("v.packageData.helpLinks");
        let isAllowSelfRegistration = false;
        if(helpLinks.hasOwnProperty('allow_sandbox_orgs_for_self_registration')){
            isAllowSelfRegistration = (helpLinks.allow_sandbox_orgs_for_self_registration+'').toLowerCase() === "true";
        }
        var custDetails = component.get("v.custDetails");
        if (isSandbox && !isAllowSelfRegistration && !custDetails.isPremiumCustomer) {
            this.toggleSandboxRegistrationModal(component);
        } else {
            this.toggleProdRegistrationModal(component);
        }
    },
    toggleProdRegistrationModal: function (component) {
        var prodRegistrationModal = component.find("prodRegistrationModal");
        this.toggleShow(component, prodRegistrationModal);
    },
    toggleSandboxRegistrationModal: function (component) {
        var sandboxRegistrationModal = component.find("sandboxRegistrationModal");
        this.toggleShow(component, sandboxRegistrationModal);
    },
    showSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    handleInputCredentialsSave: function (component) {
        this.toggleShow(component, component.find("accRegistrationSpinner"));
        var accountNumber = component.find("inputCredentialsAccountNumber").get("v.value");
        var apiKey = component.find("inputCredentialsApiKey").get("v.value");
        var action = component.get("c.updateProtectedCustomSettings");
        action.setParams({
            accountNumber: accountNumber,
            apiKey: apiKey
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.packageData.hasAccountCredentials", true);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                        this.showToast(component, errors[0].message, 10000, 'error');
                    }
                } else {
                    console.log($A.get("$Label.c.SCH_apex_unknow_error"), errors);
                    this.showToast(component, $A.get("$Label.c.SCH_apex_unknow_error"), 1000, 'error');
                }
            }
            this.toggleShow(component, component.find("accRegistrationSpinner"));
            this.toggleInputCredentialsModal(component);
        });
        $A.enqueueAction(action);
    },
    handleActivateNewAccount: function (component, helper) {
        this.toggleShow(component, component.find("prodRegistrationSpinner"));
        var action = component.get("c.activateNewAccount");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.packageData.account", result);
                this.toggleShow(component, component.find("prodRegistrationModal"));
                this.showToast(component, $A.get("$Label.c.SCH_Account_Created"), 10000, "success");
                this.fetchAccountCredentials(component, helper);
                // at the time of fetching account details
                this._processAccount(component);
            } else if (component.isValid() && state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                        this.showToast(component, errors[0].message, 1000, 'error');
                    }
                } else {
                    console.log($A.get("$Label.c.SCH_apex_unknow_error"), errors);
                    this.showToast(component, $A.get("$Label.c.SCH_apex_unknow_error"), 1000, 'error');
                }
            }
            this.toggleShow(component, component.find("prodRegistrationSpinner"));
        });
        $A.enqueueAction(action);
    },
    deleteAuthenticatedUser: function (component, helper, userId) {
        component.set("v.spinner", "main-loading");
        helper.serverConnect(component, helper, 'deleteUser', {
            userId: userId
        }, helper._deleteUserHelper);
    },
    _deleteUserHelper: function (component, helper, response, cbInfo) {
        helper.fetchAccount(component, helper);
        helper.showToast(component, "Authenticated User has been deleted", 5000, "success");
        component.set("v.spinner", "");
    },
    updateCredentialsJS: function (component, helper) {
        var accountNumber = component.find("accountNumberInputUpdate");
        var apiKey = component.find("apiKeyInputUpdate");
        var confirm = component.find("confirm-change-credentials");
        if (accountNumber.checkValidity() && apiKey.checkValidity() && confirm.checkValidity()) {
            var action = component.get("c.updateProtectedCustomSettings");
            action.setParams({
                accountNumber: accountNumber.get("v.value"),
                apiKey: apiKey.get("v.value")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    helper.updateTexteyAdministrationUI(component, helper);
                } else if (state === 'ERROR') {
                    console.log('error');
                }
            });
            component.set('v.openEditModal', false);
            $A.enqueueAction(action);
        } else {
            accountNumber.reportValidity();
            apiKey.reportValidity();
            confirm.checkValidity();
            helper.showToast(component, 'Please update invalid fields and try again.', 10000, 'error');
        }
    }
})