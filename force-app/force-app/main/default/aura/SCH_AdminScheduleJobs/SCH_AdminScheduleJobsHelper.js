({
	jsDoInit: function (component, helper) {
		if (component.get("v.account.scheduleFeatureEnabled") == true) {
			component.set("v.spinner", 'main-loading');
			helper.serverConnect(component, helper, 'isBTPackageInstalled', {}, helper._simpleSMSPackageInstalled);
		}
	},

	adminSchedulesJSHelper: function (component, helper) {
		let currentpage = 1;
		component.set("v.current_page", currentpage);
		helper.jsGetAdminSchedules(component, helper, currentpage);
	},
	getRowActions: function (cmp, row, doneCallback) {
		let data = {
		    row: row,
		    account: cmp.get("v.account")
		}
		this.prepareRowActions(data);
		// simulate a trip to the server
		setTimeout($A.getCallback(function () {
		    doneCallback(data.actions);
		}), 200);
	},
	createNewScheduleJS: function (component) {
		component.set("v.showFilter", false);
		component.set("v.isShowCreateNewSchedule", true);
	},

	_simpleSMSPackageInstalled: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		helper._processSMSResponse(component, helper, result);
	},
	_processSMSResponse: function (cmp, hlpr, result) {
		let data = {
            'result': result,
            'recordLevel': false
        }
        hlpr.processAndPrepareSMSResponse(cmp, hlpr, data);
        cmp.set("v.packageData", data.packageData);
		if (data.allowSchedule) {
			hlpr.adminSchedulesJSHelper(cmp, hlpr);
		}
		cmp.set("v.allowSchedule", data.allowSchedule);
		cmp.set("v.helpLinks", result.helpLinks);
	},

	manageAuthenticatedUserJS: function (cmp) {
		cmp.set("v.currentPage", "account-info");
	},

	scheduleRowActionJS: function (component, event, helper) {
		let action = event.getParam('action');
		let row = event.getParam('row');
		component.set("v.showFilter", false);
		helper.processRowAction(component, helper, {
		    "row": row,
		    "action": action,
		    "recipientObjectName": "recipientObjectName",
		    "isShowCreateNewSchedule": "isShowCreateNewSchedule"
		});
	},

	_relatedRelationshipFieldName: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		component.set("v.filter", result);
		component.set("v.isShowTotalRecipientsModal", true);
		component.set("v.spinner", '');
	},

	_updateScheduleResponse: function (component, helper, response, cbInfo) {
		helper.jsDoInit(component, helper);
	},

	applyFilterJS: function (component, helper) {
		component.set("v.spinner", 'main-loading');
		component.set("v.data", []);
		component.set("v.totalRecords", 0);
		helper.adminSchedulesJSHelper(component, helper);
		component.set('v.showFilter', !component.get('v.showFilter'));
	},

	refreshJS: function (component, helper) {
		component.set("v.spinner", 'main-loading');
		component.set("v.data", []);
		component.set("v.totalRecords", 0);
		helper.adminSchedulesJSHelper(component, helper);
	},

	loadMoreDataJS: function (component, helper) {
		let currentpage = component.get("v.current_page");
		currentpage++;
		component.set("v.current_page", currentpage);
		helper.jsGetAdminSchedules(component, helper, currentpage);
	},
	jsGetAdminSchedules: function (cmp, hlpr, currentPage) {
		let params = hlpr._getParametersOptions(cmp);
		hlpr.serverConnect(cmp, hlpr, 'getAdminSchedules', {
			actionType: params.selectedActionType,
			scheduleType: params.selectedScheduleType,
			status: params.selectedStatus,
			isIncludeArchived: cmp.get("v.isIncludeArchived"),
			recordId: '',
			currentPage: currentPage,
			pageSize: cmp.get("v.page_size"),
			isGlobal: true
		}, hlpr._GetAdminSchedulesCB);
	},
	_GetAdminSchedulesCB: function (cmp, hlpr, response, cbInfo) {
		var result = response.getReturnValue();
		var currentData = cmp.get('v.data');
		if (cmp.get("v.current_page") == 1) {
			currentData = [];
			var columns = result.columns;
			if (!$A.util.isUndefinedOrNull(columns)) {
				var rowActions = hlpr.getRowActions.bind(hlpr, cmp);
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
			cmp.set("v.columns", columns);
		}
		if (result.scheduleData) {
			result.scheduleData.forEach(function (col) {
				col.NextExecutionDateTimeStatus = col.NextExecutionDateTime + (!$A.util.isUndefinedOrNull(col.NextExecutionStatus) ? ' [' + col.NextExecutionStatus + ']' : '');
			})
		}
		var newData = currentData.concat(result.scheduleData);
		cmp.set("v.data", newData);
		cmp.set("v.enableInfiniteLoading", result.has_next);
		cmp.set("v.totalRecords", result.total_records);
		cmp.set("v.spinner", '');
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