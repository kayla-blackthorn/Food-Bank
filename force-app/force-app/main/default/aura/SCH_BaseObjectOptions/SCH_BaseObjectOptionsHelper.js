({
    jsDoInit: function (component, helper) {
        var globalDescribeMapJS = component.get("v.globalDescribeMap");
        helper.handleBaseOptionsPrepation(component, helper, globalDescribeMapJS, false);
    },

    handleBaseOptionsPrepation: function (component, helper, globalDescribeMapJS, isUpdate) {
        var baseObjectOptionsArr = [];
        let selectedBaseObjectValue = component.get("v.selectedBaseObjectValue");
        if (globalDescribeMapJS) {
            for (let key in globalDescribeMapJS) {
                var describeObj = JSON.parse(globalDescribeMapJS[key]);
                if (selectedBaseObjectValue == describeObj.name) {
                    component.set("v.selectedBaseObjectLabel", describeObj.label);
                }
                baseObjectOptionsArr.push({
                    'label': describeObj.label,
                    'value': describeObj.name
                });
            }
            if (baseObjectOptionsArr.length > 0) {
                baseObjectOptionsArr = baseObjectOptionsArr.sort(function (a, b) {
                    var t1 = a.label == b.label,
                        t2 = a.label < b.label;
                    return t1 ? 0 : ('ASC' ? -1 : 1) * (t2 ? 1 : -1);
                });
            }
        }
        component.set("v.baseObjectOptions", baseObjectOptionsArr);

        var selectedItems = [];
        if (!$A.util.isUndefinedOrNull(selectedBaseObjectValue) && !$A.util.isEmpty(selectedBaseObjectValue)) {
            selectedItems.push(selectedBaseObjectValue);
        }
        component.set("v.selectedItems", selectedItems);
        component.set("v.displayDropdownSelection", true);
    },

    setDropdownFocus: function (cmp, hlpr) {
        window.setTimeout(() => {
            let dorpdown = hlpr.findEle(cmp, 'objectSelection');
            if (dorpdown) {
                dorpdown.focus();
            }
        }, 200);
    },
    jsAllowSelect: function (cmp, evt, hlpr) {
        let allowSelect = !cmp.get("v.allowSelect");
        if (allowSelect) {
            hlpr.setDropdownFocus(cmp, hlpr);
        }
        cmp.set("v.allowSelect", allowSelect);
    },
    jsChangeBaseObject: function (cmp, evt, hlpr) {
        let selectedBaseObjects = cmp.get("v.selectedBaseObjects");
        let selectedBaseObjectValue = '';
        let selectedBaseObjectLabel = 'Choose Base Object';
        if (selectedBaseObjects && selectedBaseObjects.length > 0) {
            selectedBaseObjectValue = selectedBaseObjects[0].value;
            selectedBaseObjectLabel = selectedBaseObjects[0].label;
        }
        cmp.set("v.selectedBaseObjectValue", selectedBaseObjectValue);
        cmp.set("v.selectedBaseObjectLabel", selectedBaseObjectLabel);
        cmp.set("v.allowSelect", false);
    },
    jsGlobalDescrieMapUpdate: function (cmp, evt, hlpr) {
        let params = evt.getParams();
        if (params.arguments) {
            let globalDescrieMapValue = params.arguments.globalDescrieMapValue;
            hlpr.handleBaseOptionsPrepation(cmp, hlpr, globalDescrieMapValue, true);
        }
    }
})