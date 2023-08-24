({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },
    handleAllowSelect: function (cmp, evt, hlpr) {
        hlpr.jsAllowSelect(cmp, evt, hlpr);
    },
    handleObjectSelection: function (component, event, helper) {
        helper.objectsSelectionJS(component, event, helper);
    },
    handleChangeRelatedObject: function (cmp, evt, hlpr) {
        hlpr.jsChangeRelatedObject(cmp, evt, hlpr);
    },
    handleRelatedObjectvalueUpdate: function (cmp, evt, hlpr) {
        hlpr.jsRelatedObjectvalueUpdate(cmp, evt, hlpr);
    },
    handleResetRelatedObject: function (cmp, evt, hlpr) {
        hlpr.jsResetRelatedObject(cmp, evt, hlpr);
    },
})