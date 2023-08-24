({
	doInit: function (component, event, helper) {
		helper.jsDoInit(component, helper);
	},
	handleSelectScheduleType: function (component, event, helper) {
		helper.selectScheduleTypeJS(component, event, helper);
	},
	handleHideSchedule: function (component, event, helper) {
		helper.hideScheduleJS(component, helper);
	},
	handleSaveSchedule: function (component, event, helper) {
		helper.saveScheduleJS(component, helper);
	},
	handleSaveActiveSchedule: function (component, event, helper) {
		helper.saveActiveScheduleJS(component, helper);
	},
	handleBaseObjectChange: function (component, event, helper) {
		helper.baseObjectChangeJS(component, helper);
	},
	handleRelatedObjectChange: function (component, event, helper) {
		helper.relatedObjectChangeJS(component, helper);
	},
	handleConfirmOrgWideEmailAddress: function (component, event, helper) {
		helper.confirmOrgWideEmailAddressJS(component, helper);
	},
	handleCancelOrgWideEmailAddress: function (component, event, helper) {
		helper.cancelOrgWideEmailAddressJS(component, helper);
	},
})