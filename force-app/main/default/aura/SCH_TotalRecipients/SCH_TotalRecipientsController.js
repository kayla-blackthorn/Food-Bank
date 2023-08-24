({
    doInit: function (component, event, helper) {
        helper.fetchTotalRecipientsJS(component, helper);
    },
    handleHideTotalRecipients: function (component, event, helper) {
        helper.hideTotalRecipientsJS(component, helper);
    },
})