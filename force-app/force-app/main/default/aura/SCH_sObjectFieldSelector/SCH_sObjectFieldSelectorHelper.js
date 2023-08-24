({
    _getBlankFilter: function () {
        return {
            queryFieldTooltip: 'Find a field...',
            queryField: '',
            selectedOperatorLabel: ''
        };
    },
    _getBlankFieldSelection: function () {
        return {
            field: {},
            loadingFields: false,
            fields: [],
            selected: false,
            selectedItems: [],
            selectedOptions: [],
            hideValue: false
        };
    },
    jsInit: function (cmp, evt, hlpr) {
        cmp.set("v.hasError", false);
        cmp.set("v.errorMessage", '');
        let filters = cmp.get("v._filters");
        if (filters == undefined || !filters) {
            filters = [];
        }
        let filterData = cmp.get("v.filterData");
        if (!filterData) {
            filterData = {}
        }
        if (!filterData.filters) {
            filterData.filters = []
        }
        let filterFields = {};
        filterData.filters.forEach(function (field) {
            filterFields[field.f] = true;
        })
        if (filters.length == 0) {
            filters.push(hlpr._getBlankFilter());
            cmp.set('v._filters', filters);
        }
        cmp.set("v._sObjectName", cmp.get('v.sObjectName'));
        hlpr.serverConnect(cmp, hlpr, 'getInitData', {
            recordId: cmp.get('v.recordId'),
            sObjectName: cmp.get('v.sObjectName'),
            fields: Object.keys(filterFields)
        }, hlpr._GetInitData);
    },
    _GetInitData: function (cmp, hlpr, response, cbInfo) {
        let result = response.getReturnValue();
        let data = {
            'sObjectLabel': result.sObjectLabel,
            'sObjectApiName': result.sObjectApiName,
            'operations': result.operations,
            'fields': hlpr._prepareFields(cmp, result)
        };
        cmp.set("v.data", data);
        hlpr.jsFieldSelection(cmp, null, hlpr);
    },
    jsFieldSelection: function (cmp, evt, hlpr) {
        let fieldTypeData = cmp.get("v.fieldTypeData");
        fieldTypeData.isShow = false;

        let data = cmp.get("v.data");
        let index = 0;
        let filters = cmp.get("v._filters");
        let fieldData = {
            selectedFields: [],
            selectedField: false,
            allowSelection: true,
            filterIndex: index,
            level: 0
        };
        fieldData.fields = hlpr.cloneObject(data.fields);
        fieldData.selectedFields = [hlpr._getBlankFieldSelection()];
        fieldData.selectedFields[fieldData.level].fields = hlpr.cloneObject(data.fields);

        if (filters[index].selectedFields && filters[index].selectedFields.length > 0) {
            fieldData.selectedFields = hlpr.cloneObject(filters[index].selectedFields);
            fieldData.level = fieldData.selectedFields.length - 1;
            fieldTypeData = filters[index].fieldTypeDataSelected;
            fieldTypeData.isShow = true;
        }
        filters[index].selectedItems = [];
        filters[index].selectedOptions = [];
        cmp.set("v._filters", filters);
        cmp.set("v.fieldData", fieldData);
        cmp.set("v.fieldTypeData", fieldTypeData);
    },
    jsFieldEdit: function (cmp, evt, hlpr) {
        let fieldData = cmp.get("v.fieldData");
        let index = evt.target.dataset.index;

        if (!fieldData.selectedFields[fieldData.selectedFields.length - 1].field.value) {
            fieldData.selectedFields.splice(fieldData.selectedFields.length - 1, 1);
        }

        fieldData.selectedFields.forEach(function (field) {
            field.selected = true;
        })

        fieldData.selectedFields[index].selected = false;
        fieldData.level = Number(index);
        fieldData.lastFieldIndex = fieldData.selectedFields.length - 1;
        cmp.set("v.fieldData", fieldData);

        let fieldTypeData = cmp.get("v.fieldTypeData")
        fieldTypeData.isShow = fieldData.selectedFields[fieldData.selectedFields.length - 1].field.isReference == false;
        cmp.set("v.fieldTypeData", fieldTypeData);
    },
    jsFieldSelectionOnChange: function (cmp, evt, hlpr) {
        let fieldData = cmp.get("v.fieldData");
        let field = fieldData.selectedFields[fieldData.level];
        field.selected = field.selectedOptions.length > 0;
        let oldField = {};
        if (field.field) {
            oldField = field.field
        }
        let fieldTypeData = cmp.get("v.fieldTypeData");
        if (field.selected) {
            field.field = hlpr.cloneObject(field.selectedOptions[0]);
            if (field.field.isReference) {
                fieldTypeData = hlpr._processReferenceField(cmp, hlpr, {
                    fieldData: fieldData,
                    field: field,
                    oldField: oldField,
                    fieldTypeData: fieldTypeData
                });
            } else {
                fieldTypeData = hlpr._prepareFieldTypedata(field.field);
            }
        } else {
            fieldTypeData = {};
            field.field = {};
        }
        if (oldField.isReference && !field.field.isReference) {
            fieldData.selectedFields = fieldData.selectedFields.slice(0, fieldData.level + 1);
        }
        fieldData.level = fieldData.selectedFields.length - 1;

        cmp.set("v.fieldTypeData", fieldTypeData);
        fieldData.lastFieldIndex = fieldData.level;
        cmp.set("v.fieldData", fieldData);
    },
    _processReferenceField: function(cmp, hlpr, data) {
        let params;
        if (data.fieldData.selectedFields.length - 1 == data.fieldData.level) {
            params = {};
        }
        if (data.oldField.apiName == data.field.field.apiName) {
            if (data.fieldTypeData.value) {
                data.fieldTypeData.isShow = true;
            }
        } else {
            data.fieldTypeData.isShow = false;
            params = {};
            data.fieldData.selectedFields = data.fieldData.selectedFields.slice(0, data.fieldData.level + 1);
        }
        if (params) {
            data.fieldData.selectedFields.push(hlpr._getBlankFieldSelection());
            data.fieldData.selectedFields[data.fieldData.selectedFields.length - 1].loadingFields = true;
            params = {
                'sObjectName': data.field.field.sObjectName,
                'relationshipName': data.field.field.relationshipName
            };
            hlpr.serverConnect(cmp, hlpr, 'preparesObjectFields',
                params, hlpr._PreparesObjectFields);
        }
        return data.fieldTypeData;
    },
    _prepareFields: function (cmp, data) {
        let fields = [];
        if (data.referenceFields && !data.excludeParentField) {
            let tempFields = Object.values(data.referenceFields);
            tempFields.sort(function (a, b) {
                return a.label.localeCompare(b.label);
            });
            tempFields.forEach(function (field) {
                let indexOf = field.label.indexOf('ID');
                if (indexOf > -1 && indexOf + 2 == field.label.length) {
                    field.label = field.label.substring(0, indexOf);
                }
                field.label = field.label.trim();
                field.iconName = 'utility:chevronright';
                field.iconVariant = 'info';
                field.iconTitle = 'More fields are available';
                field.visibility = true;
                field.isReference = true;
                field.apiName = field.value;
                field.value = field.relationshipName;
                fields.push(field);
            })
        }

        if (data.fields) {
            let tempFields = Object.values(data.fields);
            tempFields.sort(function (a, b) {
                return a.label.localeCompare(b.label);
            });
            tempFields.forEach(function (field) {
                field.isReference = false;
                delete field.relationshipName;
                if(field.type == cmp.get('v.action')){
                    fields.push(field);
                }
            })
        }
        return fields;
    },
    jsFieldSelectionSave: function (cmp, evt, hlpr) {
        let fieldData = cmp.get("v.fieldData");
        let filters = cmp.get("v._filters");
        let data = cmp.get("v.data");
        let filter = filters[fieldData.filterIndex];
        filter.queryFieldTooltip = 'Find a field...';
        filter.queryField = '';
        filter.selectedFields = hlpr.cloneObject(fieldData.selectedFields);
        if (fieldData.selectedFields.length > 0) {
            filter.queryFieldTooltip = '[' + data.sObjectApiName + '].';
            fieldData.selectedFields.forEach(function (field) {
                filter.queryField += (field.field.relationshipName ? field.field.relationshipName + '.' : field.field.value);
            })
            filter.queryFieldTooltip += filter.queryField;
        }
        try {
            cmp.set("v._filters", filters);
        } catch (error) {
            console.log(error);
        }
        cmp.set("v.fieldData", {
            allowSelection: false
        });
        hlpr._fireOnChange(cmp, hlpr);
    },
    jsFieldSelectionCancel: function (cmp, evt, hlpr) {
        hlpr._fireOnChange(cmp, hlpr);
    },
    jsGetFilters: function (cmp, evt, hlpr) {
        return hlpr._prepareFilterData(cmp, hlpr, false);
    },
    _prepareFilterData: function (cmp, hlpr, displayError) {
        let filterJSON = {};
        filterJSON['data'] = cmp.get("v._filters");
        filterJSON['closeFieldSelection'] = false;
        return filterJSON;
    },
    _PreparesObjectFields: function (cmp, hlpr, response, cbInfo) {
        let result = response.getReturnValue();
        let fieldData = cmp.get("v.fieldData");
        fieldData.selectedFields[fieldData.level].loadingFields = false;
        result.excludeParentField = fieldData.level == result.maxQueryLevel;
        fieldData.selectedFields[fieldData.level].fields = hlpr._prepareFields(cmp, result);
        cmp.set("v.fieldData", fieldData);
    },
    _prepareFieldTypedata: function (field) {
        return {
            label: field.label,
            value: field.value,
            type: field.type,
            inputtype: field.inputtype,
            filtertype: field.filtertype,
            ltngInput: field.ltngInput,
            options: field.options ? JSON.parse(JSON.stringify(field.options)) : field.options,
            isShow: true
        }
    },
    _fireOnChange: function (cmp, hlpr) {
        let onchange = cmp.get("v.onchange");
        if (onchange) {
            $A.enqueueAction(onchange);
        }
    }
})