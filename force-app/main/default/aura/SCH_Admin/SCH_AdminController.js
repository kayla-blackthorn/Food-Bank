({
	doInit: function (component, event, helper) {
		helper.jsDoInit(component, helper);
	},
	handleBack: function (component, event, helper) {
		window.location.href = "/";
	},
	handleMouseEnterNav: function (component, event, helper) {
		var target = event.currentTarget;
		$A.util.addClass(target, "shade");
		var id = target.id;
		var tooltip = component.find(id + "-tooltip");
		$A.util.removeClass(tooltip, "slds-hide");
	},
	handleMouseOutNav: function (component, event, helper) {
		var target = event.currentTarget;
		$A.util.removeClass(target, "shade");
		var id = target.id;
		var tooltip = component.find(id + "-tooltip");
		$A.util.addClass(tooltip, "slds-hide");
	},
	handleNavClick: function (component, event, helper) {
		var id = event.currentTarget.id;
		helper.handleComponentAddById(component, id);
	},
	manageAuthenticatedUser: function (component, event, helper) {
		component.set("v.currentPage", "account-info");
	},
	handleAuthenticationClick: function (component, event, helper) {
		helper.handleAuthentication(component, helper);
	},
})