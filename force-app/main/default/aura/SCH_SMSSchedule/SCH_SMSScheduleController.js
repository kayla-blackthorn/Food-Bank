({
    handleInit: function (cmp, evt, hlpr) {
        hlpr.jsInitMessenger(cmp, evt, hlpr);
    },
    handlePrevious: function (cmp, evt, hlpr) {
        hlpr.jsPrevious(cmp, evt, hlpr);
    },
    handleNext: function (cmp, evt, hlpr) {
        hlpr.jsNext(cmp, evt, hlpr);
    },
    handleValidatedForm: function (cmp, evt, hlpr) {
        return hlpr.validatedFormJS(cmp, hlpr);
    },
    handleValidatedSectionToggleForm: function (cmp, evt, hlpr) {
        return hlpr.validatedSectionToggleFormJS(cmp, hlpr);
    }
})