({
    handleInit: function (cmp, evt, hlpr) {
        hlpr.jsInit(cmp, evt, hlpr);
    },
    handleFieldEdit: function (cmp, evt, hlpr) {
        hlpr.jsFieldEdit(cmp, evt, hlpr);
    },
    handleFieldSelectionOnChange: function (cmp, evt, hlpr) {
        hlpr.jsFieldSelectionOnChange(cmp, evt, hlpr);
    },
    handleFieldSelectionCancel: function (cmp, evt, hlpr) {
        hlpr.jsFieldSelectionCancel(cmp, evt, hlpr);
    },
    handleGetFilters: function (cmp, evt, hlpr) {
        return hlpr.jsGetFilters(cmp, evt, hlpr);
    },
    handleFieldSelectionSave: function (cmp, evt, hlpr) {
        hlpr.jsFieldSelectionSave(cmp, evt, hlpr);
    },
    
})