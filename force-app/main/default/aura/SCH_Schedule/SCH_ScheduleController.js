({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component);
    },

    handlePrevious: function (component, event, helper) {
        component.set("v.selectedActiveSectionName", "Recipients");
    },

    handleNext: function (component, event, helper) {
        helper.nextJS(component, helper, false);
    },

    handleScheduleNext: function (component, event, helper) {
        return helper.nextJS(component, helper, true);
    },

    handleDateTimeChange: function (component, event, helper) {
        helper.dateTimeChangeJS(component, event, helper);
    },

    handleExecuteNowUpdate: function (component, event, helper) {
        helper.executeNowUpdateJS(component, helper);
    },

    handleDaysChange: function (component, event, helper) {
        helper.jsDaysChange(component, event, helper);
    }

})