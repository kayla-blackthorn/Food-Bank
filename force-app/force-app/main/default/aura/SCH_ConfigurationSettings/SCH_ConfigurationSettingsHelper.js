({
    jsDoInit: function (component, helper) {
        let packageData = component.get("v.packageData");
        if (packageData) {
            helper._processHelpLink(component);
        }
    },

    _processHelpLink: function (component) {
        let optionMatched = false;
        let account = component.get('v.account');
        let logRecordOptions = component.get("v.packageData.helpLinks");
        if (logRecordOptions.hasOwnProperty('create_log_record_options')) {
            logRecordOptions = logRecordOptions.create_log_record_options;
            let options = component.get('v.options');
            for (let opt of logRecordOptions) {
                options.push({
                    'label': opt.label,
                    'value': opt.text
                });
                if (account.createLogInOrgAs == opt.text) {
                    optionMatched = true;
                }
            }
            component.set('v.options', options);
            if (!optionMatched) {
                component.set('v.selectedOption', options[0].value);
            }
        }
    },

    updateAccounthelper: function (component, account) {
        this.showSpinner(component);
        let action = component.get("c.updateAccount");
        action.setParams({
            'jsonBody': JSON.stringify(account)
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                this.showToast(component, 'Configuration has been updated.', 1000, 'success');
                this.hideSpinner(component);
            } else if (component.isValid() && state === 'ERROR') {
                let errors = response.getError();
                if (errors) {
                    for(let err of errors) {
                        if (err.message) {
                            let errorMessage = err.message.toLowerCase();
                            if (errorMessage.indexOf('not authorized') >= 0) {
                                component.set("v.packageData.hasAccountCredentials", false);
                                this.showToast(component, $A.get("$Label.c.SCH_Acc_Invalid_Credentials"), 10000, "error");
                            } else {
                                this.showToast(component, err.message, 10000, "error");
                            }
                        }
                    }
                } else {
                    this.showToast(component, $A.get("$Label.c.SCH_apex_unknow_error"), 1000, 'error');
                }
                this.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, message, duration, type) {
        let toastEvent = $A.get("e.force:showToast");
        if (toastEvent && toastEvent != 'undefined') {
            toastEvent.setParams({
                "title": 'Smart Scheduler',
                "message": message,
                "duration": duration,
                "type": type
            });
            toastEvent.fire();
        } else {
            let customToast = component.find("customToast");
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

    showSpinner: function (component) {
        let spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component) {
        let spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})