({
    handleEmailTemplateSelected: function (cmp, evt, hlpr) {
        hlpr.jsEmailTemplateSelected(cmp, evt, hlpr);
    },
    handlePrevious: function (cmp, evt, hlpr) {
        hlpr.jsPrevious(cmp, evt, hlpr);
    },
    handleNext: function (cmp, evt, hlpr) {
        hlpr.jsNext(cmp, evt, hlpr);
    },
    handleCreateNewEmailTemplate: function (cmp, evt, hlpr) {
        hlpr.jsCreateNewEmailTemplate(cmp, evt, hlpr);
    },
    handleValidatedForm: function (component, event, helper) {
        return helper.validatedFormJS(component, helper);
    },
})