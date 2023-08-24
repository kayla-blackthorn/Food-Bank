({
    jsDoInit: function (cmp, evt, hlpr) {
        hlpr.init(cmp, evt, hlpr);
    },
    init: function (cmp, evt, hlpr) {
        //note, we get options and set options_
        //options_ is the private version and we use this from now on.
        //this is to allow us to sort the options array before rendering
        var selectedOptions = [];
        selectedOptions = cmp.get("v.selectedItems");
        var tempOptions = cmp.get("v.options");
        var options = [];
        var isMultiSelect = cmp.get("v.isMultiSelect");
        let allowSorting = cmp.get('v.allowSorting');
        let singleSelect = cmp.get('v.singleSelect');
        let selectAll = cmp.get("v.selectAll");
        if (!tempOptions) {
            tempOptions = [];
        }
        options = JSON.parse(JSON.stringify(tempOptions));
        if (!selectedOptions) {
            selectedOptions = [];
        }
        if (allowSorting) {
            options.sort(function compare(a, b) {
                if (a.value === 'All') {
                    return -1;
                } else if (a.label < b.label) {
                    return -1;
                }
                if (a.value > b.value) {
                    return 1;
                }
                return 0;
            });
        }
        var options_ = [];
        var groupData = {};
        for (let ind = 0, len = options.length; ind < len; ind++) {
            let option = options[ind];
            let keys = Object.keys(option);
            let opt = {};
            keys.forEach(function (key) {
                opt[key] = option[key];
            })
            opt.index = ind;
            opt.selected = (selectAll && isMultiSelect) ? false : selectedOptions.indexOf(opt.value) > -1;
            // add custom inputs
            opt.checked = selectedOptions.length > 0 ? selectedOptions.indexOf(opt.value) > -1 : (selectAll && isMultiSelect);
            if (!singleSelect) {
                let grp = option['group'];
                grp = grp ? grp : 'Other';
                if (!groupData[grp]) {
                    groupData[grp] = [];
                }
                groupData[grp].push(opt);
                opt['group'] = grp;
                if (opt['isGroup'] === undefined) {
                    opt['isGroup'] = false;
                }
            }
            options_.push(opt);
        }
        let isGroup = cmp.get('v.isGroup');
        if ((isGroup === undefined || isGroup === true) && options_.length > 0) {
            let groups = Object.keys(groupData);
            if (groups.length > 0) {
                groups.sort(function (a, b) {
                    return b.toLowerCase().localeCompare(a.toLowerCase())
                });
                options_ = [];
                var gind = 0;
                for (let ind in groups) {
                    let gOptions = groupData[groups[ind]];
                    gOptions[0]['isGroup'] = true;
                    gOptions.forEach(function (gOption) {
                        gOption.index = gind++;
                        options_.push(gOption);
                    })
                }
                cmp.set('v.isGroup', groups.length > 1);
            }
        }
        if (!selectAll && options.length > 0) {
            selectAll = selectedOptions.length == options.length;
        }
        cmp.set('v.selectedText', '');
        cmp.set("v.options_", options_);

        cmp.set("v.selectAll", selectAll);
        cmp.set("v.noItem", options.length == 0);

        let isCombobox = cmp.get('v.isCombobox');
        var ele = document.getElementById(cmp.get('v.inpId'));
        if (!isCombobox) {
            if (ele) {
                ele.value = '';
            }
        }
        hlpr._SelectedValues(cmp);
        hlpr._AutocompleteOff(cmp);
    },
    _AutocompleteOff: function (cmp) {
        window.setTimeout(function () {
            let ele = document.getElementById(cmp.get('v.inpId'));
            if (ele) {
                ele.autocomplete = "off";
            }
        }, 100)
    },
    _prepareLabelKey: function (cmp, hlpr, options) {
        let keyLabelOptions = {};
        if (options && Array.isArray(options)) {
            options.forEach(function (option) {
                keyLabelOptions[option.value + '_' + option.label] = true;
            })
        }
        return keyLabelOptions;
    },
    jsOptionChange: function (cmp, evt, hlpr) {
        let newKeyLabels = hlpr._prepareLabelKey(cmp, hlpr, cmp.get('v.options'));
        let oldKeyLabels = hlpr._prepareLabelKey(cmp, hlpr, cmp.get('v.options_'));
        for (let key in oldKeyLabels) {
            delete newKeyLabels[key];
        }
        if (Object.keys(newKeyLabels).length > 0) {
            hlpr.init(cmp, evt, hlpr);
        }
    },
    jsOptionClick: function (cmp, evt, hlpr) {
        let opIndex = evt.currentTarget.dataset.index;
        hlpr._jsSingleCheck(cmp, evt, hlpr, opIndex);
    },
    _jsSingleCheck: function (cmp, evt, hlpr, opIndex) {
        hlpr.jsClick(cmp, evt, hlpr);
        var isMultiSelect = cmp.get("v.isMultiSelect");
        let isCombobox = cmp.get('v.isCombobox');
        if (opIndex != undefined && opIndex > -1) {
            let options_ = cmp.get('v.options_');
            let selectAll = true;
            if (isMultiSelect) {
                options_[opIndex].checked = !options_[opIndex].checked;
                options_[opIndex].selected = options_[opIndex].checked;
            } else {
                if (isCombobox) {
                    options_[opIndex].selected = true;
                } else {
                    options_[opIndex].selected = !options_[opIndex].selected;
                }
                options_[opIndex].checked = options_[opIndex].selected;
            }
            options_.forEach(function (option) {
                if (isMultiSelect && option.checked === false) {
                    selectAll = false;
                } else if (option.index + '' !== opIndex) {
                    option.checked = isMultiSelect ? option.checked : false;
                    option.selected = option.checked;
                }
            })
            cmp.set('v.options_', options_);
            var selectedResult = hlpr._SelectedValues(cmp);
            cmp.set("v.selectedItems", selectedResult.values);
            cmp.set('v.selectedOptions', selectedResult.selectedOptions);
            cmp.set('v.selectAll', selectAll);
            hlpr._enqueOnChange(cmp);
        }
    },
    jsOptionOnlyClick: function (cmp, evt, hlpr) {
        let opIndex = evt.currentTarget.dataset.index;
        hlpr.jsClick(cmp, evt, hlpr);
        if (opIndex != undefined && opIndex > -1) {
            let options_ = cmp.get('v.options_');
            let selectAll = true;
            options_.forEach(function (option) {
                if (option.index + '' === opIndex) {
                    option.checked = true;
                    option.selected = option.checked;
                } else {
                    option.checked = false;
                    option.selected = option.checked;
                    selectAll = false;
                }
            })
            cmp.set('v.options_', options_);
            var selectedResult = hlpr._SelectedValues(cmp);
            cmp.set("v.selectedItems", selectedResult.values);
            cmp.set('v.selectedOptions', selectedResult.selectedOptions);
            cmp.set('v.selectAll', selectAll);
            hlpr._enqueOnChange(cmp);
        }
    },
    _SelectedValues: function (cmp) {
        var options = cmp.get("v.options_");
        var values = [];
        var labels = [];
        var count = 0;
        var selectedInd = -1;
        var isMultiSelect = cmp.get("v.isMultiSelect");
        var selectedOptions = [];
        options.forEach(function (option) {
            if (option.checked === true || option.selected === true) {
                count++;
                values.push(option.value);
                labels.push(option.label);
                selectedInd = option.index;
                let temOp = JSON.parse(JSON.stringify(option));
                ['checked', 'index', 'selected'].forEach(function (deletedKey) {
                    delete temOp[deletedKey];
                })
                selectedOptions.push(temOp);
            }
        });
        if (count === 0) {
            cmp.set('v.selectedText', '');
            cmp.set('v.isSelected', false);
        } else {
            cmp.set('v.isSelected', true);
            if (isMultiSelect) {
                if (cmp.get("v.displaySelectedValues") == true) {
                    cmp.set('v.selectedText', labels.join(', '));
                } else {
                    cmp.set('v.selectedText', 'Selected ' + count + ' Option' + (count > 1 ? 's' : '') + '.');
                }
            } else {
                cmp.set('v.selectedText', options[selectedInd].label);
            }
        }
        return {
            values: values,
            selectedOptions: selectedOptions
        };
    },
    jsFilterList: function (cmp, evt, hlpr) {
        var source = evt.currentTarget;
        var val = source ? source.value : '';
        var ele = document.getElementById(cmp.get('v.inpId'));
        if (ele) {
            val = ele.value;
        }
        if (val) {
            val = val.toLowerCase()
        }
        hlpr._setValue(cmp, hlpr, val);
    },
    _setValue: function (cmp, hlpr, val) {
        let checkFilter = cmp.get('v.checkFilter');
        var options = cmp.get("v.options_");
        var noItem = false;
        var count = 0;
        var hiddenCount = 0;
        var grpOptionSelected = {};
        var groupData = {};
        let isCombobox = cmp.get('v.isCombobox');
        options.forEach(function (element) {
            if (isCombobox) {
                element.hide = false
            } else {
                element.hide = element.label.toLowerCase().indexOf(val) < 0;
            }
            let grp = element['group'];
            if (grp) {
                grp = grp ? grp : 'Other';
                if (!groupData[grp]) {
                    groupData[grp] = [];
                }
                groupData[grp].push(element);
                if (!grpOptionSelected[grp]) {
                    grpOptionSelected[grp] = 0
                }
            }
            if (element.hide) {
                hiddenCount++;
            } else if (grp) {
                grpOptionSelected[element.group] = grpOptionSelected[element.group] + 1;
            }
            count++;
        });

        for (let grp in grpOptionSelected) {
            let visible = grpOptionSelected[grp] > 0;
            if (visible) {
                groupData[grp][0]['isGroup'] = true;
            } else {
                groupData[grp][0]['isGroup'] = false;
            }
        }

        noItem = hiddenCount == count;
        cmp.set("v.options_", options);
        cmp.set("v.noItem", noItem);
        cmp.set('v.checkFilter', true);
        if (checkFilter === true) {
            cmp.set('v.checkFilter', false);
        }
    },
    jsClick: function (cmp, evt, hlpr) {
        window.setTimeout(
            $A.getCallback(function () {
                var mainDiv = cmp.find('main-div');
                $A.util.addClass(mainDiv, 'slds-is-open');
            }), 10
        );
    },
    jsSelection: function (cmp, evt, hlpr) {
        window.setTimeout(
            $A.getCallback(function () {
                cmp.find('inpSearch').getElement().focus();
            }), 10
        );
    },
    jsMouseLeave: function (cmp, evt, hlpr) {

        window.setTimeout(
            $A.getCallback(function () {
                let isCombobox = cmp.get('v.isCombobox');
                if (!isCombobox) {
                    var ele = document.getElementById(cmp.get('v.inpId'));
                    // if found then only need to access
                    if (ele) {
                        ele.value = '';
                    }
                }
                var mainDiv = cmp.find('main-div');
                $A.util.removeClass(mainDiv, 'slds-is-open');
                hlpr.jsFilterList(cmp, evt, hlpr);
            }), 10
        );
    },
    jsDown: function (cmp, evt, hlpr) {
        evt.preventDefault();
        let opIndex = evt.getSource().get('v.name');
        hlpr._jsSingleCheck(cmp, evt, hlpr, opIndex);
    },
    jsMasterChange: function (cmp, evt, hlpr) {
        let selectAll = !cmp.get('v.selectAll');
        hlpr.jsMouseLeave(cmp, evt, hlpr);
        let options_ = cmp.get('v.options_');
        options_.forEach(function (option) {
            option.checked = selectAll;
            option.selected = option.checked;
        })
        cmp.set('v.selectAll', selectAll);
        cmp.set("v.options_", options_);
        var selectedResult = hlpr._SelectedValues(cmp);
        cmp.set("v.selectedItems", selectedResult.values);
        cmp.set('v.selectedOptions', selectedResult.selectedOptions);
        hlpr._enqueOnChange(cmp);
    },
    jsOptionSelection: function (cmp, evt, hlpr) {
        let index = evt.currentTarget.dataset.index;
        hlpr._jsSingleCheck(cmp, evt, hlpr, index);

    },
    jsResetSelection: function (cmp, evt, hlpr) {
        let options_ = cmp.get('v.options_');
        options_.forEach(function (option) {
            option.checked = false;
            option.selected = false;
        })
        cmp.set('v.options_', options_);
        var selectedResult = hlpr._SelectedValues(cmp);
        cmp.set("v.selectedItems", selectedResult.values);
        cmp.set('v.selectedOptions', selectedResult.selectedOptions);
        hlpr._enqueOnChange(cmp);
    },
    jsSet: function (cmp, evt, hlpr) {
        let params = evt.getParams();
        if (params.arguments) {
            let attr = params.arguments.attr;
            if (attr == 'v.value') {
                let value = params.arguments.value;
                let options_ = cmp.get('v.options_');
                let selectAll = true;
                options_.forEach(function (option) {
                    if (option.value == value) {
                        option.selected = true;
                        option.checked = true;
                    } else {
                        option.selected = false;
                        option.checked = false;
                        selectAll = false;
                    }
                })
                cmp.set('v.options_', options_);
                var selectedResult = hlpr._SelectedValues(cmp);
                cmp.set("v.selectedItems", selectedResult.values);
                cmp.set('v.selectedOptions', selectedResult.selectedOptions);
                cmp.set('v.selectAll', selectAll);
                hlpr._enqueOnChange(cmp);
            }
        }
    },
    _enqueOnChange: function (cmp) {
        var onchange = cmp.get('v.onchange');
        if (onchange) {
            $A.enqueueAction(onchange);
        }
    },
    jsFocus: function (cmp, evt, hlpr) {
        let inpId = cmp.get("v.inpId");
        let focusSet = false;
        if (inpId) {
            let eles = cmp.getElement().querySelectorAll('input#' + inpId);
            if (eles && eles.length > 0 && eles[0].focus) {
                eles[0].focus();
                focusSet = false;
            }
        }
        if (!focusSet) {
            let eles = cmp.getElement().querySelectorAll('input.slds-input.slds-combobox__input');
            if (eles && eles.length > 0 && eles[0].focus) {
                eles[0].focus();
                focusSet = false;
            }
        }
    },
})