({
    jsInit: function (cmp, evt, hlpr) {
        let scheduleObj = cmp.get("v.scheduleObj");
        let sobjectApiName = scheduleObj.Base_Object;
        let resultPrimaryFieldReference = '';
        let resultSecondaryField = '';
        let searchByField = '';
        let op = '';
        let lkpFilter = '';
        if (scheduleObj.Related_Object_FieldAPIName) {
            resultSecondaryField = scheduleObj.Related_Object_FieldAPIName;
            op = ',';
        }
        if (scheduleObj.Action === 'Email' && scheduleObj.Email_To_Address) {
            lkpFilter = scheduleObj.Email_To_Address + ' != null ';
        }
        if (!$A.util.isUndefinedOrNull(scheduleObj.Related_Object) && !$A.util.isEmpty(scheduleObj.Related_Object)) {
            sobjectApiName = scheduleObj.Related_Object;
        }
        if (scheduleObj.Associate_With_Referenced_Record && scheduleObj.AssociateWithReferencedRecordOptions && !$A.util.isUndefinedOrNull(scheduleObj.Associate_With_Referenced_Record) && !$A.util.isEmpty(scheduleObj.Associate_With_Referenced_Record)) {
            for (let option of scheduleObj.AssociateWithReferencedRecordOptions) {
                if (option.value == scheduleObj.Associate_With_Referenced_Record) {
                    if (option.label.indexOf('.') != -1) {
                        sobjectApiName = (option.label.split('.')).pop();
                    }
                    if (lkpFilter && option.queryFieldRelationshipName &&
                        lkpFilter.indexOf(option.queryFieldRelationshipName) != -1) {
                        lkpFilter = lkpFilter.replace(option.queryFieldRelationshipName + '.', '');
                    }
                }
            }
        }
        var helpLinks = cmp.get("v.helpLinks");
        if (helpLinks && helpLinks.sfdc_sobject_replace_name_field && sobjectApiName &&
            helpLinks.sfdc_sobject_replace_name_field[sobjectApiName]) {
            resultPrimaryFieldReference = helpLinks.sfdc_sobject_replace_name_field[sobjectApiName];
            searchByField = helpLinks.sfdc_sobject_replace_name_field[sobjectApiName];
        }
        cmp.set("v.lkp_sobjectApiName", sobjectApiName);
        if (resultPrimaryFieldReference && resultPrimaryFieldReference != '') {
            cmp.set("v.lkp_resultPrimaryFieldReference", resultPrimaryFieldReference);
        } else {
            cmp.set("v.lkp_resultPrimaryFieldReference", cmp.get("v.lkp_resultPrimaryField"));
        }
        cmp.set("v.lkp_searchByField", searchByField);
        cmp.set("v.lkp_resultSecondaryField", resultSecondaryField);
        cmp.set("v.lkp_filter", lkpFilter);
        cmp.set("v.allowLookup", true);
    },
    previousJS: function (component, helper) {
        component.set("v.selectedActiveSectionName", "Message");
    },
    jsRecordSelected: function (component, event, helper) {
        let params = event.getParams();
        component.set("v.selectedTestRecordId", params.record.Id);
        component.set("v.selectedTestRecordName", params.record.Name);
    },
    jsSendTest: function (component, helper) {
        component.set("v.spinner", 'send-loading');
        let lookup_TestRecord = component.find("lookup_TestRecord");
        if (lookup_TestRecord.reportValidity()) {
            let isValid = helper.validateForm(component, 'phoneOrEmailValues');
            let val = component.find("phoneOrEmailValues").get("v.value");
            if (isValid && (val + '').trim().length > 0) {
                let isValidData = false;
                if (component.get("v.scheduleObj.Action") === 'Email') {
                    if (!$A.util.isUndefinedOrNull(component.get("v.scheduleObj.Email_Template_Id"))) {
                        isValidData = true;
                    } else {
                        helper._showMessage(component, {
                            message: $A.get("$Label.c.SCH_SS_field_selection_error_email_template"),
                            type: "error"
                        });
                        component.set("v.spinner", '');
                    }
                } else {
                    isValidData = true;
                }
                if (isValidData) {
                    helper.serverConnect(component, helper, 'sendAndTestScheduleSMSPreview', {
                        scheduleJSON: JSON.stringify(component.get("v.scheduleObj")),
                        phoneOrEmailValues: val.trim(),
                        targetRecordId: component.get("v.selectedTestRecordId")
                    }, helper._sendTestResponseJS);
                }
            } else {
                helper._showMessage(component, {
                    message: (component.get("v.scheduleObj.Action") === 'SMS' ? 'Test Phone Number(s)' : 'Test Email(s)') + ': You must enter a value',
                    type: "error"
                });
                component.set("v.spinner", '');
            }
        } else {
            helper._showMessage(component, {
                message: 'Test Record not selected',
                type: "error"
            });
            component.set("v.spinner", '');
        }
    },
    _sendTestResponseJS: function (component, helper, response, cbInfo) {
        component.set("v.spinner", '');
        helper._showMessage(component, {
            message: (component.get("v.scheduleObj.Action") === 'SMS' ? 'Message' : 'Email') + ' sent successfully!',
            type: "success"
        });
    },

})