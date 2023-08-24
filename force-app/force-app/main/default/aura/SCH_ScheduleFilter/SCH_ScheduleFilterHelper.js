({
    jsFilterClick: function (cmp, hlpr) {
        cmp.set("v.showFilter", false);
    },
    jsApplyFilter: function (cmp, hlpr) {
        hlpr._enqueOnApply(cmp);
    },
    _enqueOnApply: function (cmp) {
        var onApply = cmp.get('v.onApply');
        if (onApply) {
            $A.enqueueAction(onApply);
        }
    },
})