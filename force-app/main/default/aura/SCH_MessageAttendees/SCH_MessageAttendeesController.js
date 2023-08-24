({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },

    handleResetAccordSections: function (component, event, helper) {
        component.find("accordion").set("v.activeSectionName", ['Recipients']);
        var accordion_scheduleSection = component.find("accordion_schedule");
        if (accordion_scheduleSection) {
            accordion_scheduleSection.set("v.activeSectionName", []);
        }
        var accordion_messageSection = component.find("accordion_message");
        if (accordion_messageSection) {
            accordion_messageSection.set("v.activeSectionName", []);
        }
        var accordion_previewSection = component.find("accordion_preview");
        if (accordion_previewSection) {
            accordion_previewSection.set("v.activeSectionName", []);
        }
        component.set("v.selectedActiveSectionName", "Recipients");
        component.set("v.scheduleObj.Email_To_Address", "");
        component.set("v.scheduleObj.SMS_To_Number", "");
        helper.jsDoInit(component, helper);
    },

    handleAttendeeFilterChange: function (component, event, helper) {
        helper.handleAttendeeFilterChangeJS(component, helper);
    },

    handleAttendeeFilterBoxChange: function (component, event, helper) {
        component.set("v.selectedAttendeeFilterValue", []);
        helper.selectedAttendeeFilterLabelJS(component);
        helper.selectedAttendeeFilterOptionsJS(component, helper);
        helper.handleAttendeeFilterChangeJS(component, helper);
    },

    handleSubmitRecipients: function (component, event, helper) {
        helper.submitRecipientsJS(component, helper);
    },

    handleScheduleSelectedAccordin: function (component, event, helper) {
        var accordionSection = component.find("accordion");
        if (accordionSection) {
            accordionSection.set("v.activeSectionName", []);
        }
        var accordion_scheduleSection = component.find("accordion_schedule");
        if (accordion_scheduleSection) {
            accordion_scheduleSection.set("v.activeSectionName", []);
        }
        var accordion_messageSection = component.find("accordion_message");
        if (accordion_messageSection) {
            accordion_messageSection.set("v.activeSectionName", []);
        }
        var accordion_previewSection = component.find("accordion_preview");
        if (accordion_previewSection) {
            accordion_previewSection.set("v.activeSectionName", []);
        }

        if (accordionSection && component.get("v.selectedActiveSectionName") === 'Recipients') {
            component.find("accordion").set("v.activeSectionName", ['Recipients']);
        } else if (accordion_scheduleSection && component.get("v.selectedActiveSectionName") === 'Schedule') {
            component.find("accordion_schedule").set("v.activeSectionName", ['Schedule']);
        } else if (accordion_messageSection && component.get("v.selectedActiveSectionName") === 'Message') {
            component.find("accordion_message").set("v.activeSectionName", ['Message']);
        } else if (accordion_previewSection && component.get("v.selectedActiveSectionName") === 'Preview') {
            component.find("accordion_preview").set("v.activeSectionName", ['Preview']);
        }
    },

    handleViewTotalRecipients: function (component, event, helper) {
        helper.viewTotalRecipientsJS(component, helper);
    },

    handleValidatedForm: function (component, event, helper) {
        return helper.validatedFormJS(component, helper);
    },
    handleSectionToggle: function (cmp, evt, hlpr) {
        hlpr.jsSectionToggle(cmp, evt, hlpr);
    },
    handleCreteriaChanged: function (cmp, evt, hlpr) {
        hlpr.jsCreteriaChanged(cmp, evt, hlpr);
    },
    handleChangesObjectFilterBase: function (cmp, evt, hlpr) {
        hlpr.jsChangesObjectFilterBase(cmp, evt, hlpr);
    },
    handleChangesObjectFilterRelated: function (cmp, evt, hlpr) {
        hlpr.jsChangesObjectFilterRelated(cmp, evt, hlpr);
    },
    handleToEmailChange : function (cmp, evt, hlpr) {
        hlpr.jsToEmailChange(cmp, evt, hlpr);
    },
    handleChangesObjectToEmailSelector: function (cmp, evt, hlpr) {
        hlpr.jsChangesObjectToEmailSelector(cmp, evt, hlpr);
    },
    handleFromEmailAddressChange: function (cmp, evt, hlpr) {
        hlpr.jsFromEmailAddressChange(cmp, evt, hlpr);
    },
    handleAssociateReferenceChange: function (cmp, evt, hlpr) {
        hlpr.jsAssociateReferenceChange(cmp, evt, hlpr);
    },
})