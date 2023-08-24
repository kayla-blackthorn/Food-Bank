/**
 * @description: Used as utility component with general usage(utility) methods
 * 
 * @author: Dharmendra Karamchandani
 */
({
    setupIsClassic: function (cmp) {
        cmp.set('v.isClassic', location.hostname.indexOf('lightning') == -1);
    },
    setLocationStorage: function (key, value) {
        window.localStorage.setItem(key, value);
    },
    getLocationStorage: function (key) {
        return window.localStorage.getItem(key);
    },
    setDocumentCookie: function (key, value, minutes) {
        var d = new Date();
        d.setTime(d.getTime() + (minutes * 60 * 1000));
        var expires = "expires=" + d.toUTCString();
        document.cookie = key + "=" + value + ";" + expires + ";path=/";
    },
    getDocumentCookie: function (key) {
        var name = key + "=";
        var cos = document.cookie.split(';');
        for (var i = 0; i < cos.length; i++) {
            var ca = cos[i];
            if (ca) {
                ca = ca.trim();
            }
            if (ca.indexOf(name) == 0) {
                return ca.substring(name.length, ca.length);
            }
        }
        return '';
    },
    serverConnect: function (cmp, hlpr, method, params, callback, callbackInfo, errorcb, noErrorToast) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c." + method);
        // passing parameter while calling
        if (params && Object.keys(params)) {
            action.setParams(params);
        }
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function (response) {
            try {
                let actionCnt = cmp.get('v.actionCnt');
                if (actionCnt != undefined) {
                    cmp.set('v.actionCnt', actionCnt - 1);
                }
                let spinner = hlpr.findEle(cmp, cmp.get('v.spinner'));
                if (spinner) {
                    $A.util.addClass(spinner, 'slds-hide');
                }
                cmp.set('v.spinner', '');
            } catch (error) {
                console.log(error);
            }
            var state = response.getState();
            if (state === "SUCCESS") {
                // passing response to a callback method
                if (callback) {
                    callback(cmp, hlpr, response, callbackInfo);
                }
            } else if (state === "INCOMPLETE") {
                this._showMessage(cmp, {
                    message: 'Please refresh the page!',
                    type: "error"
                });
            } else if (state === "ERROR") {
                // noErrorToast is true to not preparing/showing error message
                if (noErrorToast === true) {
                    if (errorcb) {
                        errorcb(cmp, hlpr, response, callbackInfo);
                    }
                    return;
                }
                try {
                    var errors = response.getError();
                    this._handleErrorss(cmp, errors);
                } catch (e) {
                    console.log($A.get("$Label.c.SCH_apex_unknow_error"), e);
                    this._showMessage(cmp, {
                        message: $A.get("$Label.c.SCH_apex_unknow_error"),
                        type: "error"
                    });
                }
                if (errorcb) {
                    errorcb(cmp, hlpr, response, callbackInfo);
                }
            }
        })
        try {
            let actionCnt = cmp.get('v.actionCnt');
            if (actionCnt != undefined) {
                cmp.set('v.actionCnt', cmp.get('v.actionCnt') + 1);
            }
            let spinner = hlpr.findEle(cmp, cmp.get('v.spinner'));
            if (spinner) {
                $A.util.removeClass(spinner, 'slds-hide');
            }
        } catch (error) {
            console.log(error);
        }
        //this is actually use to call server side method
        $A.enqueueAction(action);
    },
    _handleErrorss: function (cmp, errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        console.log('errors', errors);
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            let errorMsg = '';
            if (errors[0] && errors[0].pageErrors && errors[0].pageErrors.length > 0) {
                errorMsg = errors[0].pageErrors[0].message;
            } else if (errors[0] && errors[0].fieldErrors) {
                errorMsg = this.extractFieldsErrorMsg(errors[0].fieldErrors);
            } else if (errors[0].message) {
                errorMsg = errors[0].message;
            }
            toastParams.message = errorMsg;
        }
        if (toastParams.message) {
            this.__triggerToast(cmp, toastParams);
        }
    },
    // Extracting fields Error Message
    extractFieldsErrorMsg: function (fieldErrors) {
        var keys = Object.keys(fieldErrors);
        var msg = 'Unknown error';
        if (keys.length > 0) {
            msg = '';
            for (var ind in keys) {
                var fErrors = fieldErrors[keys[ind]];
                fErrors.forEach(function (fErr) {
                    msg += fErr.message + ' \n';
                })
            }
        }
        return msg;
    },
    capitalize: function (cmp, text) {
        return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();
    },
    _showMessage: function (cmp, message) {
        // Configure success toast
        let toastParams = {
            message: "", // no default message
            type: "success"
        };
        // Pass the success message if any
        toastParams.message = message.message;
        if (message.title) {
            toastParams.title = message.title;
        }
        if (message.type && toastParams.message) {
            toastParams.type = message.type;
            if (!toastParams.title) {
                toastParams.title = this.capitalize(cmp, message.type + '');
            }
        }
        this.__triggerToast(cmp, toastParams);
    },
    __triggerToast: function (cmp, toastParams) {
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        } else {
            var customToast = cmp.find("customToast");
            if (toastParams.type == "success") {
                toastParams.type = 'info';
            }
            cmp.set("v.msgType", toastParams.type);
            cmp.set("v.msgToShow", toastParams.message);
            if (customToast) {
                if (Array.isArray(customToast) && customToast.length > 0) {
                    $A.util.removeClass(customToast[0], "slds-hide");
                } else {
                    $A.util.removeClass(customToast, "slds-hide");
                }
            } else {
                alert(toastParams.message);
            }
        }
    },
    findEle: function (cmp, eleId) {
        var elements = cmp.find(eleId);
        if (Array.isArray(elements) && elements.length > 0) {
            elements = elements[0]
        }
        return elements;
    },
    validateForm: function (component, validationFieldAuraIds) {
        let isValidationPassed = true;
        validationFieldAuraIds.split(',').forEach(function (auraIdOfInputsToBeValidated) {
            if (component.find(auraIdOfInputsToBeValidated) && component.find(auraIdOfInputsToBeValidated).length) { //if there are any records to iterate
                (component.find(auraIdOfInputsToBeValidated)).forEach(function (inputField) {
                    if (inputField.get('v.required') && !inputField.get('v.value')) {
                        inputField.showHelpMessageIfInvalid();
                        inputField.reportValidity();
                        isValidationPassed = false;
                    }
                });
            } else {
                var singleInputField = component.find(auraIdOfInputsToBeValidated);
                if (singleInputField) {
                    if (singleInputField.get('v.required') && !singleInputField.get('v.value')) {
                        singleInputField.showHelpMessageIfInvalid();
                        singleInputField.reportValidity();
                        isValidationPassed = false;
                    }
                }
            }
        });
        return isValidationPassed;
    },
    cloneObject: function (obj) {
        if (obj) {
            return JSON.parse(JSON.stringify(obj));
        }
        return obj;
    },
    processAccountClientSide: function (record) {
        let availableFeatures = [];
        let disabledFeatures = [];
        if (record) {
            record.accountConfigured = false;
            if (record.accountNumber !== undefined && record.apiKey !== undefined) {
                if ((record.accountNumber + '').trim().length > 0 && (record.apiKey + '').trim().length > 0) {
                    record.accountConfigured = true;
                }
            }

            if (record.featuresTocheck) {
                for (let key in record.featuresTocheck) {
                    if (record.hasOwnProperty(key)) {
                        availableFeatures.push(record.featuresTocheck[key]);
                        if (record[key] == false) {
                            disabledFeatures.push(record.featuresTocheck[key]);
                        }
                    }
                }
            }
            record.disallowScheduler = false;
            record.disallowActions = false;
            record.createSchedulerLabel = $A.get("$Label.c.SCH_SS_action_create_scheduler_label");
            record.createSchedulerTitle = record.createSchedulerLabel;
            let actionDisabledInfo = '{!action} disabled';
            record.adminSuffix = ', please contact ';
            record.linkLabel = 'Blackthorn Support';
            record.nonAdminSuffix = ', please contact your System Administrator.';
            if (availableFeatures.length > 0) {
                if (disabledFeatures.length == availableFeatures.length) {
                    record.disallowScheduler = true;
                    record.createSchedulerTitle = actionDisabledInfo.replace('{!action}',
                        this._prepareFeatureInfo(availableFeatures));
                }
                if (disabledFeatures.length > 0) {
                    record.actionDisableInfo = actionDisabledInfo.replace('{!action}',
                        this._prepareFeatureInfo(disabledFeatures));
                    record.disallowActions = true;
                }
            }
        }
    },
    _prepareFeatureInfo: function (features) {
        let isAre = features.length == 1 ? ' is' : 's are';
        let otherThanLast = features.splice(0, features.length - 1);
        let message = '';
        if (otherThanLast.length > 0) {
            message = otherThanLast.join(', ') + ' and ';
        }
        message += features[0];
        message += ' feature' + isAre;
        return message;
    },
    processAndPrepareSMSResponse: function (cmp, hlpr, data) {
        data.packageData = (data.result);
        if (!data.packageData) {
            data.packageData = {};
        }
        if (!data.packageData.btSchedulePermissions) {
            data.packageData.btSchedulePermissions = {}
        }
        if (!data.packageData.btScheduleAccount) {
            data.packageData.btScheduleAccount = {};
        }
        if (data.recordLevel) {
            data.packageData.btScheduleAccount.isBTScheduleAdmin = false;
            if (!$A.util.isUndefinedOrNull(data.packageData.btSchedulePermissions.isBTScheduleAdmin)) {
                data.packageData.btScheduleAccount.isBTScheduleAdmin = data.packageData.btSchedulePermissions.isBTScheduleAdmin;
            }
            this.processAccountClientSide(data.packageData.btScheduleAccount);
        }
        data.allowSchedule = false;
        data.packageData.isInstalled = data.result.isInstalled ? data.result.isInstalled : false;
        data.packageData.allowInstall = data.result.allowInstall ? data.result.allowInstall : false;
        data.packageData.isBTScheduleAdmin = data.packageData.btSchedulePermissions.isBTScheduleAdmin ? data.packageData.btSchedulePermissions.isBTScheduleAdmin : false;
        data.packageData.accountRegistered = data.packageData.btScheduleAccount.authenticatedUser ? true : false;
        data.packageData.isConfigured = (data.packageData.btScheduleAccount.isUserAuthenticated && data.packageData.btScheduleAccount.isAuthenticatedUserActive) ? true : false;

        if (data.result.isInstalled && data.result.accountRegistered) {
            if (data.packageData.btSchedulePermissions && data.packageData.isConfigured) {
                data.allowSchedule = true;
            }
        }

        if (!data.packageData.isScheduleFeatureEnabled) {
            data.allowSchedule = false;
        }
    },
    prepareRowActions: function (data) {
        var actions = [];
        if (data.row && !$A.util.isUndefinedOrNull(data.row.Status)) {
            if (data.row.Status === 'Active') {
                actions.push({
                    name: 'archived',
                    label: $A.get("$Label.c.SCH_SS_action_archive")
                });
                actions.push({
                    name: 'inactive',
                    label: $A.get("$Label.c.SCH_SS_action_unschedule")
                });
            } else if (data.row.Status === 'Draft') {
                if (data.row.ScheduleType === 'SMS' && !$A.util.isUndefinedOrNull(data.account.featureScheduleSMS) && !$A.util.isEmpty(data.account.featureScheduleSMS) && data.account.featureScheduleSMS == true) {
                    actions.push({
                        name: 'edit',
                        label: $A.get("$Label.c.SCH_SS_action_edit")
                    });
                } else if (data.row.ScheduleType === 'Email' && !$A.util.isUndefinedOrNull(data.account.featureScheduleEmail) && !$A.util.isEmpty(data.account.featureScheduleEmail) && data.account.featureScheduleEmail == true) {
                    actions.push({
                        name: 'edit',
                        label: $A.get("$Label.c.SCH_SS_action_edit")
                    });
                }
                actions.push({
                    name: 'archived',
                    label: $A.get("$Label.c.SCH_SS_action_archive")
                });
            } else if (data.row.Status === 'Inactive') {
                actions.push({
                    name: 'archived',
                    label: $A.get("$Label.c.SCH_SS_action_archive")
                });
            }
            if (!$A.util.isUndefinedOrNull(data.row.first_activated_at) && !$A.util.isEmpty(data.row.first_activated_at)) {
                actions.push({
                    name: 'view_detail',
                    label: $A.get("$Label.c.SCH_SS_action_view_detail")
                });
            }
            if (actions.length == 0) {
                actions.push({
                    name: 'no_action',
                    label: $A.get("$Label.c.SCH_SS_action_no_action"),
                    disabled: true
                });
            }
        }
        data.actions = actions;
    },
    _prepareArchiveConfirmData: function (row, action) {
        let startText = "Are you sure you want to ";
        let endText = "?";
        if (action == "archived") {
            startText += "archive ";
        } else if (action == 'inactive') {
            startText += "unschedule ";
            endText += " This action cannot be undone."
        } else {
            startText += action + " ";
        }
        return {
            "title": action,
            "body": [{
                    text: startText
                },
                {
                    text: row.ScheduleActionName,
                    isBlod: true
                },
                {
                    text: endText
                }
            ],
            "btn_name": action,
            "action_name": "updateSchedule",
            "salesforce_id": row.salesforce_id,
            "status": action
        };
    },
    processRowAction: function (cmp, hlpr, data) {
        switch (data.action.name) {
            case 'archived':
            case 'inactive':
                cmp.set("v.confirm_data", this._prepareArchiveConfirmData(data.row, data.action.name));
                cmp.set("v.isShowConfirmModal", true);
                break;
            case 'edit':
                if (data.spinner) {
                    cmp.set("v.spinner", data.spinner);
                }
                cmp.set("v.existingScheduleId", data.row.salesforce_id);
                cmp.set("v." + data.isShowCreateNewSchedule, true);
                break;
            case 'schedule':
                if (data.spinner) {
                    cmp.set("v.spinner", data.spinner);
                }
                hlpr.serverConnect(cmp, hlpr, 'updateSchedule', {
                    recordId: data.row.salesforce_id,
                    status: 'active'
                }, hlpr._updateScheduleResponse);
                break;
            case 'ActionName':
                if (data.spinner) {
                    cmp.set("v.spinner", data.spinner);
                }
                cmp.set("v.filter", null);
                cmp.set("v." + data.recipientObjectName, data.row.related_object);
                if (data.row.ScheduleType != null && data.row.ScheduleType != undefined && (data.row.ScheduleType + '').toLowerCase() === 'sms' && !$A.util.isUndefinedOrNull(data.row.sms_to_number_field)) {
                    cmp.set("v.fieldNameToShow", data.row.sms_to_number_field);
                } else if (data.row.ScheduleType != null && data.row.ScheduleType != undefined && (data.row.ScheduleType + '').toLowerCase() === 'email' && !$A.util.isUndefinedOrNull(data.row.email_to_address_field)) {
                    cmp.set("v.fieldNameToShow", data.row.email_to_address_field);
                }
                hlpr.serverConnect(cmp, hlpr, 'getAdminTotalRecipientsFilter', {
                    objectName: data.row.base_object,
                    relatedObject: data.row.related_object,
                    relatedRelationshipName: data.row.base_related_relationship,
                    scheduleId: data.row.salesforce_id
                }, hlpr._relatedRelationshipFieldName);
                break;
            case 'view_detail':
                if (data.spinner) {
                    cmp.set("v.spinner", data.spinner);
                }
                cmp.set("v.scheduleData", {
                    'schedule_Id': data.row.salesforce_id,
                    'schedule_Type': data.row.ScheduleType.toLowerCase(),
                    'schedule_Name': data.row.ScheduleActionName
                });
                cmp.set("v.showAllExecution", true);
                break;
        }
    }
})