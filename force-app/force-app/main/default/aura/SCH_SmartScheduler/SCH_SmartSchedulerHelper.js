({
	jsDoInit: function (component, helper) {
		component.set("v.spinner", "sch-loading");
		component.set('v.scheduleObj.baseObjectCriteria', 'matchCriteria');
		component.set('v.scheduleObj.relatedObjectCriteria', 'matchCriteria');
		component.set('v.scheduleObj.baseObjectCriteriaFilters', []);
		component.set('v.scheduleObj.relatedObjectCriteriaFilters', []);
		helper.serverConnect(component, helper, 'getInitData', {}, helper._GetInitData);
		helper._prepareScheduleObj(component);
		let account = component.get("v.account");
		if (!$A.util.isUndefinedOrNull(account) && !$A.util.isEmpty(account) && (!account.featureScheduleEmail || !account.featureScheduleSMS)) {
			component.set("v.isDisabled", true);
			if (account.featureScheduleSMS) {
				component.set("v.scheduleObj.Action", 'SMS');
			} else if (account.featureScheduleEmail) {
				component.set("v.scheduleObj.Action", 'Email');
			}
		}

		let recordId = component.get("v.recordId");
		if (recordId != null && recordId != undefined) {
			component.set("v.scheduleObj.Base_Object", 'conference360__Event__c');
			component.set("v.scheduleObj.Base_Object_Label", 'Event');
			component.set("v.scheduleObj.Related_Object", 'conference360__Attendee__c');
			component.set("v.scheduleObj.Related_Object_Label", 'Event Attendees');
			component.set("v.scheduleObj.Related_Object_Relationship_Name", "conference360__Event__r");
			component.set("v.scheduleObj.Related_Object_FieldAPIName", "conference360__Event__c");
			component.set("v.scheduleObj.Base_Object_Evaluate_Criteria", 'Id=' + "'" + recordId + "'");
			component.set("v.scheduleObj.SObject_RecordId", recordId);
			component.set("v.scheduleObj.Type", 'record');
			helper.serverConnect(component, helper, 'fetchEventDetail', {
				recordId: component.get("v.recordId")
			}, helper._eventInfoJS);
			helper._maintainScheduleField(component, helper, {
				objectName: 'conference360__Attendee__c',
				isBaseChange: true,
				isSetBaseSobjectFields: true
			});
		}
		let existingScheduleId = component.get("v.existingScheduleId");
		if (existingScheduleId) {
			helper.initExistingScheduleJS(component, helper);
		}
	},

	_GetInitData: function (cmp, hlpr, response, cbInfo) {
		var result = response.getReturnValue();
		if (!$A.util.isUndefinedOrNull(result.helpLinks) && !$A.util.isEmpty(result.helpLinks) && !$A.util.isUndefinedOrNull(result.helpLinks.attendee_registration_status) && !$A.util.isEmpty(result.helpLinks.attendee_registration_status)) {
			cmp.set("v.scheduleObj.attendee_registration_status", result.helpLinks.attendee_registration_status);
		}
		if (!$A.util.isUndefinedOrNull(result.helpLinks) && !$A.util.isEmpty(result.helpLinks) && !$A.util.isUndefinedOrNull(result.helpLinks.BT_Support_Team) && !$A.util.isEmpty(result.helpLinks.BT_Support_Team)) {
			cmp.set("v.scheduleObj.BT_Support_Team", result.helpLinks.BT_Support_Team);
		}
		cmp.set("v.helpLinks", result.helpLinks);
		cmp.set("v.globalDescribeMap", result.globalsObjectDescribe);

		var baseObjectOptionsCmp = cmp.find("baseObjectOptions");
		if (baseObjectOptionsCmp) {
			baseObjectOptionsCmp.globalDescrieMapUpdate(result.globalsObjectDescribe);
		}

		cmp.set("v.emailBalance", result.emailBalance);
		hlpr._processSMSResponse(cmp, hlpr, result.smsResult);
	},

	initExistingScheduleJS: function (component, helper) {
		let existingScheduleId = component.get("v.existingScheduleId");
		if (!$A.util.isUndefinedOrNull(existingScheduleId) && !$A.util.isEmpty(existingScheduleId)) {
			component.set("v.isDisabled", true);
			component.set("v.allowSchedule", false);
			helper._prepareScheduleObj(component);
			helper.serverConnect(component, helper, 'getScheduleWithActions', {
				recordId: existingScheduleId
			}, helper._prepareScheduleActions);
		}
	},

	_prepareScheduleActions: function (cmp, hlpr, response, cbInfo) {
		var result = response.getReturnValue();
		if (!$A.util.isUndefinedOrNull(result) && !$A.util.isEmpty(result)) {
			let scheduleObj = cmp.get("v.scheduleObj");
			cmp.set("v.recordId", result[0].bt_base__SObject_Record_Id__c);
			cmp.set("v.scheduleObj.Action", result[0].bt_base__Schedule_Actions__r[0].bt_base__Action__c);
			cmp.set("v.scheduleObj.Status", result[0].bt_base__Status__c);
			cmp.set("v.scheduleObj.Type", result[0].bt_base__Type__c);
			cmp.set("v.scheduleObj.Base_Object", result[0].bt_base__Base_Object__c);
			cmp.set("v.scheduleObj.Base_Object_Evaluate_Criteria", result[0].bt_base__Base_Object_Evaluate_Criteria__c);
			cmp.set("v.scheduleObj.SObject_RecordId", result[0].bt_base__SObject_Record_Id__c);
			cmp.set("v.allowSchedule", true);
			cmp.set("v.scheduleObj.Related_Object", ((!$A.util.isUndefinedOrNull(result[0].bt_base__Related_Object__c) && !$A.util.isEmpty(result[0].bt_base__Related_Object__c)) ? result[0].bt_base__Related_Object__c : ''));
			cmp.set("v.scheduleObj.Related_Object_Evaluate_Criteria", result[0].bt_base__Related_Object_Evaluate_Criteria__c);
			cmp.set("v.scheduleObj.baseObjectCriteria", ((!$A.util.isUndefinedOrNull(result[0].bt_base__Base_Object_Evaluate_Criteria__c) && !$A.util.isEmpty(result[0].bt_base__Base_Object_Evaluate_Criteria__c)) ? 'matchCriteria' : 'noCriteria'));
			cmp.set("v.scheduleObj.relatedObjectCriteria", ((!$A.util.isUndefinedOrNull(result[0].bt_base__Related_Object_Evaluate_Criteria__c) && !$A.util.isEmpty(result[0].bt_base__Related_Object_Evaluate_Criteria__c)) ? 'matchCriteria' : 'noCriteria'));

			cmp.set("v.scheduleObj.Related_Object_Relationship_Name", result[0].bt_base__Related_Object_Relationship_Name__c);
			let relatedObjectOptions = cmp.find("relatedObjectOptions");
			if (relatedObjectOptions && !$A.util.isUndefinedOrNull(result[0].bt_base__Related_Object__c)) {
				relatedObjectOptions.relatedObjectvalueUpdate(result[0].bt_base__Related_Object__c);
			}
			if (!$A.util.isUndefinedOrNull(result[0].bt_base__Base_Object_Evaluate_Criteria_JSON__c) && !$A.util.isEmpty(result[0].bt_base__Base_Object_Evaluate_Criteria_JSON__c)) {
				var criteriaObj;
				try {
					criteriaObj = JSON.parse(result[0].bt_base__Base_Object_Evaluate_Criteria_JSON__c);
				} catch (error) {
					console.log(error);
				}
				if (!$A.util.isUndefinedOrNull(criteriaObj) && !$A.util.isEmpty(criteriaObj)) {
					if (result[0].bt_base__Type__c && result[0].bt_base__Type__c.toLowerCase() === 'object') {
						cmp.set("v.scheduleObj.baseObjectCriteriaFilters", criteriaObj);
					}
				}
			}
			if (!$A.util.isUndefinedOrNull(result[0].bt_base__Related_Object_Evaluate_Criteria_JSON__c) && !$A.util.isEmpty(result[0].bt_base__Related_Object_Evaluate_Criteria_JSON__c)) {
				var criteriaObj;
				try {
					criteriaObj = JSON.parse(result[0].bt_base__Related_Object_Evaluate_Criteria_JSON__c);
				} catch (error) {
					console.log(error);
				}
				if (!$A.util.isUndefinedOrNull(criteriaObj) && !$A.util.isEmpty(criteriaObj)) {
					if (result[0].bt_base__Type__c && result[0].bt_base__Type__c.toLowerCase() === 'object') {
						cmp.set("v.scheduleObj.relatedObjectCriteriaFilters", criteriaObj);
					} else {
						cmp.set("v.scheduleObj.selectedAttendeeFilter", criteriaObj.filters[0].f);
						if (criteriaObj.filters.length > 1) {
							let selectedValue = criteriaObj.filters[1].val.toString();
							let selectedValueArr = selectedValue.replace('"', '').replaceAll("'", "").split(',');
							cmp.set("v.scheduleObj.selectedAttendeeFilterValue", selectedValueArr);
						}
					}
				}
			}
			cmp.set("v.scheduleobj.Related_Object_Evaluate_Criteria_JSON", result[0].bt_base__Related_Object_Evaluate_Criteria_JSON__c);
			cmp.set("v.scheduleObj.Name", result[0].Name);
			cmp.set("v.scheduleObj.SMS_From_Number", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__SMS_From_Number__c : ''));
			cmp.set("v.scheduleObj.SMS_To_Number", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__SMS_To_Number_Field__c : ''));
			cmp.set("v.scheduleObj.Email_From_Address", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__Email_From_Address__c : ''));
			cmp.set("v.scheduleObj.Email_To_Address", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__Email_To_Address_Field__c : ''));
			cmp.set("v.scheduleObj.Associate_With_Referenced_Record", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__Associate_With_Referenced_Record__c+'' : ''));
			cmp.set("v.scheduleObj.Offset", (result[0].bt_base__Offset__c ? result[0].bt_base__Offset__c : 'before'));
			cmp.set("v.scheduleObj.Offset_Type", (result[0].bt_base__Offset_Type__c ? result[0].bt_base__Offset_Type__c : 'days'));
			cmp.set("v.scheduleObj.Offset_Value", result[0].bt_base__Offset_Value__c);
			let scheduleDateTimeField = result[0].bt_base__Schedule_Date_Time_Field__c;
			let baseObject = result[0].bt_base__Base_Object__c.toLowerCase().trim();
			if (result[0].bt_base__Type__c === 'record' && (baseObject === "conference360__event__c" || baseObject === "conference360__attendee__c" || baseObject === "conference360__session__c" || baseObject === "conference360__session_attendee__c")) {
				scheduleDateTimeField = result[0].bt_base__Base_Object__c + '.' + result[0].bt_base__Schedule_Date_Time_Field__c;
			}
			cmp.set("v.scheduleObj.Schedule_Date_Time_Field", scheduleDateTimeField);
			cmp.set("v.scheduleObj.Schedule_Date_Time", result[0].bt_base__Schedule_Date_Time__c);
			cmp.set("v.scheduleObj.Email_Template_Id", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__Email_Template_Id__c : ''));
			cmp.set("v.scheduleObj.SMS_Message", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__SMS_Message__c : ''));
			cmp.set("v.scheduleObj.SMS_Template_Id", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__SMS_Template_Id__c : ''));
			cmp.set("v.scheduleObj.SMS_Attachment_Id", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].bt_base__SMS_Attachment_Id__c : ''));
			cmp.set("v.scheduleObj.Execute_Now", result[0].bt_base__Execute_Now__c);
			cmp.set("v.scheduleObj.Schedule_Id", result[0].Id);
			cmp.set("v.scheduleObj.Schedule_Action_Id", (result[0].bt_base__Schedule_Actions__r != undefined ? result[0].bt_base__Schedule_Actions__r[0].Id : ''));

			//Fetch Event Record Detail
			if(!$A.util.isUndefinedOrNull(result[0].bt_base__SObject_Record_Id__c) && !$A.util.isEmpty(result[0].bt_base__SObject_Record_Id__c)){
				hlpr.serverConnect(cmp, hlpr, 'fetchEventDetail', {
					recordId: result[0].bt_base__SObject_Record_Id__c
				}, hlpr._eventInfoJS);
			}

			cmp.set("v.currentStep", 4);

		}
	},
	_prepareScheduleObj: function (component) {
		component.set("v.scheduleObj", {
			'Base_Object': '',
			'Base_Object_Label': 'Choose Base Object',
			'Base_Object_Evaluate_Criteria': '',
			'Related_Object': '',
			'Related_Object_Label': 'Choose Related Object',
			'Related_Object_Evaluate_Criteria': '',
			'Related_Object_Evaluate_Criteria_JSON': '',
			'Related_Object_Relationship_Name': '',
			'Related_Object_FieldAPIName': '',
			'Action': 'Email',
			'Status': 'draft',
			'Name': '',
			'SMS_From_Number': '',
			'SMS_To_Number': '',
			'Email_From_Address': '',
			'Email_To_Address': '',
			'Recipient': 0,
			'Offset': 'before',
			'Offset_Type': 'days',
			'Offset_Value': '',
			'Schedule_Date_Time_Field': '',
			'Schedule_Date_Time': '',
			'Type': 'Object',
			'SObject_RecordId': '',
			'Email_Template_Id': '',
			'Email_Template_Name': '',
			'selectedAttendeeFilter': '',
			'selectedAttendeeFilterValue': '',
			'baseObjectCriteria': 'matchCriteria',
			'relatedObjectCriteria': 'matchCriteria',
			'baseObjectCriteriaFilters': [],
			'relatedObjectCriteriaFilters': [],
			'BT_Support_Team': '',
			'AssociateWithReferencedRecordOptions':[],
			'Associate_With_Referenced_Record': false
		});
	},

	_eventInfoJS: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		component.set("v.eventInfo", result);
	},

	_sobjectFieldsWithType: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		result = JSON.parse(result);
		component.set("v.mapSobjectFieldsWithType", result);
		if (cbInfo && cbInfo.isSetBaseSobjectFields) {
			var scheduleDateTimeOptionsArr = [];
			var scheduleObj = component.get("v.scheduleObj");
			if ($A.util.isUndefinedOrNull(scheduleObj.SObject_RecordId) || $A.util.isEmpty(scheduleObj.SObject_RecordId)) {
				var newMap = result['datetime'];
				for (let newMapKey in newMap) {
					let dateTimeFieldLabel = newMap[newMapKey].label;
					dateTimeFieldLabel = dateTimeFieldLabel.replace('GMT (do not use)', '').replace('(do not use)', '').trim();
					scheduleDateTimeOptionsArr.push({
						'label': dateTimeFieldLabel,
						'value': newMap[newMapKey].name
					});
				}
				if (scheduleDateTimeOptionsArr.length > 0) {
					scheduleDateTimeOptionsArr = scheduleDateTimeOptionsArr.sort(function (a, b) {
						return a.label.toLowerCase().localeCompare(b.label.toLowerCase());
					});
				}
			}
			component.set("v.scheduleDateTimeOptions", scheduleDateTimeOptionsArr);
		} else {
			var scheduleObj = component.get("v.scheduleObj");
			if (!$A.util.isUndefinedOrNull(scheduleObj.SObject_RecordId) && !$A.util.isEmpty(scheduleObj.SObject_RecordId) && !$A.util.isUndefinedOrNull(scheduleObj.Base_Object)) {
				if (!$A.util.isUndefinedOrNull(scheduleObj.Related_Object)) {
					helper.serverConnect(component, helper, 'getScheduleDateTimeFields', {
						objectName: scheduleObj.Related_Object
					}, helper._prepareRecordScheduleDateTimeFields);
				}
			}
		}
	},

	_prepareRecordScheduleDateTimeFields: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		var scheduleDateTimeOptionsArr = [];
		if (!$A.util.isUndefinedOrNull(result) && !$A.util.isEmpty(result)) {
			for (let newMapKey in result) {
				newMapKey = newMapKey.replace('GMT (do not use)', '').replace('(do not use)', '').trim();
				scheduleDateTimeOptionsArr.push({
					'label': newMapKey,
					'value': result[newMapKey]
				});
			}
		}
		component.set("v.scheduleDateTimeOptions", scheduleDateTimeOptionsArr);
	},

	selectScheduleTypeJS: function (component, event, helper) {
		var selectedMenuItemValue = event.getParam("value");
		component.set("v.scheduleObj.Action", selectedMenuItemValue);
		component.set("v.scheduleId", '');
		if (!$A.util.isUndefinedOrNull(component.get("v.scheduleObj.Base_Object"))) {
			helper._prepareScheduleObjOnActionChange(component);
			component.set("v.currentStep", 1);
		}
		let allowSMS = component.get("v.allowSMS");
		// everytime checking SMS Package Installed or not untill not install
		if (selectedMenuItemValue === 'SMS') {
			if (allowSMS) {
				helper.serverConnect(component, helper, 'getSMSdetails', {}, helper._GetSMSdetails);

				let relatedObjectAPIName = component.get("v.scheduleObj.Related_Object");
				if (!$A.util.isUndefinedOrNull(relatedObjectAPIName) && !$A.util.isEmpty(relatedObjectAPIName) && relatedObjectAPIName === 'conference360__Session_Attendee__c') {
					relatedObjectAPIName = "conference360__Attendee__c";
					helper.serverConnect(component, helper, 'getSobjectFieldsWithType', {
						objectName: relatedObjectAPIName
					}, helper._sobjectFieldsWithType);
				}
			} else {
				helper.serverConnect(component, helper, 'isSimpleSMSPackageInstalled', {}, helper._simpleSMSPackageInstalled);
			}
		} else {
			helper.serverConnect(component, helper, 'getEmailDetails', {}, helper._GetEmailDetails);
			let relatedObjectAPIName = component.get("v.scheduleObj.Related_Object");
			if (!$A.util.isUndefinedOrNull(relatedObjectAPIName) && !$A.util.isEmpty(relatedObjectAPIName) && relatedObjectAPIName === 'conference360__Session_Attendee__c') {
				component.set("v.scheduleObj.Email_To_Address", '');
				helper.serverConnect(component, helper, 'getSobjectFieldsWithType', {
					objectName: relatedObjectAPIName
				}, helper._sobjectFieldsWithType);
			}
		}
	},

	_simpleSMSPackageInstalled: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		helper._processSMSResponse(component, helper, result);
	},
	_processSMSResponse: function (cmp, hlpr, result) {
		let smsData = result;
		if (!smsData) {
			smsData = {};
		}
		if (!smsData.smsPermissions) {
			smsData.smsPermissions = {}
		}
		if (!smsData.smsAccount) {
			smsData.smsAccount = {};
		}
		let allowSMS = cmp.get("v.allowSMS");
		smsData.isInstalled = result.isInstalled ? result.isInstalled : false;
		smsData.allowInstall = result.allowInstall ? result.allowInstall : false;
		smsData.isSmsAdmin = smsData.smsPermissions.isSmsAdmin ? smsData.smsPermissions.isSmsAdmin : false;
		smsData.accountRegistered = smsData.smsAccount.accountRegistered ? smsData.smsAccount.accountRegistered : false;
		smsData.isConfigured = smsData.smsAccount.isConfigured ? smsData.smsAccount.isConfigured : false;
		smsData.upgradeApp = smsData.smsAccount.upgradeApp ? smsData.smsAccount.upgradeApp : false;
		smsData.smsBalance = smsData.smsAccount.smsBalance;

		cmp.set("v.smsData", smsData);
		if (result.isInstalled && result.accountRegistered) {
			if (smsData.smsPermissions && smsData.smsPermissions.isSmsAllow && smsData.isConfigured && !smsData.upgradeApp) {
				allowSMS = true;
			}
		}
		cmp.set("v.allowSMS", allowSMS);
	},
	_GetSMSdetails: function (cmp, hlpr, response) {
		var result = response.getReturnValue();
		let smsData = cmp.get("v.smsData");
		if (result.smsAccount) {
			smsData.smsBalance = result.smsAccount.smsBalance;
		}
		cmp.set("v.smsData", smsData);
	},
	_GetEmailDetails: function (cmp, hlpr, response) {
		var result = response.getReturnValue();
		cmp.set("v.emailBalance", result.emailBalance ? result.emailBalance : 0);
	},
	// when changing releted sObject dropdown 
	relatedObjectChangeJS: function (component, helper) {
		// Filter configurations
		// related object configurations

		if (!$A.util.isUndefinedOrNull(component.get("v.recordId")) || $A.util.isUndefinedOrNull(component.get("v.existingScheduleId"))) {
			component.set('v.scheduleObj.relatedObjectCriteria', 'matchCriteria');
			component.set('v.scheduleObj.relatedObjectCriteriaFilters', []);
			component.set('v.scheduleObj.Related_Object_Evaluate_Criteria', '');
			component.set('v.scheduleObj.Related_Object_Evaluate_Criteria_JSON', '');
			component.set('v.scheduleObj.selectedAttendeeFilter', '');
			component.set('v.scheduleObj.selectedAttendeeFilterValue', '');
		}

		if ($A.util.isUndefinedOrNull(component.get("v.existingScheduleId"))) {
			component.set("v.currentStep", 1);
			component.set("v.scheduleObj.SMS_From_Number", '');
			component.set("v.scheduleObj.SMS_To_Number", '');
			component.set("v.scheduleObj.Email_From_Address", '');
			component.set("v.scheduleObj.Email_To_Address", '');
			component.set("v.scheduleId", '');
			helper._prepareScheduleObjOnActionChange(component);
		}

		let relatedObjectAPIName = component.get("v.scheduleObj.Related_Object");
		let baseObjectAPIName = component.get("v.scheduleObj.Base_Object");
		if (!$A.util.isUndefinedOrNull(relatedObjectAPIName) && !$A.util.isEmpty(relatedObjectAPIName)) {
			if (relatedObjectAPIName === 'conference360__Session_Attendee__c' && component.get("v.scheduleObj.Action") === 'SMS') {
				relatedObjectAPIName = "conference360__Attendee__c";
			}
			helper.serverConnect(component, helper, 'getSobjectFieldsWithType', {
				objectName: relatedObjectAPIName
			}, helper._sobjectFieldsWithType);
		} else if (!$A.util.isUndefinedOrNull(baseObjectAPIName) && !$A.util.isEmpty(baseObjectAPIName)) {
			helper.serverConnect(component, helper, 'getSobjectFieldsWithType', {
				objectName: baseObjectAPIName
			}, helper._sobjectFieldsWithType);
		}
	},

	baseObjectChangeJS: function (component, helper) {
		// Filter configurations
		// base object configurations
		component.set('v.scheduleObj.baseObjectCriteria', 'matchCriteria');
		component.set('v.scheduleObj.baseObjectCriteriaFilters', []);
		component.set("v.scheduleObj.Base_Object_Evaluate_Criteria", "");
		component.set('v.scheduleObj.Base_Object_Evaluate_Criteria_JSON', '');
		// related object configurations
		component.set('v.scheduleObj.relatedObjectCriteria', 'matchCriteria');
		component.set('v.scheduleObj.relatedObjectCriteriaFilters', []);
		component.set('v.scheduleObj.Related_Object_Evaluate_Criteria', '');
		component.set('v.scheduleObj.Related_Object_Evaluate_Criteria_JSON', '');
		component.set('v.scheduleObj.selectedAttendeeFilter', '');
		component.set('v.scheduleObj.selectedAttendeeFilterValue', '');

		if ($A.util.isUndefinedOrNull(component.get("v.recordId"))) {
			let baseObjectAPIName = component.get("v.scheduleObj.Base_Object");
			if (baseObjectAPIName != null && baseObjectAPIName != '' && baseObjectAPIName != undefined) {
				component.set("v.scheduleObj.SMS_From_Number", '');
				component.set("v.scheduleObj.SMS_To_Number", '');
				component.set("v.scheduleObj.Email_From_Address", '');
				component.set("v.scheduleObj.Email_To_Address", '');
				component.set("v.scheduleObj.Related_Object", '');
				component.set("v.scheduleObj.Related_Object_Label", 'Choose Related Object');
				component.set('v.scheduleObj.Related_Object_FieldAPIName', '');
				component.set('v.scheduleObj.Related_Object_Relationship_Name', '');

				var relatedObjectOptionsCmp = component.find("relatedObjectOptions");
				if (!$A.util.isUndefinedOrNull(relatedObjectOptionsCmp) && !$A.util.isEmpty(relatedObjectOptionsCmp)) {
					relatedObjectOptionsCmp.resetRelatedObjectValueUpdate();
				}

				if ($A.util.isUndefinedOrNull(component.get("v.existingScheduleId"))) {
					component.set("v.currentStep", 1);
				}
				helper._prepareScheduleObjOnActionChange(component);
				helper._maintainScheduleField(component, helper, {
					objectName: baseObjectAPIName,
					isBaseChange: true,
					isSetBaseSobjectFields: true
				});
			}
		} else {
			component.set("v.scheduleObj.Base_Object_Evaluate_Criteria", 'Id=' + "'" + component.get("v.recordId") + "'");
		}
		component.set("v.scheduleId", '');
	},
	_maintainScheduleField: function (cmp, hlpr, data) {
		hlpr.serverConnect(cmp, hlpr, 'getSobjectFieldsWithType', {
			objectName: data.objectName
		}, hlpr._sobjectFieldsWithType, data);
	},
	hideScheduleJS: function (component, helper) {
		component.set("v.isBack", true);
		component.set("v.isShowCreateNewMessageComp", false);
		component.set("v.isDisabled", false);
	},

	saveScheduleJS: function (component, helper) {
		component.set("v.spinner", 'sch-loading');
		var objSchedule = component.get("v.scheduleObj");
		var response = helper.validateForm(component, objSchedule);
		let currentStep = component.get("v.currentStep");
		if (response.isvalid && currentStep >= 3) {
			if((objSchedule.Action == 'Email' && objSchedule.isEmailVerified) || objSchedule.Action == 'SMS'){
				objSchedule.Status = 'Draft';
				let scheduleId = component.get("v.scheduleId");
				let existingScheduleId = component.get("v.existingScheduleId");
				if (!$A.util.isUndefinedOrNull(scheduleId) && !$A.util.isEmpty(scheduleId) && ($A.util.isUndefinedOrNull(existingScheduleId) || $A.util.isEmpty(existingScheduleId))) {
					helper.serverConnect(component, helper, 'createNewScheduleCallout', {
						recordId: scheduleId,
						isSchedule: false
					}, helper._newScheduleCalloutResponse);
				} else {
					helper.serverConnect(component, helper, 'createSchedule', {
						scheduleJSON: JSON.stringify(objSchedule)
					}, helper._createDraftSchudleResponse);
				}
			}else{
				component.set("v.scheduleObj.isShowEmailVerified", true);
				component.set("v.scheduleObj.isScheduleActive", false);
				component.set("v.spinner", '');
			}
		} else {
			if (!$A.util.isUndefinedOrNull(response.message) && !$A.util.isEmpty(response.message)) {
				this.showToast(component, response.message, 1000, 'error');
			}
			component.set("v.spinner", '');
		}
	},

	_createDraftSchudleResponse: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		component.set("v.scheduleId", result);
		let existingScheduleId = component.get("v.existingScheduleId");
		if (!$A.util.isUndefinedOrNull(existingScheduleId) && !$A.util.isEmpty(existingScheduleId)) {
			helper.serverConnect(component, helper, 'updateSchedule', {
				recordId: result,
				status: 'draft'
			}, helper._newScheduleCalloutResponse);
		} else {
			helper.serverConnect(component, helper, 'createNewScheduleCallout', {
				recordId: result,
				isSchedule: false
			}, helper._newScheduleCalloutResponse);
		}
	},

	_createSchudleResponse: function (component, helper, response, cbInfo) {
		var result = response.getReturnValue();
		component.set("v.scheduleId", result);
		let existingScheduleId = component.get("v.existingScheduleId");
		if (!$A.util.isUndefinedOrNull(existingScheduleId) && !$A.util.isEmpty(existingScheduleId)) {
			helper.serverConnect(component, helper, 'updateSchedule', {
				recordId: result,
				status: 'active'
			}, helper._newScheduleCalloutResponse);
		} else {
			helper.serverConnect(component, helper, 'createNewScheduleCallout', {
				recordId: result,
				isSchedule: true
			}, helper._newScheduleCalloutResponse);
		}
	},

	_newScheduleCalloutResponse: function (component, helper, response, cbInfo) {
		component.set("v.isShowCreateNewMessageComp", false);
		component.set("v.scheduleObj.isShowEmailVerified", false);
		component.set("v.spinner", '');
	},

	saveActiveScheduleJS: function (component, helper) {
		component.set("v.spinner", 'sch-loading');
		var objSchedule = component.get("v.scheduleObj");
		var response = helper.validateForm(component, objSchedule);
		let currentStep = component.get("v.currentStep");
		if (response.isvalid && currentStep >= 3) {
			//objSchedule.Status = 'Scheduled';

			var isInsufficientBalance = false;
			if (((objSchedule.Action === 'SMS' && component.get("v.smsData.smsBalance") < objSchedule.Recipient) || (objSchedule.Action === 'Email' && component.get("v.emailBalance") < objSchedule.Recipient))) {
				if (objSchedule.Execute_Now) {
					isInsufficientBalance = true;
				} else if (!objSchedule.Execute_Now && !$A.util.isUndefinedOrNull(objSchedule.Schedule_Date_Time)) {
					let selectedDateTime = objSchedule.Schedule_Date_Time;
					let now = new Date();
					now.setDate(now.getDate() + 1);
					let dtVal = new Date(selectedDateTime);
					if (dtVal.getTime() >= now.getTime()) {
						isInsufficientBalance = false;
					} else {
						isInsufficientBalance = true;
					}
				}
			}

			if (isInsufficientBalance) {
				this.showToast(component, objSchedule.Action + ' balance less than total number of recipient.', 1000, 'error');
				component.set("v.spinner", '');
			} else {
				if((objSchedule.Action == 'Email' && objSchedule.isEmailVerified) || objSchedule.Action == 'SMS'){
					let scheduleId = component.get("v.scheduleId");
					let existingScheduleId = component.get("v.existingScheduleId");
					if (!$A.util.isUndefinedOrNull(scheduleId) && !$A.util.isEmpty(scheduleId) && ($A.util.isUndefinedOrNull(existingScheduleId) || $A.util.isEmpty(existingScheduleId))) {
						helper.serverConnect(component, helper, 'createNewScheduleCallout', {
							recordId: scheduleId,
							isSchedule: true
						}, helper._newScheduleCalloutResponse);
					} else {
						helper.serverConnect(component, helper, 'createSchedule', {
							scheduleJSON: JSON.stringify(objSchedule)
						}, helper._createSchudleResponse);
					}
				}else{
					component.set("v.scheduleObj.isShowEmailVerified", true);
					component.set("v.scheduleObj.isScheduleActive", true);
					component.set("v.spinner", '');
				}
			}
		} else {
			if (!$A.util.isUndefinedOrNull(response.message) && !$A.util.isEmpty(objSchedule.Related_Object)) {
				this.showToast(component, response.message, 1000, 'error');
			}
			component.set("v.spinner", '');
		}
	},

	showToast: function (component, message, duration, type) {
		(this)._showMessage(component, {
			message: message,
			type: type
		});
	},
	_prepareScheduleObjOnActionChange: function (component) {
		component.set('v.scheduleObj.Name', '');
		component.set('v.scheduleObj.Recipient', 0);
		component.set('v.scheduleObj.Offset', 'before');
		component.set('v.scheduleObj.Offset_Type', 'days');
		component.set('v.scheduleObj.Offset_Value', '');
		component.set('v.scheduleObj.Schedule_Date_Time_Field', '');
		component.set('v.scheduleObj.Schedule_Date_Time', '');
		component.set('v.scheduleObj.Email_Template_Id', '');
		component.set('v.scheduleObj.Email_Template_Name', '');
		component.set('v.scheduleObj.AssociateWithReferencedRecordOptions', []);
		component.set('v.scheduleObj.Associate_With_Referenced_Record', 'false');
		let recordId = component.get("v.recordId");
		if (recordId != null && recordId != undefined && recordId != '') {
			component.set("v.scheduleObj.Base_Object_Evaluate_Criteria", 'Id=' + "'" + recordId + "'");
		}
	},

	validateForm: function (component, scheduleObj) {
		var response = {
			'isvalid': true,
			'message': ''
		};
		let messageAttendeescmp = component.find("messageAttendeescmp");

		if ($A.util.isUndefinedOrNull(scheduleObj.Related_Object) || $A.util.isEmpty(scheduleObj.Related_Object)) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_related_object");
		} else if ($A.util.isUndefinedOrNull(scheduleObj.Name) || $A.util.isEmpty(scheduleObj.Name)) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_name");
		} else if (scheduleObj.Action === 'Email' && ($A.util.isUndefinedOrNull(scheduleObj.Email_From_Address) || $A.util.isEmpty(scheduleObj.Email_From_Address))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_from_email");
		} else if (scheduleObj.Action === 'Email' && ($A.util.isUndefinedOrNull(scheduleObj.Email_To_Address) || $A.util.isEmpty(scheduleObj.Email_To_Address))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_to_email");
		} else if (scheduleObj.Action === 'SMS' && ($A.util.isUndefinedOrNull(scheduleObj.SMS_From_Number) || $A.util.isEmpty(scheduleObj.SMS_From_Number))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_from_sms");
		} else if (scheduleObj.Action === 'SMS' && ($A.util.isUndefinedOrNull(scheduleObj.SMS_To_Number) || $A.util.isEmpty(scheduleObj.SMS_To_Number))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_to_sms");
		} else if (($A.util.isUndefinedOrNull(scheduleObj.Schedule_Date_Time_Field) || $A.util.isEmpty(scheduleObj.Schedule_Date_Time_Field)) && ($A.util.isUndefinedOrNull(scheduleObj.Schedule_Date_Time) || $A.util.isEmpty(scheduleObj.Schedule_Date_Time))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_datetime");
		} else if (($A.util.isUndefinedOrNull(scheduleObj.Execute_Now) || (!$A.util.isUndefinedOrNull(scheduleObj.Execute_Now) && !scheduleObj.Execute_Now)) && !$A.util.isUndefinedOrNull(scheduleObj.Schedule_Date_Time_Field) && scheduleObj.Schedule_Date_Time_Field != 'now' && ($A.util.isUndefinedOrNull(scheduleObj.Offset_Value) || $A.util.isEmpty(scheduleObj.Offset_Value)) && ($A.util.isUndefinedOrNull(scheduleObj.Schedule_Date_Time) || $A.util.isEmpty(scheduleObj.Schedule_Date_Time))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_datetime");
		} else if (scheduleObj.Action === 'Email' && ($A.util.isUndefinedOrNull(scheduleObj.Email_Template_Id) || $A.util.isEmpty(scheduleObj.Email_Template_Id))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_email_template");
		} else if (scheduleObj.Action === 'SMS' && ($A.util.isUndefinedOrNull(scheduleObj.SMS_Message) || $A.util.isEmpty(scheduleObj.SMS_Message))) {
			response.isvalid = false;
			response.message = $A.get("$Label.c.SCH_SS_field_selection_error_sms");
		} else if (!$A.util.isUndefinedOrNull(scheduleObj.Execute_Now) && !$A.util.isEmpty(scheduleObj.Execute_Now) && !scheduleObj.Execute_Now && !$A.util.isUndefinedOrNull(scheduleObj.Schedule_Date_Time) && !$A.util.isEmpty(scheduleObj.Schedule_Date_Time)) {
			let selectedDateTime = scheduleObj.Schedule_Date_Time;
			let now = new Date();
			now.setTime(now.getTime() + (1 * 60 * 1000));

			let dtVal = new Date(selectedDateTime);
			if (dtVal.getTime() >= now.getTime()) {
				response.isvalid = true;
			} else {
				response.isvalid = false;
				response.message = $A.get("$Label.c.SCH_SS_field_selection_error_past_datetime");
			}
		}
		
		if (!$A.util.isUndefinedOrNull(messageAttendeescmp) && !$A.util.isEmpty(messageAttendeescmp) && !messageAttendeescmp.validateScheduleForm()) {
			response.isvalid = false;
		}
		return response;
	},

	confirmOrgWideEmailAddressJS: function (component, helper) {
		component.set("v.scheduleObj.isShowEmailVerified", false);
		component.set("v.scheduleObj.isEmailVerified", true);
		if(component.get("v.scheduleObj.isScheduleActive") == true){
			helper.saveActiveScheduleJS(component, helper);
		}else{
			helper.saveScheduleJS(component, helper);
		}
	},

	cancelOrgWideEmailAddressJS: function (component, helper) {
		component.set("v.scheduleObj.isShowEmailVerified", false);
	},
})