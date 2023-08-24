({
    jsDoInit: function (component, helper) {
        var baseObjectValue = component.get("v.selectedBaseObjectValue");
        let eventRecordConfig = true;
        if (baseObjectValue != null && baseObjectValue != undefined && baseObjectValue != '') {
            if (!$A.util.isUndefinedOrNull(component.get("v.recordId"))) {
                var relatedObjectOptionsArr = [];
                relatedObjectOptionsArr.push({
                    'label': 'Event Attendees',
                    'value': 'conference360__Attendee__c',
                    'relationship_name': 'conference360__Event__r',
                    'field_api_name': 'conference360__Event__c'
                });
                relatedObjectOptionsArr.push({
                    'label': 'Session Attendees',
                    'value': 'conference360__Session_Attendee__c',
                    'relationship_name': 'conference360__Session__r',
                    'field_api_name': 'conference360__Session__r.conference360__Event__c'
                });
                component.set("v.relatedObjectOptions", relatedObjectOptionsArr);
                component.set("v.currentStep", 1);
            } else {
                eventRecordConfig = false;
                helper.serverConnect(component, helper, 'getGlobalChildsObjectName', {
                    objectName: baseObjectValue
                }, helper._globalChildsObjectDescribe);
            }
            component.set("v.eventRecordConfig", eventRecordConfig);
        }
    },

    _globalChildsObjectDescribe: function (component, helper, response, cbInfo) {
        var result = response.getReturnValue();
        var relatedObjectOptionsArr = [];
        if (result) {
            for (let objDescribe of result) {
                objDescribe.label += ' (' + objDescribe.field_api_name + ')';
                relatedObjectOptionsArr.push(objDescribe);
            }
        }
        if (relatedObjectOptionsArr.length > 0) {
            relatedObjectOptionsArr = relatedObjectOptionsArr.sort(function (a, b) {
                var t1 = a.label == b.label,
                    t2 = a.label < b.label;
                return t1 ? 0 : ('ASC' ? -1 : 1) * (t2 ? 1 : -1);
            });
        }
        let selectedRelatedObjectLabel = 'Choose Related Object';
        let selectedRelatedObjectFieldAPIName = '';
        var selectedRelatedObjectValue = '';
        var selectedRelatedObjectRelationshipName = '';

        var selectedValue = component.get("v.selectedRelatedObjectValue");
        var selectedRelation = component.get("v.selectedRelatedObjectRelationshipName");


        if (relatedObjectOptionsArr != null && relatedObjectOptionsArr != undefined && !$A.util.isUndefinedOrNull(selectedValue) && !$A.util.isEmpty(selectedValue)) {
            for (let i = 0; i < relatedObjectOptionsArr.length; i++) {
                if (relatedObjectOptionsArr[i].relationship_name == selectedRelation &&
                    relatedObjectOptionsArr[i].value == selectedValue) {
                    selectedRelatedObjectLabel = relatedObjectOptionsArr[i].label;
                    selectedRelatedObjectFieldAPIName = relatedObjectOptionsArr[i].field_api_name;
                    selectedRelatedObjectValue = relatedObjectOptionsArr[i].value;
                    selectedRelatedObjectRelationshipName = relatedObjectOptionsArr[i].relationship_name;
                    break;
                }
            }
        }

        component.set("v.selectedRelatedObjectLabel", selectedRelatedObjectLabel);
        component.set("v.selectedRelatedObjectFieldAPIName", selectedRelatedObjectFieldAPIName);
        component.set("v.selectedRelatedObjectValue", selectedRelatedObjectValue);
        component.set("v.selectedRelatedObjectRelationshipName", selectedRelatedObjectRelationshipName);

        component.set("v.relatedObjectOptions", relatedObjectOptionsArr);
        component.set("v.displayDropdownSelection", true);
    },

    objectsSelectionJS: function (component, event, helper) {
        var selectedValue = event.getParam("value");
        component.set("v.selectedRelatedObjectValue", selectedValue);
        helper.objectLabelSelectionJS(component, helper, selectedValue);
        component.set("v.currentStep", 1);
    },

    objectLabelSelectionJS: function (component, helper, selectedValue) {
        var relatedObjectOptionsArr = component.get("v.relatedObjectOptions");
        if (relatedObjectOptionsArr != null && relatedObjectOptionsArr != undefined) {
            for (let i = 0; i < relatedObjectOptionsArr.length; i++) {
                if (relatedObjectOptionsArr[i].value == selectedValue) {
                    component.set("v.selectedRelatedObjectRelationshipName", relatedObjectOptionsArr[i].relationship_name);
                    component.set("v.selectedRelatedObjectLabel", relatedObjectOptionsArr[i].label);
                    component.set("v.selectedRelatedObjectFieldAPIName", relatedObjectOptionsArr[i].field_api_name);
                    break;
                }
            }
        }
    },

    jsAllowSelect: function (cmp, evt, hlpr) {
        let allowSelect = !cmp.get("v.allowSelect");
        if (allowSelect) {
            hlpr._setDropdownFocus(cmp, hlpr);
        }
        cmp.set("v.allowSelect", allowSelect);
    },
    _setDropdownFocus: function (cmp, hlpr) {
        window.setTimeout(() => {
            let dorpdown = hlpr.findEle(cmp, 'relatedObjectSelection');
            if (dorpdown) {
                dorpdown.focus();
            }
        }, 200);
    },

    jsChangeRelatedObject: function (cmp, evt, hlpr) {
        let selectedRelatecObjects = cmp.get("v.selectedRelatecObjects");
        let selectedRelatedObjectValue = '';
        let selectedRelatedObjectLabel = 'Choose Related Object';
        let selectedRelatedObjectRelationshipName = '';
        let selectedRelatedFieldAPIName = '';
        if (selectedRelatecObjects && selectedRelatecObjects.length > 0) {
            selectedRelatedObjectValue = selectedRelatecObjects[0].value;
            selectedRelatedObjectLabel = selectedRelatecObjects[0].label;
            selectedRelatedObjectRelationshipName = selectedRelatecObjects[0].relationship_name;
            selectedRelatedFieldAPIName = selectedRelatecObjects[0].field_api_name;
        }
        cmp.set("v.selectedRelatedObjectValue", selectedRelatedObjectValue);
        cmp.set("v.selectedRelatedObjectLabel", selectedRelatedObjectLabel);
        cmp.set("v.selectedRelatedObjectRelationshipName", selectedRelatedObjectRelationshipName);
        cmp.set("v.selectedRelatedObjectFieldAPIName", selectedRelatedFieldAPIName);
        cmp.set("v.allowSelect", false);
    },
    jsRelatedObjectvalueUpdate: function (cmp, evt, hlpr) {
        let params = evt.getParams();
        if (params.arguments) {
            let selectedValue = params.arguments.relatedObjectvalue;
            hlpr.objectLabelSelectionJS(cmp, hlpr, selectedValue);
        }
    },
    jsResetRelatedObject: function (cmp, evt, hlpr) {
        cmp.set("v.selectedItems", []);
    },
})