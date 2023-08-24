({
    jsEmailTemplateSelected: function (cmp, evt, hlpr) {
        let params = evt.getParams();
        cmp.set("v.scheduleObj.Email_Template_Id", params.record.Id);
        cmp.set("v.scheduleObj.Email_Template_Name", params.record.Name);
    },

    jsNext: function (cmp, evt, hlpr) {
        let lookup_emailtemplate = cmp.find("lookup_emailtemplate");
        if (lookup_emailtemplate.reportValidity()) {
            cmp.set("v.currentStep", 4);
            cmp.set("v.selectedActiveSectionName", "Preview");
        } else {
            hlpr.showToast(cmp, $A.get("$Label.c.SCH_SS_field_selection_error_email_template"), 10000, 'error');
        }
    },

    jsPrevious: function (cmp, evt, hlpr) {
        cmp.set("v.selectedActiveSectionName", "Schedule");
    },
    showToast: function (component, message, duration, type) {
        (this)._showMessage(component, {
            message: message,
            type: type
        });
    },
    jsCreateNewEmailTemplate: function (cmp, evt, hlpr) {
        let relatedRecordId = cmp.get("v.relatedRecordId");
        let compDef = {
            "type": "standard__recordPage",
            "attributes": {
                "objectApiName": "conference360__Event__c",
                "recordId": relatedRecordId,
                "actionName": "view"
            },
            "state": {}
        }
        let parseCompDef = '1.' + btoa(JSON.stringify(compDef)).replaceAll('=', '%3D');
        let newTemplateURL = '/lightning/o/';
        if (!$A.util.isUndefinedOrNull(relatedRecordId) && !$A.util.isEmpty(relatedRecordId)) {
            newTemplateURL += 'conference360__Email_Template__c/new?inContextOfRef=' + parseCompDef;
        } else {
            newTemplateURL += 'EmailTemplate/home';
        }
        window.open(newTemplateURL, '_blank');
    },
    validatedFormJS: function (component, helper) {
        let isValid = false;
        let lookup_emailtemplate = component.find("lookup_emailtemplate");
        if (lookup_emailtemplate.reportValidity()) {
            isValid = true;
        }
        return isValid;
    },
})