({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },
    handleCloseExecutionModal: function (component, event, helper) {
        helper.closeExecutionModalJS(component, helper);
    },
    handleLoadMoreData: function (component, event, helper) {
        helper.loadMoreDataJS(component, helper);
    },
    handleChangeDisplayFailedOnly: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },
    handleExecutionRowAction: function (component, event, helper) {
        helper.jsExecutionRowAction(component, event, helper);
    },
    handleBack: function (component, event, helper) {
        helper.jsResetExecution(component, event, helper);
    },
    handleRetryFailedOnly: function (component, event, helper) {
        helper.jsRetryFailedOnly(component, event, helper);
    },
    handleResendExecutionStatusEmail: function (component, event, helper) {
        helper.jsResendExecutionStatusEmail(component, event, helper);
    }
})