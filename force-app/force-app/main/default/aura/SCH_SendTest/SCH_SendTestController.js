({
    handleInit: function (cmp, evt, hlpr) {
        hlpr.jsInit(cmp, evt, hlpr);
    },
    handleResetInit: function (cmp, evt, hlpr) {
        hlpr.jsInit(cmp, evt, hlpr);
    },
    handleRecordSelected: function (component, event, helper) {
        helper.jsRecordSelected(component, event, helper);
    },
    handlePrevious: function (component, event, helper) {
        helper.previousJS(component, helper);
    },
    handleSendTest: function (component, event, helper) {
        helper.jsSendTest(component, helper);
    },
})