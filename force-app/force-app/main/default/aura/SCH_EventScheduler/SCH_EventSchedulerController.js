({
    doInit: function (component, event, helper) {
        helper.fetchSchedulerAction(component, helper);
    },
    handleRefreshData: function (component, event, helper) {
        var isShowCreateNewMessage = component.get("v.isShowCreateNewMessageComp");
        var isShowConfirmModal = component.get("v.isShowConfirmModal");

        if (isShowCreateNewMessage == false && isShowConfirmModal == false) {
            if (component.get("v.isBack") == false) {
                helper.fetchSchedulerAction(component, helper);
            }
            component.set("v.existingScheduleId", null);
            component.set("v.isBack", false);
        } else if (component.get("v.isShowConfirmModal") == false) {
            if (component.get("v.isBack") == false) {
                helper.fetchSchedulerAction(component, helper);
            }
            component.set("v.isBack", false);
        }
    },
    handleRowAction: function (component, event, helper) {
        helper.rowActionJSHelper(component, event, helper);
    },
    handleCreateNewMessage: function (component, event, helper) {
        helper.createNewMessageJS(component);
    },
    handleLoadMoreData: function (component, event, helper) {
        helper.loadMoreDataJS(component, helper);
    },
    handleFilterClick: function (component, event, helper) {
        component.set('v.showFilter', !component.get('v.showFilter'));
    },
    handleApplyFilter: function (component, event, helper) {
        helper.applyFilterJS(component, helper);
    },
    handleRefresh: function (component, event, helper) {
        helper.refreshJS(component, helper);
    },
})