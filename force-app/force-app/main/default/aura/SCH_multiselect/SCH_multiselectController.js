({
    handleDoInit: function (cmp, evt, hlpr) {
        hlpr.jsDoInit(cmp, evt, hlpr);
    },
    handleKeyPress: function (cmp, evt, hlpr) {
        hlpr.jsFilterList(cmp, evt, hlpr);
    },
    handleKeyDown: function (cmp, evt, hlpr) {
        hlpr.jsFilterList(cmp, evt, hlpr);
    },
    handleClick: function (cmp, evt, hlpr) {
        hlpr.jsClick(cmp, evt, hlpr);
    },
    handleMouseLeave: function (cmp, evt, hlpr) {
        hlpr.jsMouseLeave(cmp, evt, hlpr);
    },
    handleSelection: function (cmp, evt, hlpr) {
        hlpr.jsSelection(cmp, evt, hlpr);
    },
    handleOptionSelection: function (cmp, evt, hlpr) {
        hlpr.jsOptionSelection(cmp, evt, hlpr);
    },
    handleOptionChange: function (cmp, evt, hlpr) {
        hlpr.jsOptionChange(cmp, evt, hlpr);
    },
    handleOptionClick: function (cmp, evt, hlpr) {
        hlpr.jsOptionClick(cmp, evt, hlpr);
    },
    handleOptionOnlyClick: function (cmp, evt, hlpr) {
        hlpr.jsOptionOnlyClick(cmp, evt, hlpr);
    },
    handleCheckClick: function (cmp, evt, hlpr) {
        evt.preventDefault();
    },
    handleDown: function (cmp, evt, hlpr) {
        hlpr.jsDown(cmp, evt, hlpr);
    },
    handleMasterChange: function (cmp, evt, hlpr) {
        hlpr.jsMasterChange(cmp, evt, hlpr);
    },
    handleReInit: function (cmp, evt, hlpr) {
        hlpr.init(cmp, evt, hlpr);
    },
    handleWithSelected: function (cmp, evt, hlpr) {
        hlpr.init(cmp, evt, hlpr);
    },
    handleResetSelection: function (cmp, evt, hlpr) {
        hlpr.jsResetSelection(cmp, evt, hlpr);
    },
    handleSet: function (cmp, evt, hlpr) {
        hlpr.jsSet(cmp, evt, hlpr);
    },
    handleGet: function (cmp, evt, hlpr) {
        hlpr.jsGet(cmp, evt, hlpr);
    },
    handleFocus: function (cmp, evt, hlpr) {
        hlpr.jsFocus(cmp, evt, hlpr);
    },
})