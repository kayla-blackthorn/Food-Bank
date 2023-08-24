({
    handleInit: function (cmp, evt, hlpr) {
        hlpr.jsInit(cmp, evt, hlpr);
    },
    handleAddFilter: function (cmp, evt, hlpr) {
        hlpr.jsAddFilter(cmp, evt, hlpr);
    },
    handleRemoveFilter: function (cmp, evt, hlpr) {
        hlpr.jsRemoveFilter(cmp, evt, hlpr);
    },
    handleConditionChange: function (cmp, evt, hlpr) {
        hlpr.jsConditionChange(cmp, evt, hlpr);
    },
    handleFieldSelection: function (cmp, evt, hlpr) {
        hlpr.jsFieldSelection(cmp, evt, hlpr);
    },
    handleFieldSelectionCancel: function (cmp, evt, hlpr) {
        hlpr.jsFieldSelectionCancel(cmp, evt, hlpr);
    },
    handleFieldSelectionSave: function (cmp, evt, hlpr) {
        hlpr.jsFieldSelectionSave(cmp, evt, hlpr);
    },
    handleFieldSelectionOnChange: function (cmp, evt, hlpr) {
        hlpr.jsFieldSelectionOnChange(cmp, evt, hlpr);
    },
    handleFieldDropdownChange: function (cmp, evt, hlpr) {
        hlpr.jsFieldDropdownChange(cmp, evt, hlpr);
    },
    handleFieldBlur: function (cmp, evt, hlpr) {
        hlpr.jsFieldBlur(cmp, evt, hlpr);
    },
    handleFieldEdit: function (cmp, evt, hlpr) {
        hlpr.jsFieldEdit(cmp, evt, hlpr);
    },
    handleFilterChangeOperation: function (cmp, evt, hlpr) {
        hlpr.jsFilterChangeOperation(cmp, evt, hlpr);
    },
    handleChangeSObjectName: function (cmp, evt, hlpr) {
        hlpr.jsChangeSObjectName(cmp, evt, hlpr);
    },
    handleGetQueryFilter: function (cmp, evt, hlpr) {
        return hlpr.jsGetQueryFilter(cmp, evt, hlpr);
    },
    handleGetFilters: function (cmp, evt, hlpr) {
        return hlpr.jsGetFilters(cmp, evt, hlpr);
    },
})