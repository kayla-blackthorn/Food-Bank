({
    closeExecutionModalJS: function (component, helper) {
        component.set("v.showAllExecution", false);
    },
    jsDoInit: function (component, helper) {
        component.set("v.current_page", 1);
        let selectedExecutionSFId = component.get("v.selectedExecutionSFId");
        if (!$A.util.isUndefinedOrNull(selectedExecutionSFId)) {
            helper.serverConnect(component, helper, 'getAllLogsForExecution', {
                recordId: component.get("v.scheduleData.schedule_Id"),
                executionId: selectedExecutionSFId,
                currentPage: component.get("v.current_page"),
                pageSize: component.get("v.page_size"),
                nameFieldToReplace: component.get("v.nameFieldToReplace"),
                isDisplayFailedOnly: !component.get("v.isDisplayFailedOnly")
            }, helper._AllExecutionsForScheduleJS);
        } else {
            helper.serverConnect(component, helper, 'getAllExecutionsForSchedule', {
                recordId: component.get("v.scheduleData.schedule_Id"),
                currentPage: component.get("v.current_page"),
                pageSize: component.get("v.page_size"),
                nameFieldToReplace: component.get("v.nameFieldToReplace"),
                isDisplayFailedOnly: !component.get("v.isDisplayFailedOnly")
            }, helper._AllExecutionsForScheduleJS);
        }
    },

    _AllExecutionsForScheduleJS: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        let columns = result.columns;
        let selectedExecutionSFId = component.get("v.selectedExecutionSFId");
        if ($A.util.isUndefinedOrNull(selectedExecutionSFId)) {
            let actions = [];
            actions.push({
                name: 'view_detail',
                label: $A.get("$Label.c.SCH_SS_action_view_detail")
            });
            columns.push({
                type: 'action',
                typeAttributes: {
                    rowActions: actions
                }
            });
        }
        if (columns) {
            columns.forEach(function (col) {
                if (!col.cellAttributes) {
                    col.cellAttributes = {};
                }
                if (col.cellAttributes.hasOwnProperty('bClass')) {
                    col.cellAttributes.class = col.cellAttributes.bClass;
                    delete col.cellAttributes.bClass;
                }
            })
        }
        component.set("v.columns", columns);
        component.set("v.data", result.logsData);
        component.set("v.enableInfiniteLoading", result.has_next);
        component.set("v.totalRecords", result.total_records);
        let isRetryFailedOnly = false;
        let defaultShowAll = component.get("v.defaultShowAll");
        if (result.failed_log_count && result.failed_log_count > 0 && selectedExecutionSFId) {
            isRetryFailedOnly = true;
        } else if (defaultShowAll) {
            component.set("v.defaultShowAll", false);
            component.set("v.isDisplayFailedOnly", true);
        }
        component.set("v.isShowRetryFailedOnly", isRetryFailedOnly);
    },

    loadMoreDataJS: function (component, helper) {
        let currentpage = component.get("v.current_page");
        currentpage++;
        component.set("v.current_page", currentpage);
        let selectedExecutionSFId = component.get("v.selectedExecutionSFId");
        if (selectedExecutionSFId) {
            helper.serverConnect(component, helper, 'getAllLogsForExecution', {
                recordId: component.get("v.scheduleData.schedule_Id"),
                executionId: selectedExecutionSFId,
                currentPage: currentpage,
                pageSize: component.get("v.page_size"),
                nameFieldToReplace: component.get("v.nameFieldToReplace"),
                isDisplayFailedOnly: !component.get("v.isDisplayFailedOnly")
            }, helper._LoadMoreAllExecutionsForScheduleJS);
        } else {
            helper.serverConnect(component, helper, 'getAllExecutionsForSchedule', {
                recordId: component.get("v.scheduleData.schedule_Id"),
                currentPage: currentpage,
                pageSize: component.get("v.page_size"),
                nameFieldToReplace: component.get("v.nameFieldToReplace"),
                isDisplayFailedOnly: !component.get("v.isDisplayFailedOnly")
            }, helper._LoadMoreAllExecutionsForScheduleJS);
        }
    },

    _LoadMoreAllExecutionsForScheduleJS: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        component.set("v.enableInfiniteLoading", result.has_next);
        let currentData = component.get('v.data');
        let newData = currentData.concat(result.logsData);
        component.set("v.data", newData);
    },
    jsExecutionRowAction : function (component, event, helper){
        let action = event.getParam('action');
        let row = event.getParam('row');
        if (action.name == 'view_detail') {
            component.set("v.selectedExecutionSFId", row.salesforce_id);
            component.set("v.selectedExecutionSFName", row.parent_log_name);
            component.set("v.columns", []);
            component.set("v.data", []);
            component.set("v.enableInfiniteLoading", true);
            helper.jsDoInit(component, helper);
        }
    },
    jsResetExecution: function (component, event, helper) {
        component.set("v.selectedExecutionSFId", null);
        component.set("v.selectedExecutionSFName", null);
        component.set("v.defaultShowAll", true);
        helper.jsResetData(component, event, helper);
    },
    jsResetData: function (component, event, helper) {
        component.set("v.columns", []);
        component.set("v.data", []);
        component.set("v.enableInfiniteLoading", true);
        helper.jsDoInit(component, helper);
    },
    jsRetryFailedOnly: function (component, event, helper) {
        helper.serverConnect(component, helper, 'retryFailedRecords', {
            recordId: component.get("v.scheduleData.schedule_Id"),
            executionId: component.get("v.selectedExecutionSFId").replace('/', '')
        }, helper._RetryFailedOnlyJS);
    },
    _RetryFailedOnlyJS: function (component, helper, response, cbInfo) {
        helper.jsResetData(component, null, helper);
        helper.showToast(component, helper, $A.get("$Label.c.SCH_SS_Retry_Failed_Records_Success"), 10000, 'success');
    },
    jsResendExecutionStatusEmail: function (component, event, helper) {
        helper.serverConnect(component, helper, 'resendStatusEmail', {
            recordId: component.get("v.scheduleData.schedule_Id"),
            executionId: component.get("v.selectedExecutionSFId").replace('/', '')
        }, helper._ResendExecutionStatusEmailJS);
    },
    _ResendExecutionStatusEmailJS: function (component, helper, response, cbInfo) {
        helper.jsResetData(component, null, helper);
        helper.showToast(component, helper, $A.get("$Label.c.SCH_SS_Resend_Execution_Status_Success"), 10000, 'success');
    },
    showToast: function (component, helper, message, duration, type) {
        (this)._showMessage(component, {
            message: message,
            type: type
        });
    },
})