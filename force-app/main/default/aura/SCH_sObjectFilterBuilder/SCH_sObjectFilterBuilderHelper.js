({
    _getBlankFilter: function () {
        return {
            queryFieldTooltip: 'Find a field...',
            queryField: '',
            operations: [{
                label: 'Equals',
                value: '='
            }],
            value: '',
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
    jsChangeSObjectName: function (cmp, evt, hlpr) {
        let _sObjectName = cmp.get('v._sObjectName');
        let sObjectName = cmp.get('v.sObjectName');
        if (_sObjectName != sObjectName) {
            window.setTimeout($A.getCallback(function () {
                cmp.set("v._filters", []);
                hlpr.jsInit(cmp, evt, hlpr);
            }), 500);
        }
    },
    _setupConditions: function (cmp, hlpr) {
        let conditionData = cmp.get("v.conditionData");
        if (!conditionData || !conditionData.hasOwnProperty('name')) {
            conditionData = {};
            conditionData.name = cmp.getGlobalId().replace(new RegExp("[^\\w]+", "g"), "");
            conditionData.allAND = $A.get("$Label.c.SCH_filter_builder_condition_all_selection");
            conditionData.anyOR = $A.get("$Label.c.SCH_filter_builder_condition_or_selection");
            conditionData.custom = $A.get("$Label.c.SCH_filter_builder_condition_custom_selection");
            conditionData.conditions = [conditionData.allAND, conditionData.anyOR, conditionData.custom];
            cmp.set("v.conditionData", conditionData);
        }
    },
    jsInit: function (cmp, evt, hlpr) {
        cmp.set("v.hasError", false);
        cmp.set("v.errorMessage", '');
        let filters = cmp.get("v._filters");
        if (filters == undefined || !filters) {
            filters = [];
        }
        let filterData = cmp.get("v.filterData");
        let filterFields = {};
        if (filterData != undefined && filterData && filterData.filters && filterData.filters.length > 0) {
            filterData.filters.forEach(function (field) {
                filterFields[field.f] = true;
            })
        }
        if (filters.length == 0) {
            filters.push(hlpr._getBlankFilter());
            cmp.set('v._filters', filters);
        }
        cmp.set("v._sObjectName", cmp.get('v.sObjectName'));
        var params = {
            recordId: cmp.get('v.recordId'),
            sObjectName: cmp.get('v.sObjectName'),
            fields: Object.keys(filterFields)
        };
        hlpr.serverConnect(cmp, hlpr, 'getInitData',
            params,
            hlpr._GetInitData);
        hlpr._setupConditions(cmp, hlpr);
    },
    _GetInitData: function (cmp, hlpr, response, cbInfo) {
        var result = response.getReturnValue();
        let data = {
            'sObjectLabel': result.sObjectLabel,
            'sObjectApiName': result.sObjectApiName,
            'operations': result.operations,
            'fields': hlpr._prepareFields(result)
        };
        cmp.set("v.data", data);
        hlpr._setupDefaultFilters(cmp, hlpr);
    },
    _setupDefaultFilters: function (cmp, hlpr) {
        let filterData = cmp.get("v.filterData");
        let data = cmp.get("v.data");
        let filters = cmp.get("v._filters");
        if (filterData && filterData.filters && filterData.filters.length > 0) {
            filters = [];
            filterData.filters.forEach(function (filterO) {
                let filterN = hlpr._getBlankFilter()
                filterN.queryFieldTooltip = 'Find a field...';
                filterN.queryField = '';
                filterN.value = '';
                filterN.selectedFields = [];
                if (filterO.f) {
                    let fieldParts = filterO.f.split('.');
                    let baseField = fieldParts.splice(0, 1);
                    filterN.selectedFields = [hlpr._getBlankFieldSelection()];
                    filterN.selectedFields[0].fields = hlpr.cloneObject(data.fields);
                    filterN.selectedFields[0].fields.forEach(function (field) {
                        if (baseField[0] == field.value) {
                            filterN.selectedFields[0].field = hlpr.cloneObject(field);
                            filterN.selectedFields[0].selected = true;
                            filterN.selectedFields[0].loadingFields = false;
                            filterN.selectedFields[0].selectedItems = baseField;
                            filterN.selectedFields[0].selectedOptions = [hlpr.cloneObject(field)];
                        }
                    })
                    if (fieldParts.length == 0) {
                        filterN.fieldTypeDataSelected = hlpr._prepareFieldTypedata(filterN.selectedFields[0].field);
                    } else {
                        filterN.preparing = true;
                        filterN.selectedFields[1] = hlpr._getBlankFieldSelection();
                        filterN.selectedFields[1].field = {
                            value: fieldParts.join('.')
                        };
                        filterN.selectedFields[1].selected = true;
                        filterN.selectedFields[1].loadingFields = true;
                    }
                }
                filterN.selectedOperator = '=';
                filterN.selectedOperatorLabel = 'Equals';
                filterN.filterOperator = filterO.op;
                filterN.filterVal = filterO.val;
                filterN.selectAll = false;
                hlpr._maintainFilterOperatorVal(filterN, data);
                filters[filters.length] = filterN;
            })
            cmp.set("v.customConditionalLogic", "");
        }

        let customConditionalLogic = '';
        let conditionData = cmp.get("v.conditionData");
        let selectedCondition = conditionData.allAND;
        if (filterData.condition === 'and') {
            selectedCondition = conditionData.allAND;
        } else if (filterData.condition === 'or') {
            selectedCondition = conditionData.anyOR;
        } else if (filterData.condition === 'custom') {
            selectedCondition = conditionData.custom;
            customConditionalLogic = filterData.logic_exp;
        }
        cmp.set("v.selectedCondition", selectedCondition);
        cmp.set("v.customConditionalLogic", customConditionalLogic);
        cmp.set("v._filters", filters);
        hlpr._processFilter(cmp, hlpr);
    },
    _processFilter: function (cmp, hlpr) {
        let filters = cmp.get("v._filters");
        let data = cmp.get("v.data");
        if (filters && filters.length > 0) {
            let isChanged = true;
            for (let ind = 0, len = filters.length; ind < len; ind++) {
                if (filters[ind].preparing) {
                    isChanged = false;
                    let flen = filters[ind].selectedFields.length;
                    let f = filters[ind].selectedFields[flen - 2];
                    let cbInfo = {
                        filterIndex: ind,
                        fieldInd: flen - 1
                    }
                    var s = function (cmp, hlpr, response, cbInfo) {
                        var result = response.getReturnValue();
                        // maintaining operations
                        hlpr._maintainOperations(cmp, result.operations);
                        data = cmp.get("v.data");

                        let filters = cmp.get("v._filters");
                        let filterN = filters[cbInfo.filterIndex];
                        let fieldInd = cbInfo.fieldInd;
                        let fieldParts = filterN.selectedFields[fieldInd].field.value.split('.');
                        let baseField = fieldParts.splice(0, 1);
                        filterN.selectedFields[fieldInd].loadingFields = false;
                        result.excludeParentField = fieldInd == result.maxQueryLevel;
                        filterN.selectedFields[fieldInd].fields = hlpr._prepareFields(result);

                        filterN.selectedFields[fieldInd].fields.forEach(function (field) {
                            if (baseField[0] == field.value) {
                                filterN.selectedFields[fieldInd].field = hlpr.cloneObject(field);
                                filterN.selectedFields[fieldInd].selected = true;
                                filterN.selectedFields[fieldInd].loadingFields = false;
                                filterN.selectedFields[fieldInd].selectedItems = baseField;
                                filterN.selectedFields[fieldInd].selectedOptions = [hlpr.cloneObject(field)];
                            }
                        })
                        if (fieldParts.length == 0) {
                            delete filterN.preparing;
                            filterN.fieldTypeDataSelected = hlpr._prepareFieldTypedata(filterN.selectedFields[fieldInd].field);
                        } else {
                            filterN.preparing = true;
                            filterN.selectedFields[fieldInd + 1] = hlpr._getBlankFieldSelection();
                            filterN.selectedFields[fieldInd + 1].field = {
                                value: fieldParts.join('.')
                            };
                            filterN.selectedFields[fieldInd + 1].selected = true;
                            filterN.selectedFields[fieldInd + 1].loadingFields = true;
                        }
                        hlpr._maintainFilterOperatorVal(filterN, data);

                        filters[cbInfo.filterIndex] = filterN;
                        cmp.set("v._filters", filters);
                        hlpr._processFilter(cmp, hlpr);
                    }
                    let params = {
                        'sObjectName': f.field.sObjectName,
                        'relationshipName': f.field.relationshipName
                    };
                    hlpr.serverConnect(cmp, hlpr, 'preparesObjectFields',
                        params, s, cbInfo);
                    break;
                }
            }
            if (isChanged) {
                hlpr._fireOnChange(cmp, hlpr);
            }
        }
    },
    _maintainFilterOperatorVal: function (filter, data) {
        if (filter.fieldTypeDataSelected) {
            filter.operations = data.operations[filter.fieldTypeDataSelected.filtertype];
            if (!filter.operations) {
                filter.operations = data.operations['id'];
            }
            if (filter.filterOperator) {
                filter.selectedOperator = filter.filterOperator;
            }
            if (filter.filterVal) {
                filter.value = filter.filterVal;
            }
            filter.operations.forEach(function (op) {
                if (op.value == filter.selectedOperator) {
                    filter.selectedOperator = op.value;
                    filter.selectedOperatorLabel = op.label;
                    op.selected = true;
                }
            })
            if (filter.selectedOperator === 'is_null' || filter.selectedOperator === 'is_not_null') {
                filter.hideValue = true;
                filter.value = '';
            } else {
                filter.hideValue = false;
            }
            if (filter.fieldTypeDataSelected.filtertype === 'checkbox' || filter.fieldTypeDataSelected.filtertype === 'combobox') {
                filter.options = filter.fieldTypeDataSelected.options;
                if (filter.value) {
                    filter.selectedItems = filter.value ? filter.value.split(',') : [];
                }
            }
        }
        filter.queryFieldTooltip = 'Find a field...';
        filter.queryField = '';
        if (filter.selectedFields.length > 0) {
            filter.queryFieldTooltip = '[' + data.sObjectApiName + '].';
            filter.selectedFields.forEach(function (field) {
                filter.queryField += (field.field.relationshipName ? field.field.relationshipName + '.' : field.field.value);
            })
            filter.queryFieldTooltip += filter.queryField;
        }
    },
    _prepareFields: function (data) {
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
                fields.push(field);
            })
        }
        return fields;
    },
    jsAddFilter: function (cmp, evt, hlpr) {
        let filters = cmp.get("v._filters");
        filters.push(hlpr._getBlankFilter());
        cmp.set('v._filters', filters);
    },
    jsConditionChange: function (cmp, evt, hlpr) {
        let conditionData = cmp.get("v.conditionData");
        let selectedCondition = cmp.get("v.selectedCondition");
        if (selectedCondition != conditionData.custom) {
            cmp.set("v.customConditionalLogic", "");
        }
        cmp.set("v.selectedCondition", evt.getSource().get("v.label"));
        hlpr._fireOnChange(cmp, hlpr);
    },
    jsRemoveFilter: function (cmp, evt, hlpr) {
        let index = evt.target.dataset.index;
        let filters = cmp.get("v._filters");
        filters.splice(index, 1);
        cmp.set('v._filters', filters);
        hlpr._fireOnChange(cmp, hlpr);
    },

    jsFieldSelection: function (cmp, evt, hlpr) {
        let fieldTypeData = cmp.get("v.fieldTypeData");
        fieldTypeData.isShow = false;

        let data = cmp.get("v.data");
        let index = evt.currentTarget.dataset.index;
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

    jsFieldSelectionCancel: function (cmp, evt, hlpr) {
        cmp.set("v.fieldData", {
            allowSelection: false
        });
    },
    jsFieldSelectionSave: function (cmp, evt, hlpr) {
        let fieldData = cmp.get("v.fieldData");
        let filters = cmp.get("v._filters");
        let data = cmp.get("v.data");
        let filter = filters[fieldData.filterIndex];
        filter.queryFieldTooltip = 'Find a field...';
        filter.queryField = '';
        filter.value = '';
        filter.selectedFields = hlpr.cloneObject(fieldData.selectedFields);
        if (fieldData.selectedFields.length > 0) {
            filter.queryFieldTooltip = '[' + data.sObjectApiName + '].';
            fieldData.selectedFields.forEach(function (field) {
                filter.queryField += (field.field.relationshipName ? field.field.relationshipName + '.' : field.field.value);
            })
            filter.queryFieldTooltip += filter.queryField;
        }
        filter.fieldTypeDataSelected = cmp.get("v.fieldTypeData");
        filter.operations = data.operations[filter.fieldTypeDataSelected.filtertype];
        if (!filter.operations) {
            filter.operations = data.operations['id'];
        }
        filter.options = filter.fieldTypeDataSelected.options;
        filter.ltnginput = filter.fieldTypeDataSelected.ltngInput;

        filter.selectedOperator = '=';
        filter.selectedOperatorLabel = 'Equals';
        filter.hideValue = false;
        filter.value = '';
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
    jsFieldSelectionOnChange: function (cmp, evt, hlpr) {
        let fieldData = cmp.get("v.fieldData");
        var field = fieldData.selectedFields[fieldData.level];
        field.selected = field.selectedOptions.length > 0;
        let oldField = {};
        if (field.field) {
            oldField = field.field
        }
        let fieldTypeData = cmp.get("v.fieldTypeData");
        if (field.selected) {
            field.field = hlpr.cloneObject(field.selectedOptions[0]);
            if (field.field.isReference) {
                let params;
                if (fieldData.selectedFields.length - 1 == fieldData.level) {
                    params = {};
                }
                if (oldField.apiName == field.field.apiName) {
                    if (fieldTypeData.value) {
                        fieldTypeData.isShow = true;
                    }
                } else {
                    fieldTypeData.isShow = false;
                    params = {};
                    fieldData.selectedFields = fieldData.selectedFields.slice(0, fieldData.level + 1);
                }
                if (params) {
                    fieldData.selectedFields.push(hlpr._getBlankFieldSelection());
                    fieldData.selectedFields[fieldData.selectedFields.length - 1].loadingFields = true;
                    params = {
                        'sObjectName': field.field.sObjectName,
                        'relationshipName': field.field.relationshipName
                    };
                    hlpr.serverConnect(cmp, hlpr, 'preparesObjectFields',
                        params, hlpr._PreparesObjectFields);
                }
            } else {
                fieldTypeData = hlpr._prepareFieldTypedata(field.field);
            }
        } else {
            fieldTypeData = {};
            field.field = {};
        }
        if (oldField.isReference && !field.field.isReference) {
            fieldData.level = fieldData.level;
            fieldData.selectedFields = fieldData.selectedFields.slice(0, fieldData.level + 1);
        }
        fieldData.level = fieldData.selectedFields.length - 1;

        cmp.set("v.fieldTypeData", fieldTypeData);
        fieldData.lastFieldIndex = fieldData.level;
        cmp.set("v.fieldData", fieldData);
        hlpr._fireOnChange(cmp, hlpr);
    },
    jsFieldDropdownChange: function (cmp, evt, hlpr) {
        hlpr._fireOnChange(cmp, hlpr);
    },
    jsFieldBlur: function (cmp, evt, hlpr) {
        hlpr._fireOnChange(cmp, hlpr);
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
    _PreparesObjectFields: function (cmp, hlpr, response, cbInfo) {
        var result = response.getReturnValue();
        let fieldData = cmp.get("v.fieldData");
        fieldData.selectedFields[fieldData.level].loadingFields = false;
        result.excludeParentField = fieldData.level == result.maxQueryLevel;
        fieldData.selectedFields[fieldData.level].fields = hlpr._prepareFields(result);
        cmp.set("v.fieldData", fieldData);
    },
    _maintainOperations: function (cmp, operations) {
        if (operations) {
            let data = cmp.get("v.data");
            if (!data.operations) {
                data.operations = {};
            }
            for (let key in operations) {
                if (!data.operations[key]) {
                    data.operations[key] = operations;
                }
            }
            cmp.set("v.data", data);
        }
    },
    jsFilterChangeOperation: function (cmp, evt, hlpr) {
        let val = evt.target.value;
        let index = evt.target.dataset.index;
        let filters = cmp.get("v._filters");
        if (filters[index]) {
            filters[index].selectedOperator = val;
        }
        if (filters[index].selectedOperator === 'is_null' || filters[index].selectedOperator === 'is_not_null') {
            filters[index].hideValue = true;
            filters[index].value = '';
        } else {
            filters[index].hideValue = false;
        }
        for (let ind in filters[index].operations) {
            if (filters[index].operations[ind].value == val) {
                filters[index].selectedOperatorLabel = filters[index].operations[ind].label;
                break;
            }
        }
        cmp.set("v._filters", filters);
        hlpr._fireOnChange(cmp, hlpr);
    },
    jsGetFilters: function (cmp, evt, hlpr) {
        return hlpr._prepareFilterData(cmp, hlpr, false);
    },
    jsGetQueryFilter: function (cmp, evt, hlpr) {
        return hlpr._prepareFilterData(cmp, hlpr, true);
    },
    _prepareFilterData: function (cmp, hlpr, displayError) {
        let filters = {};
        let index = 1;
        let sObjectLabel = cmp.get("v.data").sObjectLabel;
        let filterJSON = {};
        let lstFilters = [];
        let valueMissingIndexs = [];
        cmp.get("v._filters").forEach(function (f) {
            let val = '';
            let filterWrap = {};

            if (f.fieldTypeDataSelected) {
                if (f.fieldTypeDataSelected.type === 'BOOLEAN' || f.fieldTypeDataSelected.type === 'PICKLIST' || f.fieldTypeDataSelected.type === 'MULTIPICKLIST') {
                    if (f.fieldTypeDataSelected.type === 'BOOLEAN') {
                        val = !$A.util.isEmpty(f.selectedItems) ? f.selectedItems : '';
                        f.value = val;
                    } else {
                        if ($A.util.isEmpty(f.selectedItems)) {
                            val = '';
                            f.value = '';
                        } else {
                            val = f.selectedItems.map(vl => `'${vl}'`).join(',');
                            f.value = f.selectedItems.join(',');
                        }
                    }
                } else if (f.fieldTypeDataSelected.type === 'STRING' || f.fieldTypeDataSelected.type === 'TEXTAREA' || f.fieldTypeDataSelected.type === 'EMAIL' ||
                    f.fieldTypeDataSelected.type === 'PHONE' || f.fieldTypeDataSelected.type === 'URL' || f.fieldTypeDataSelected.type === 'REFERENCE') {
                    if ($A.util.isEmpty(f.value)) {
                        val = f.value;
                    } else {
                        if (f.selectedOperator === 'contains' || f.selectedOperator === 'starts_with' || f.selectedOperator === 'ends_with') {
                            val = f.value
                        } else {
                            val = "'" + f.value + "'"
                        }
                    }
                } else if (f.fieldTypeDataSelected.type === 'CURRENCY' || f.fieldTypeDataSelected.type === 'DOUBLE' ||
                    f.fieldTypeDataSelected.type === 'PERCENT' || f.fieldTypeDataSelected.type === 'TIME' || f.fieldTypeDataSelected.type === 'DATETIME' || f.fieldTypeDataSelected.type === 'DATE') {
                    val = !$A.util.isEmpty(f.value) ? f.value : '';
                }
            }

            if (f.queryField) {
                filters[index] = f.queryField;

                filterWrap['f_id'] = index;
                filterWrap['f'] = f.queryField;
                filterWrap['op'] = f.selectedOperator;
                filterWrap['val'] = f.value;
                filterWrap['f_type'] = f.fieldTypeDataSelected.type;

                lstFilters.push(filterWrap);
            }
            switch (f.selectedOperator) {
                case '=':
                    if (f.fieldTypeDataSelected.type === 'PICKLIST') {
                        if (val) {
                            filters[index] = filters[index] + ' IN (' + val + ')';
                        } else {
                            filters[index] = filters[index] + ' = null';
                        }

                    } else if (f.fieldTypeDataSelected.type === 'MULTIPICKLIST') {
                        if (val) {
                            filters[index] = filters[index] + ' INCLUDES ( ' + val + ' )';
                        } else {
                            filters[index] = filters[index] + '= null';
                        }
                    } else {
                        filters[index] = filters[index] + ' ' + f.selectedOperator + ' ' + val;
                    }
                    break;
                case '<>':
                    if (f.fieldTypeDataSelected.type === 'PICKLIST') {
                        if (val) {
                            filters[index] = filters[index] + ' NOT IN (' + val + ')';
                        } else {
                            filters[index] = filters[index] + ' != null';
                        }
                    } else if (f.fieldTypeDataSelected.type === 'MULTIPICKLIST') {
                        if (val) {
                            filters[index] = filters[index] + ' EXCLUDES ( ' + val + ' )';
                        } else {
                            filters[index] = filters[index] + ' != null';
                        }
                    } else {
                        filters[index] = filters[index] + ' ' + f.selectedOperator + ' ' + val;
                    }
                    break;
                case '>':
                    filters[index] = filters[index] + ' ' + f.selectedOperator + ' ' + val;
                    break;
                case '>=':
                    filters[index] = filters[index] + ' ' + f.selectedOperator + ' ' + val;
                    break;
                case '<':
                    filters[index] = filters[index] + ' ' + f.selectedOperator + ' ' + val;
                    break;
                case '<=':
                    filters[index] = filters[index] + ' ' + f.selectedOperator + ' ' + val;
                    break;
                case 'starts_with':
                    filters[index] = filters[index] + ' Like ' + "'" + val + "%'";
                    break;
                case 'ends_with':
                    filters[index] = filters[index] + ' Like ' + "'%" + val + "'";
                    break;
                case 'contains':
                    filters[index] = filters[index] + ' Like ' + "'%" + val + "%'";
                    break;
                case 'is_null':
                    filters[index] = filters[index] + ' = NULL ';
                    break;
                case 'is_not_null':
                    filters[index] = filters[index] + ' != NULL ';
                    break;

                default:
                    break;
            }
            filterWrap.filter = filters[index];
            if ($A.util.isEmpty(val) && f.selectedOperator != 'is_null' && f.selectedOperator != 'is_not_null') {
                valueMissingIndexs.push(index);
            }

            index++;
        })

        let selectedCondition = cmp.get("v.selectedCondition");
        let conditionData = cmp.get("v.conditionData");
        let customConditionalLogic = cmp.get("v.customConditionalLogic");
        let isError = false;
        let filterValue = '';
        let logicExpression = '';
        let errorMessage = '';
        let condition;
        switch (selectedCondition) {
            case conditionData.allAND:
                filterValue = Object.values(filters).join(' AND ');
                logicExpression = Object.keys(filters).join(' AND ');
                condition = 'and';
                break;
            case conditionData.anyOR:
                filterValue = Object.values(filters).join(' OR ');
                logicExpression = Object.keys(filters).join(' OR ');
                condition = 'or';
                break;
            case conditionData.custom:
                condition = 'custom';
                if (!$A.util.isEmpty(customConditionalLogic)) {
                    logicExpression = customConditionalLogic;
                    filterValue = customConditionalLogic;
                    let numMatch = /\d/gi;
                    let indexMatches = customConditionalLogic.match(numMatch);
                    indexMatches.sort(function (a, b) {
                        return b - a;
                    })
                    let charFixes = '^<^';
                    indexMatches.forEach(function (ind) {
                        filterValue = filterValue.replace(ind, charFixes + ind + charFixes)
                    })
                    indexMatches.forEach(function (index) {
                        if (filters[index]) {
                            filterValue = filterValue.replace(charFixes + index + charFixes, filters[index]) + ' ';
                        } else {
                            isError = true;
                        }
                    });
                }
                break;
            default:
                break;
        }

        let expVal = logicExpression;
        let largestIndex = logicExpression.match(/\d+/g);
        largestIndex = Math.max(...(largestIndex || []));
        expVal = expVal.replace(/AND/gi, '').replace(/OR/gi, '').replace(/[0-9]/g, '').replace(/[()]/g, '').trim();

        if (valueMissingIndexs.length > 0) {
            errorMessage = $A.get("$Label.c.SCH_filter_builder_error_condition_logic_not_defined").trim() + ' ' + Object.values(valueMissingIndexs).join(',');
            isError = true;
        } else if (largestIndex > lstFilters.length) {
            errorMessage = $A.get("$Label.c.SCH_filter_builder_error_condition_logic_not_defined").trim() + ' ' + largestIndex + '.';
            isError = true;
        } else if (lstFilters.length > largestIndex) {
            errorMessage = $A.get("$Label.c.SCH_filter_builder_error_condition_logic_missed").trim();
            isError = true;
        } else if (!$A.util.isEmpty(expVal)) {
            errorMessage = $A.get("$Label.c.SCH_filter_builder_error_condition_logic_invalid").trim();
            isError = true;
        }
        if (displayError) {
            cmp.set('v.hasError', isError);
            cmp.set('v.errorMessage', errorMessage);
        }
        filterJSON['logic_exp'] = logicExpression;
        filterJSON['filters'] = lstFilters;
        filterJSON['query_filter'] = filterValue;
        filterJSON['validity'] = !isError;
        filterJSON['message'] = errorMessage;
        filterJSON['condition'] = condition;
        return filterJSON;
    },
    _fireOnChange: function (cmp, hlpr) {
        let onchange = cmp.get("v.onchange");
        if (onchange) {
            $A.enqueueAction(onchange);
        }
    }
})