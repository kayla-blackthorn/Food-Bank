({
    jsCloseConfirmModal: function (component) {
        component.set("v.isBack", true);
        component.set("v.isShowConfirmModal", false);
    },
    jsConfirm: function (component, helper) {
        helper.serverConnect(component, helper, component.get("v.action_name"), {
            recordId: component.get("v.salesforce_id"),
            status: component.get("v.status")
        }, helper._updateScheduleResponse);
    },
    _updateScheduleResponse: function (component, helper, response, cbInfo) {
        component.set("v.isShowConfirmModal", false);
    },
})