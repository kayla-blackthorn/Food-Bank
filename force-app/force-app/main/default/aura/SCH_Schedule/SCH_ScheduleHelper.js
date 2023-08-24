({
    jsDoInit: function (component) {
        var dateTimeFieldsArr = component.get("v.dateTimeFields");
        var scheduleObj = component.get("v.scheduleObj");
        var scheduleDateTimeField = component.get("v.scheduleObj.Schedule_Date_Time_Field");
        if (dateTimeFieldsArr.length > 0 && ($A.util.isUndefinedOrNull(scheduleDateTimeField) || $A.util.isEmpty(scheduleDateTimeField))) {
            component.set("v.scheduleObj.Schedule_Date_Time_Field", dateTimeFieldsArr[0].value);
        } else if (!$A.util.isUndefinedOrNull(scheduleDateTimeField) && !$A.util.isEmpty(scheduleDateTimeField) && !$A.util.isUndefinedOrNull(scheduleObj.SObject_RecordId) && !$A.util.isEmpty(scheduleObj.SObject_RecordId) && !$A.util.isUndefinedOrNull(scheduleObj.Base_Object) && scheduleObj.Base_Object === 'conference360__Event__c') {
            for (let dd = 0; dd < dateTimeFieldsArr.length; dd++) {
                if (dateTimeFieldsArr[dd].value.indexOf('.') != -1) {
                    var dateTimefieldArr = dateTimeFieldsArr[dd].value.split('.');
                    if (dateTimefieldArr != undefined && dateTimefieldArr.length > 0 && dateTimefieldArr[1] == scheduleDateTimeField) {
                        component.set("v.scheduleObj.Schedule_Date_Time_Field", dateTimeFieldsArr[dd].value);
                    }
                }
            }
        }
        this.executeNowUpdateJS(component, this);
    },

    executeNowUpdateJS: function (component, helper) {
        var executeNow = component.get("v.isExecuteNow");
        if (!$A.util.isUndefinedOrNull(executeNow) && executeNow == true) {
            component.find("datetime_now").set("v.checked", true);
            component.set("v.scheduleObj.Schedule_Date_Time_Field", "now");
        } else if (!$A.util.isUndefinedOrNull(component.get("v.scheduleObj.Offset_Value")) && !$A.util.isEmpty(component.get("v.scheduleObj.Offset_Value")) && !$A.util.isUndefinedOrNull(component.get("v.scheduleObj.Schedule_Date_Time_Field")) && !$A.util.isEmpty(component.get("v.scheduleObj.Schedule_Date_Time_Field"))) {
            component.find("datetime_beforeAfter").set("v.checked", true);
        } else {
            component.find("datetime_value").set("v.checked", true);
        }
    },

    showToast: function (component, message, duration, type) {
        (this)._showMessage(component, {
            message: message,
            type: type
        });
    },

    nextJS: function (component, helper, isSave) {
        let isValid = false;
        let errormessage = $A.get("$Label.c.SCH_SS_field_selection_error_datetime");
        if (component.find("datetime_value").get("v.checked")) {
            let selectedDateTime = component.get("v.scheduleObj.Schedule_Date_Time");
            let now = new Date();
            now.setTime(now.getTime() + (1 * 60 * 1000));
            let dtVal = new Date(selectedDateTime);
            if (dtVal.getTime() >= now.getTime()) {
                isValid = true;
            } else {
                errormessage = $A.get("$Label.c.SCH_SS_field_selection_error_past_datetime");
            }
        } else if (component.find("datetime_now").get("v.checked")) {
            isValid = true;
            component.set("v.scheduleObj.Schedule_Date_Time_Field", "now");
        } else if (component.find("datetime_beforeAfter").get("v.checked")) {
            let selectedday = component.get("v.scheduleObj.Offset_Value");
            let selecteddaysOptions = component.get("v.scheduleObj.Offset_Type");
            let selectedBeforeAfterOptions = component.get("v.scheduleObj.Offset");
            let selectedDateTimeField = component.get("v.scheduleObj.Schedule_Date_Time_Field");
            if (selectedday != null && selectedday != undefined && selectedday != '' &&
                selecteddaysOptions != null && selecteddaysOptions != undefined && selecteddaysOptions != '' &&
                selectedBeforeAfterOptions != null && selectedBeforeAfterOptions != undefined && selectedBeforeAfterOptions != '') {
                isValid = true;
            }
        }

        if (isValid) {
            if (!isSave) {
                let currentStep = component.get("v.currentStep");
                if (currentStep < 3) {
                    component.set("v.currentStep", 3);
                }
                component.set("v.selectedActiveSectionName", "Message");
            }
        } else {
            this.showToast(component, errormessage, 3000, 'error');
        }
        return isValid;
    },
    dateTimeChangeJS: function (component, event, helper) {
        var datetimetype = event.getSource().get("v.label");
        component.set("v.scheduleObj.Schedule_Date_Time_Field", '');
        component.set("v.scheduleObj.Schedule_Date_Time", '');
        component.set('v.scheduleObj.Offset_Value', '');
        component.set('v.scheduleObj.Execute_Now', false);

        var daysOptions = component.get("v.daysOptions");
        if (!$A.util.isUndefinedOrNull(daysOptions)) {
            component.set("v.scheduleObj.Offset_Type", daysOptions[0].value);
        }

        var beforeAfterOptions = component.get("v.beforeAfterOptions");
        if (!$A.util.isUndefinedOrNull(beforeAfterOptions)) {
            component.set("v.scheduleObj.Offset", beforeAfterOptions[0].value);
        }

        var dateTimeFields = component.get("v.dateTimeFields");
        if (!$A.util.isUndefinedOrNull(dateTimeFields)) {
            component.set("v.scheduleObj.Schedule_Date_Time_Field", dateTimeFields[0].value);
        }

        if (!$A.util.isUndefinedOrNull(datetimetype) && !$A.util.isEmpty(datetimetype) && datetimetype === 'datetime_now') {
            component.set('v.scheduleObj.Execute_Now', true);
        }
    },
    jsDaysChange: function (component, event, helper) {
        if (event.which < 48 || event.which > 57) {
            event.preventDefault();
        }
    }
})