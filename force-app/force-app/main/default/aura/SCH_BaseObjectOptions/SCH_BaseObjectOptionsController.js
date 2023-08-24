({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },
    handleAllowSelect: function (cmp, evt, hlpr) {
        hlpr.jsAllowSelect(cmp, evt, hlpr);
    },
    handleChangeBaseObject: function (cmp, evt, hlpr) {
        hlpr.jsChangeBaseObject(cmp, evt, hlpr);
    },
    handleGlobalDescrieMapUpdate: function (cmp, evt, hlpr) {
        hlpr.jsGlobalDescrieMapUpdate(cmp, evt, hlpr);
    },
})