({
    fetchSchedulerAction: function (component, helper) {
        helper.serverConnect(component, helper, 'isBTPackageInstalled', {}, helper._simpleSMSPackageInstalled);
    },

    _simpleSMSPackageInstalled: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        helper._processSMSResponse(component, helper, result);
    },

    _processSMSResponse: function (cmp, hlpr, result) {
        let data = {
            'result': result,
            'recordLevel': true
        }
        hlpr.processAndPrepareSMSResponse(cmp, hlpr, data);
        cmp.set("v.packageData", data.packageData);
        if (data.allowSchedule) {
            let currentpage = 1;
            cmp.set("v.current_page", currentpage);
            let params = hlpr._getParametersOptions(cmp);
            hlpr.serverConnect(cmp, hlpr, 'getAdminSchedules', {
                actionType: params.selectedActionType,
                scheduleType: params.selectedScheduleType,
                status: params.selectedStatus,
                isIncludeArchived: cmp.get("v.isIncludeArchived"),
                recordId: cmp.get("v.recordId"),
                currentPage: currentpage,
                pageSize: cmp.get("v.page_size"),
                isGlobal: false
            }, hlpr._adminGetScheduleJS);
            hlpr.serverConnect(cmp, hlpr, 'fetchTimeZoneName', {
				recordId: cmp.get("v.recordId")
			}, hlpr._eventTimeZoneInfoJS);
        }
        cmp.set("v.allowSchedule", data.allowSchedule);
        cmp.set("v.helpLinks", result.helpLinks);
    },

    _eventTimeZoneInfoJS: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        if (!$A.util.isUndefinedOrNull(result) && !$A.util.isEmpty(result)) {
            component.set("v.userTimeZone", result);
        }
    },

    _adminGetScheduleJS: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        var columns = result.columns;
        if (!$A.util.isUndefinedOrNull(columns)) {
            var rowActions = helper.getRowLevelActions.bind(helper, component);
            columns.push({
                type: 'action',
                typeAttributes: {
                    rowActions: rowActions
                }
            });
        }
        if (columns) {
            columns.forEach(function (col) {
                if (col && col.cellAttributes && col.cellAttributes.hasOwnProperty('bClass')) {
                    col.cellAttributes.class = col.cellAttributes.bClass;
                    delete col.cellAttributes.bClass;
                }
            })
        }
        if (result.scheduleData) {
            result.scheduleData.forEach(function (col) {
                col.NextExecutionDateTimeStatus = col.NextExecutionDateTime + (!$A.util.isUndefinedOrNull(col.NextExecutionStatus) ? ' [' + col.NextExecutionStatus + ']' : '');
            })
        }
        component.set("v.columns", columns);
        component.set("v.enableInfiniteLoading", result.has_next);
        component.set("v.data", result.scheduleData);
        component.set("v.totalRecords", result.total_records);
    },

    getRowLevelActions: function (cmp, row, doneCallback) {
        let data = {
            row: row,
            account: cmp.get("v.packageData.btScheduleAccount")
        }
        this.prepareRowActions(data);
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(data.actions);
        }), 200);
    },

    createNewMessageJS: function (component) {
        component.set("v.isShowCreateNewMessageComp", true);
    },

    rowActionJSHelper: function (component, event, helper) {
        let action = event.getParam('action');
        let row = event.getParam('row');
        helper.processRowAction(component, helper, {
            "row": row,
            "action": action,
            "recipientObjectName": "selectScheduleAttendees",
            "isShowCreateNewSchedule":"isShowCreateNewMessageComp"
        });
    },

    _relatedRelationshipFieldName: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        component.set("v.filter", result);
        component.set("v.isShowTotalRecipientsModal", true);
        component.set("v.spinner", '');
    },

    _updateScheduleResponse: function (component, helper, response, cbInfo) {
        helper.fetchSchedulerAction(component, helper);
    },

    loadMoreDataJS: function (component, helper) {
        let currentpage = component.get("v.current_page");
        currentpage++;
        component.set("v.current_page", currentpage);
        let params = helper._getParametersOptions(component);
        helper.serverConnect(component, helper, 'getAdminSchedules', {
            actionType: params.selectedActionType,
            scheduleType: params.selectedScheduleType,
            status: params.selectedStatus,
            isIncludeArchived: component.get("v.isIncludeArchived"),
            recordId: component.get("v.recordId"),
            currentPage: currentpage,
            pageSize: component.get("v.page_size"),
            isGlobal: false
        }, helper._adminLoadMoreScheduleJS);
    },

    _adminLoadMoreScheduleJS: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        component.set("v.enableInfiniteLoading", result.has_next);
        var currentData = component.get('v.data');
        if (result.scheduleData) {
            result.scheduleData.forEach(function (col) {
                col.NextExecutionDateTimeStatus = col.NextExecutionDateTime + (!$A.util.isUndefinedOrNull(col.NextExecutionStatus) ? ' [' + col.NextExecutionStatus + ']' : '');
            })
        }
        var newData = currentData.concat(result.scheduleData);
        component.set("v.data", newData);
    },
    applyFilterJS: function (cmp, hlpr) {
        cmp.set("v.spinner", 'main-loading');
        cmp.set("v.data", []);
        cmp.set("v.totalRecords", 0);
        if (cmp.get("v.allowSchedule")) {
            let currentpage = 1;
            cmp.set("v.current_page", currentpage);
            let params = hlpr._getParametersOptions(cmp);
            hlpr.serverConnect(cmp, hlpr, 'getAdminSchedules', {
                actionType: params.selectedActionType,
                scheduleType: params.selectedScheduleType,
                status: params.selectedStatus,
                isIncludeArchived: cmp.get("v.isIncludeArchived"),
                recordId: cmp.get("v.recordId"),
                currentPage: currentpage,
                pageSize: cmp.get("v.page_size"),
                isGlobal: false
            }, hlpr._adminGetScheduleJS);
        }
        cmp.set('v.showFilter', !cmp.get('v.showFilter'));
    },
    refreshJS: function (cmp, hlpr) {
        cmp.set("v.spinner", 'main-loading');
        cmp.set("v.data", []);
        cmp.set("v.totalRecords", 0);
        if (cmp.get("v.allowSchedule")) {
            let currentpage = 1;
            cmp.set("v.current_page", currentpage);
            let params = hlpr._getParametersOptions(cmp);
            hlpr.serverConnect(cmp, hlpr, 'getAdminSchedules', {
                actionType: params.selectedActionType,
                scheduleType: params.selectedScheduleType,
                status: params.selectedStatus,
                isIncludeArchived: cmp.get("v.isIncludeArchived"),
                recordId: cmp.get("v.recordId"),
                currentPage: currentpage,
                pageSize: cmp.get("v.page_size"),
                isGlobal: false
            }, hlpr._adminGetScheduleJS);
        }
    },
    _getParametersOptions: function (component) {
        var parametersOptions = {
            'selectedScheduleType': '',
            'selectedStatus': '',
            'selectedActionTypeOptions': ''
        };

        let selectedScheduleTypeOptions = component.get("v.selectedScheduleTypeOptions");
        if (!$A.util.isUndefinedOrNull(selectedScheduleTypeOptions) && !$A.util.isEmpty(selectedScheduleTypeOptions)) {
            parametersOptions.selectedScheduleType = selectedScheduleTypeOptions.join(',');
        }

        let selectedStatusOptions = component.get("v.selectedStatusOptions");
        if (!$A.util.isUndefinedOrNull(selectedStatusOptions) && !$A.util.isEmpty(selectedStatusOptions)) {
            parametersOptions.selectedStatus = selectedStatusOptions.join(',');
        }

        let selectedActionTypeOptions = component.get("v.selectedActionTypeOptions");
        if (!$A.util.isUndefinedOrNull(selectedActionTypeOptions) && !$A.util.isEmpty(selectedActionTypeOptions)) {
            if (selectedActionTypeOptions.length == 2) {
                parametersOptions.selectedActionType = 'all';
            } else {
                parametersOptions.selectedActionType = selectedActionTypeOptions.join(',');
            }
        }
        return parametersOptions;
    }

})