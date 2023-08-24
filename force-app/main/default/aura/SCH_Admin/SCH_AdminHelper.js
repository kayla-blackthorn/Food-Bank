({
    jsDoInit: function (cmp, hlpr) {
        hlpr.serverConnect(cmp, hlpr, 'getAdminInfoOnPageLoad', {}, hlpr._AdminInfoOnPageLoad);
    },

    _AdminInfoOnPageLoad: function (cmp, hlpr, response, cbInfo) {
        var currentPage = cmp.get("v.currentPage");
        var packageData = response.getReturnValue();
        if (packageData.account) {
            hlpr.processAccountClientSide(packageData.account);
            cmp.set("v.account", packageData.account);
            if (packageData.hasAccountCredentials && packageData.account.isUserAuthenticated && packageData.account.isAuthenticatedUserActive) {
                if (!packageData.btSchedulePermissions.isBTScheduleAdmin) {
                    currentPage = "scheduler-info";
                }
            }
        }
        cmp.set("v.packageData", packageData);
        hlpr._prepareAccountBaseDetails(cmp);

        if (packageData.isValid) {
            cmp.set("v.isAuthUser", true);
            cmp.set("v.currentPage", currentPage);
        } else if (packageData.errorMessage) {
            cmp.set("v.packageData.hasAccountCredentials", false);
            hlpr._showMessage(cmp, {
                message: packageData.errorMessage,
                title: 'Smart Scheduler',
                type: "error"
            });
        }
    },

    handleComponentAddById: function (cmp, cmpId) {
        var currentPage = cmp.get("v.currentPage");
        if (!cmp.get("v.packageData.hasAccountCredentials")) {
            return;
        }
        var isFirst = false;
        if (cmpId != "account-info" && cmpId != "scheduler-info" && cmpId != "configuration-settings") {
            cmpId = "account-info";
            isFirst = true;
        }
        if (cmpId !== currentPage || isFirst) {
            cmp.set("v.currentPage", cmpId);
        }
    },
    _prepareAccountBaseDetails: function (cmp) {
        let account = cmp.get("v.account");
        let redierctToBack = true;
        let redierctToBackTrial = true;
        if (account) {
            if (account.isUserAuthenticated && account.isAuthenticatedUserActive) {
                redierctToBack = false;
            } else {
                redierctToBack = cmp.get("v.isAuthUser") == true || !account.isUserAuthenticated;
            }
            redierctToBackTrial = account.plan == 'Trial';
        }
        cmp.set("v.redierctToBack", redierctToBack);
        cmp.set("v.redierctToBackTrial", redierctToBackTrial);
    },
    handleAuthentication: function (component, helper) {
        component.set("v.spinner", "main-loading");
        helper.serverConnect(component, helper, 'getAuthenticationLink', {
            retUrl: window.location.href
        }, helper._AuthenticationJSHelper);
    },
    _AuthenticationJSHelper: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        var urlEvent = $A.get("e.force:navigateToURL");
        if (urlEvent) {
            urlEvent.setParams({
                url: result
            });
            urlEvent.fire();
        } else {
            window.open(result);
        }
        component.set("v.spinner", "");
    },
})