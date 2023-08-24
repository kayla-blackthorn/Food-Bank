({
    fetchTotalRecipientsJS: function (component, helper) {
        let objectname = component.get("v.selectScheduleAttendees");
        if (objectname != null && objectname != undefined && objectname != '') {
            helper.serverConnect(component, helper, 'getRecipients', {
                objectName: objectname,
                relatedObjectFieldAPIName: component.get("v.selectedRelatedObjectFieldAPIName"),
                filter: component.get("v.filter"),
                fieldsToShow: component.get("v.fieldNameToShow"),
                fieldNameToReplace: component.get("v.nameFieldToReplace")
            }, helper._totalRecipientsJS);
        }
    },

    _totalRecipientsJS: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        let columns = result.columns;
        let data = result.data;
        if (!$A.util.isUndefinedOrNull(columns) && !$A.util.isEmpty(columns)) {
            for (let newcolumn of columns) {
                if(newcolumn.iconLabel){
                    component.set("v.iconLabel", newcolumn.iconLabel);
                    let styleContent = '.bt_baseSCH_TotalRecipients .slds-icon-utility-info::after{' +
                        'content: "' + newcolumn.iconLabel + '"' +
                        '}';
                    let css = document.createElement('style');
                    if (css.styleSheet) {
                        css.styleSheet.cssText = styleContent;
                    } else {
                        css.appendChild(document.createTextNode(styleContent));
                    }
                    component.find("sectionTotalRecipients").getElement().appendChild(css);
                }
                if (newcolumn.fieldName.indexOf('.') != -1) {
                    let fieldNamePullData = newcolumn.fieldName;
                    let newcolumn_fieldName = newcolumn.fieldName.replaceAll('.', '_');
                    let newcolumnfieldLabel = newcolumn.fieldName.replaceAll('.', '_');
                    if (!newcolumn.typeAttributes) {
                        newcolumn.typeAttributes = {}
                    }
                    if (!newcolumn.typeAttributes.label) {
                        newcolumn.typeAttributes.label = {}
                    }
                    if (newcolumn.typeAttributes.label.fieldName &&
                        newcolumn.typeAttributes.label.fieldName.indexOf('.') != -1) 
                    {
                        fieldNamePullData = newcolumn.typeAttributes.label.fieldName;
                        newcolumn.typeAttributes.label.fieldName = newcolumn.typeAttributes.label.fieldName.replaceAll('.', '_');
                        newcolumnfieldLabel = newcolumn.typeAttributes.label.fieldName;
                    }
                    if (!$A.util.isUndefinedOrNull(data) && !$A.util.isEmpty(data)) {
                        for (let newdata of data) {
                            let newFieldValue = helper.getParentData(newdata, fieldNamePullData);
                            newdata[newcolumn_fieldName] = newFieldValue;
                            newdata[newcolumnfieldLabel] = newFieldValue;
                        }
                    }
                    newcolumn.fieldName = newcolumn_fieldName;
                }
            }
        }
        component.set("v.columns", columns);
        if (result.nameField && result.nameField.indexOf('.') != -1) {
            result.nameField = result.nameField.replace('.', '_');
        }
        component.set("v.nameField", result.nameField);
        component.set("v.selectScheduleAttendeesLabel", result.sObjectLabel);
        if (result.nameField != null && result.nameField != undefined) {
            for (let objData of data) {
                if (objData[result.nameField] != null && objData[result.nameField] != undefined) {
                    objData[result.nameField + 'link'] = '/' + objData['Id'];
                }
            }
        }
        component.set("v.data", data);
    },

    getParentData : function (data, fieldName) {
        let fieldValue = '';
        if (fieldName.indexOf('.') != -1) {
            let fieldArr = fieldName.split('.');
            for (let field of fieldArr) {
                fieldName = field;
                if (data[fieldName] == undefined) {
                    break;
                }
                data = data[fieldName];
            }
            fieldValue = data;
        } else {
            fieldValue = data[fieldName];
        }
        return fieldValue;
    },
    hideTotalRecipientsJS: function (component, helper) {
        component.set("v.isShowViewRecipientsModal", false);
    },
})