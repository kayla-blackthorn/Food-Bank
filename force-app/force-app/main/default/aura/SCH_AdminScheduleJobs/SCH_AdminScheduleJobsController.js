({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },
    handleRefreshData: function (component, event, helper) {
        var isShowCreateNewSchedules = component.get("v.isShowCreateNewSchedule");
        var isShowConfirmModal = component.get("v.isShowConfirmModal");
        if (isShowCreateNewSchedules == false && isShowConfirmModal == false) {
            if (component.get("v.isBack") == false) {
                helper.jsDoInit(component, helper);
            }
            component.set("v.isBack", false);
            component.set("v.existingScheduleId", null);
        } else if (component.get("v.isShowConfirmModal") == false) {
            if (component.get("v.isBack") == false) {
                helper.jsDoInit(component, helper);
            }
            component.set("v.isBack", false);
        }
    },
    handleCreateNewSchedule: function (component, event, helper) {
        helper.createNewScheduleJS(component);
    },
    manageAuthenticatedUser: function (component, event, helper) {
        helper.manageAuthenticatedUserJS(component);
    },
    handleScheduleRowAction: function (component, event, helper) {
        helper.scheduleRowActionJS(component, event, helper);
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
    handleLoadMoreData: function (component, event, helper) {
        helper.loadMoreDataJS(component, helper);
    }
})