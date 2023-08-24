({
    config: {selectAll: {label: 'Select FROM Parent', text:'SELECT_FROM_PARENT'}},
    _doHelpLinkConfig: function(cmp, hlpr){
        let helpLinks = cmp.get("v.helpLinks");
        if(helpLinks.select_all_config){
            hlpr.config.selectAll = helpLinks.select_all_config;
        }
    },
    jsDoInit: function (component, helper) {
        helper._doHelpLinkConfig(component, helper);
        component.set("v.spinner", 'message-loading');
        helper.serverConnect(component, helper, 'getOrgWideEmailAddress', {}, helper._orgWideEmailAddressJS);
        if (component.get("v.selectScheduleAttendees") != null && component.get("v.selectScheduleAttendees") != undefined && component.get("v.selectScheduleAttendees") != '') {
            helper.serverConnect(component, helper, 'getAttendeeFilterOptions', {
                objectName: component.get("v.selectScheduleAttendees")
            }, helper._attendeeFilterOptionsJS);
        }
        helper._preparePhoneAndEmailOptions(component, helper);

        //Fetch available phone numbers if SMS package installed, account configured and user's have sms permissions
        if (component.get("v.allowSMS")) {
            helper.fetchAvailableFromNumbers(component, helper);
        }

        let selectedAttendeeFilter = component.get("v.selectedAttendeeFilter");
        if (!$A.util.isUndefinedOrNull(selectedAttendeeFilter) && !$A.util.isEmpty(selectedAttendeeFilter)) {
            helper.selectedAttendeeFilterOptionsJS(component, helper);
        }
        let selectedAttendeeFilterValue = component.get("v.selectedAttendeeFilterValue");
        if (!$A.util.isUndefinedOrNull(selectedAttendeeFilterValue) && !$A.util.isEmpty(selectedAttendeeFilterValue)) {
            let selectedAttendeeFilterOptions = component.find("selectedAttendeeFilterOptions");
            if (selectedAttendeeFilterOptions) {
                selectedAttendeeFilterOptions.reInit();
            }
        }

        let filter = '';
        if (component.get("v.selectScheduleAttendees") != null && component.get("v.selectScheduleAttendees") != undefined && component.get("v.selectScheduleAttendees") != '') {
            filter = component.get("v.selectedAttendeeFilterCriteria");
            if (!$A.util.isUndefinedOrNull(filter) && !$A.util.isEmpty(filter)) {
                filter = ' (' + filter + ') ';
            }
        }

        try {
            helper.fetchTotalAttendeeCount(component, helper, filter);
        } catch (err) {}

        let accordionSection = component.find("accordion");
        if (accordionSection) {
            accordionSection.set("v.activeSectionName", ['Recipients']);
        }
    },

    jsSectionToggle: function (cmp, evt, hlpr) {
        let sourceId = evt.getSource().getLocalId();
        let allowSectionToggle = true;
        let messageCmp = cmp.find("message");
        if (messageCmp && sourceId != 'accordion_message') {
            allowSectionToggle = messageCmp.validateSectionToggleForm();
        }
        if (allowSectionToggle) {
            let isOpen = evt.getParam('openSections').length > 0;
            if (isOpen) {
                hlpr._setupActiveSectionNameWhenOpen(cmp, hlpr, sourceId);
            }
        } else {
            hlpr._setupActiveSectionName(cmp, hlpr);
        }
    },
    _setupActiveSectionNameWhenOpen: function (cmp, hlpr, sourceId) {
        switch (sourceId) {
            case 'accordion':
                cmp.set("v.selectedActiveSectionName", "Recipients");
                break;
            case 'accordion_schedule':
                cmp.set("v.selectedActiveSectionName", "Schedule");
                break;
            case 'accordion_message':
                cmp.set("v.selectedActiveSectionName", "Message");
                break;
            case 'accordion_preview':
                cmp.set("v.selectedActiveSectionName", "Preview");
                break;
            default:
                break;
        }
    },
    _setupActiveSectionName: function (cmp, hlpr) {
        let accordion_section = cmp.find('accordion');
        if (accordion_section) {
            accordion_section.set('v.activeSectionName', '');
        }
        let accordion_schedule_section = cmp.find('accordion_schedule');
        if (accordion_schedule_section) {
            accordion_schedule_section.set('v.activeSectionName', '');
        }
        let accordion_message_section = cmp.find('accordion_message');
        if (accordion_message_section) {
            accordion_message_section.set('v.activeSectionName', 'Message');
        }
        let accordion_preview_section = cmp.find('accordion_preview');
        if (accordion_preview_section) {
            accordion_preview_section.set('v.activeSectionName', '');
        }
        cmp.set("v.selectedActiveSectionName", "Message");
    },
    _preparePhoneAndEmailOptions: function (component, helper) {
        let sendSMSToOptionsArr = [];
        let sendToEmailOptionsArr = [];
        let mapSobjectFieldsWithType = component.get("v.mapSobjectFieldsWithType");
        let related_object = component.get("v.scheduleObj.Related_Object");
        if (mapSobjectFieldsWithType != null && mapSobjectFieldsWithType != undefined) {
            for (let key in mapSobjectFieldsWithType) {
                if (key === 'phone') {
                    let newMap = mapSobjectFieldsWithType[key];
                    for (let newMapKey in newMap) {
                        let label_phone = newMap[newMapKey].label;
                        if (!$A.util.isUndefinedOrNull(related_object) && !$A.util.isEmpty(related_object) && (related_object === 'conference360__Attendee__c' || related_object === 'conference360__Session_Attendee__c')) {
                            if (label_phone.indexOf('(Deprecated)') != -1) {
                                label_phone = label_phone.replace('(Deprecated)', '').trim();
                            } else if (label_phone.indexOf('Deprecated') != -1) {
                                label_phone = label_phone.replace('Deprecated', '').trim();
                            }
                        }
                        let value_phone = newMap[newMapKey].name;
                        if (!$A.util.isUndefinedOrNull(related_object) && !$A.util.isEmpty(related_object) && related_object === 'conference360__Session_Attendee__c') {
                            label_phone = 'Attendee > ' + label_phone;
                            value_phone = 'conference360__Attendee__r.' + value_phone;
                        }
                        sendSMSToOptionsArr.push({
                            'label': label_phone,
                            'value': value_phone
                        });
                    }
                } else if (key === 'email') {
                    let newMap = mapSobjectFieldsWithType[key];
                    for (let newMapKey in newMap) {
                        let label_email = newMap[newMapKey].label;
                        if (!$A.util.isUndefinedOrNull(related_object) && !$A.util.isEmpty(related_object) && related_object === 'conference360__Attendee__c' && label_email.indexOf('Deprecated') == -1) {
                            sendToEmailOptionsArr.push({
                                'label': label_email,
                                'value': newMap[newMapKey].name
                            });
                        } else if (!$A.util.isUndefinedOrNull(related_object) && !$A.util.isEmpty(related_object) && related_object != 'conference360__Attendee__c') {
                            sendToEmailOptionsArr.push({
                                'label': label_email,
                                'value': newMap[newMapKey].name
                            });
                        } else if ($A.util.isUndefinedOrNull(related_object) || $A.util.isEmpty(related_object)) {
                            sendToEmailOptionsArr.push({
                                'label': label_email,
                                'value': newMap[newMapKey].name
                            });
                        }
                    }
                }
            }
        }

        let scheduleObj = component.get("v.scheduleObj");
        if (scheduleObj.Action == 'Email' && scheduleObj.Email_To_Address && scheduleObj.Email_To_Address.indexOf('.') !== -1) {
            sendToEmailOptionsArr.push({
                'label': '[' + related_object + '].' + scheduleObj.Email_To_Address,
                'value': scheduleObj.Email_To_Address
            });
            helper._prepareReferenceOptions(component, helper, scheduleObj.Email_To_Address);
        } else if (scheduleObj.Action == 'SMS' && scheduleObj.SMS_To_Number && scheduleObj.SMS_To_Number.indexOf('.') !== -1) {
            let configChioces = false;
            if (scheduleObj.SObject_RecordId) {
                configChioces = scheduleObj.SMS_To_Number != 'conference360__Attendee__r.conference360__Phone__c';
            } else {
                configChioces = true;
            }
            if (configChioces) {
                sendSMSToOptionsArr.push({
                    'label': '[' + related_object + '].' + scheduleObj.SMS_To_Number,
                    'value': scheduleObj.SMS_To_Number
                });
                helper._prepareReferenceOptions(component, helper, scheduleObj.SMS_To_Number);
            }
        }

        let smsToNumber = component.get("v.scheduleObj.SMS_To_Number");
        if (sendSMSToOptionsArr.length > 0) {
            sendSMSToOptionsArr = sendSMSToOptionsArr.sort(function (a, b) {
                let t1 = a.label == b.label,
                    t2 = a.label < b.label;
                return t1 ? 0 : ('ASC' ? -1 : 1) * (t2 ? 1 : -1);
            });

            let matchFound = false;
            if (!$A.util.isUndefinedOrNull(smsToNumber) && !$A.util.isEmpty(smsToNumber)) {
                sendSMSToOptionsArr.forEach((option) => {
                    if (option.value == smsToNumber) {
                        matchFound = true;
                    }
                });
            }

            if ($A.util.isUndefinedOrNull(smsToNumber) || $A.util.isEmpty(smsToNumber) || !matchFound) {
                smsToNumber = sendSMSToOptionsArr[0].value;
            }
        }
        sendSMSToOptionsArr.push({
            'label': helper.config.selectAll.label,
            'value': helper.config.selectAll.text
        });
        component.set("v.scheduleObj.SMS_To_Number", smsToNumber);
        component.set("v.sendSMSToOptions", sendSMSToOptionsArr);


        let emailToAddress = component.get("v.scheduleObj.Email_To_Address");
        if (sendToEmailOptionsArr.length > 0) {
            sendToEmailOptionsArr = sendToEmailOptionsArr.sort(function (a, b) {
                let t1 = a.label == b.label,
                    t2 = a.label < b.label;
                return t1 ? 0 : ('ASC' ? -1 : 1) * (t2 ? 1 : -1);
            });

            let emailMatchFound = false;
            if (!$A.util.isUndefinedOrNull(emailToAddress) && !$A.util.isEmpty(emailToAddress)) {
                sendToEmailOptionsArr.forEach((option) => {
                    if (option.value == emailToAddress) {
                        emailMatchFound = true;
                    }
                });
            }

            if ($A.util.isUndefinedOrNull(emailToAddress) || $A.util.isEmpty(emailToAddress) || !emailMatchFound) {
                emailToAddress = sendToEmailOptionsArr[0].value;
            }
        }
        sendToEmailOptionsArr.push({
            'label': helper.config.selectAll.label,
            'value': helper.config.selectAll.text
        });
        component.set("v.scheduleObj.Email_To_Address", emailToAddress);
        component.set("v.sendToEmailOptions", sendToEmailOptionsArr);
    },

    fetchAssociateReference: function (component, helper, sObjectName, relationshipName) {
        helper.serverConnect(component, helper, 'getAssociateReference', {
            'sObjectName': sObjectName,
            'relationshipName': relationshipName
        }, helper._AssociateReferenceHelper);
    },

    _AssociateReferenceHelper: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        let AssociateWithReferencedRecordOptionsArr = [];
        if (result) {
            AssociateWithReferencedRecordOptionsArr.push({
                'label': result.associateReference,
                'value': 'true',
                'queryFieldRelationshipName': result.relationshipName
            });
            AssociateWithReferencedRecordOptionsArr.push({
                'label': result.sObjectName,
                'value': 'false'
            });
        }
        component.set("v.scheduleObj.AssociateWithReferencedRecordOptions", AssociateWithReferencedRecordOptionsArr);
    },

    _attendeeFilterOptionsJS: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        let opt = [];
        opt.push({
            'label': '-None-',
            value: ''
        });
        for (let key in result) {
            opt.push({
                'value': key,
                'label': result[key]
            });
            if (key == component.get("v.selectedAttendeeFilter")) {
                component.set("v.selectedAttendeeFilterLabel", result[key]);
            }
        }
        component.set("v.attendeeFilterOptions", opt);
    },

    _orgWideEmailAddressJS: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        let opt = [];
        if (component.get("v.selectScheduleType").toLowerCase() === 'email') {
            if (result != null && result != undefined && result.length > 0) {
                for (let i = 0; i < result.length; i++) {
                    opt.push({
                        'label': result[i],
                        'value': result[i]
                    });
                }
            }
        }
        component.set("v.fromEmailAddressOptions", opt);
        let email_From_Address = component.get("v.scheduleObj.Email_From_Address");
        if ($A.util.isUndefinedOrNull(email_From_Address) || $A.util.isEmpty(email_From_Address)) {
            if (opt.length > 0) {
                component.set("v.scheduleObj.Email_From_Address", opt[0].value);
            }
        }
        helper.jsFromEmailAddressChange(component, null, helper);
    },

    fetchAvailableFromNumbers: function (component, helper) {
        helper.serverConnect(component, helper, 'getAvailableFromNumbers', {}, helper._AvailableFromNumbers);
    },

    _AvailableFromNumbers: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        let sendSMSFromOptionsArr = [];
        if (component.get("v.selectScheduleType").toLowerCase() === 'sms') {
            for (let key in result) {
                sendSMSFromOptionsArr.push({
                    'label': result[key],
                    'value': key
                });
            }
        }
        component.set("v.sendSMSFromOptions", sendSMSFromOptionsArr);

        let sMS_From_Number = component.get("v.scheduleObj.SMS_From_Number");
        if ($A.util.isUndefinedOrNull(sMS_From_Number) || $A.util.isEmpty(sMS_From_Number)) {
            if (sendSMSFromOptionsArr.length > 0) {
                component.set("v.scheduleObj.SMS_From_Number", sendSMSFromOptionsArr[0].value);
            }
        }
    },

    fetchTotalAttendeeCount: function (component, helper, filter) {
        let scheduleObj = Object.assign({}, component.get("v.scheduleObj"));
        if (!$A.util.isUndefinedOrNull(filter) && !$A.util.isEmpty(filter)) {
            if (!$A.util.isUndefinedOrNull(scheduleObj.SObject_RecordId) && !$A.util.isEmpty(scheduleObj.SObject_RecordId)) {
                if (!$A.util.isUndefinedOrNull(scheduleObj.Related_Object_FieldAPIName) && !$A.util.isEmpty(scheduleObj.Related_Object_FieldAPIName)) {
                    if (filter.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                        filter = filter.replace('Id', scheduleObj.Related_Object_FieldAPIName);
                    }
                    if (filter.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                        filter = filter.replace('conference360__Session__r.conference360__Event__c', scheduleObj.Related_Object_FieldAPIName);
                    }
                    if (filter.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                        filter = filter.replace('conference360__Event__c', scheduleObj.Related_Object_FieldAPIName);
                    }
                }
                filter = ' WHERE (' + filter + ') ';
                if (!$A.util.isUndefinedOrNull(scheduleObj.Base_Object_Evaluate_Criteria) && !$A.util.isEmpty(scheduleObj.Base_Object_Evaluate_Criteria)) {
                    if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                        scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace('Id', scheduleObj.Related_Object_FieldAPIName);
                    }
                    if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                        scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace('conference360__Session__r.conference360__Event__c', scheduleObj.Related_Object_FieldAPIName);
                    }
                    if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                        scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace('conference360__Event__c', scheduleObj.Related_Object_FieldAPIName);
                    }
                    filter += ' AND (' + scheduleObj.Base_Object_Evaluate_Criteria + ') ';
                }
            } else if (!$A.util.isUndefinedOrNull(scheduleObj.Base_Object_Evaluate_Criteria) && !$A.util.isEmpty(scheduleObj.Base_Object_Evaluate_Criteria)) {
                let criteria_obj = JSON.parse(scheduleObj.Base_Object_Evaluate_Criteria_JSON);
                if (!$A.util.isUndefinedOrNull(criteria_obj.filters) && !$A.util.isEmpty(criteria_obj.filters)) {
                    for (let i = 0; i < criteria_obj.filters.length; i++) {
                        if (!$A.util.isUndefinedOrNull(criteria_obj.filters[i].f)) {
                            let filter_val = ' ' + scheduleObj.Related_Object_Relationship_Name + '.' + criteria_obj.filters[i].f;
                            if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(filter_val) == -1) {
                                let rx = new RegExp("(^|\\s)" + criteria_obj.filters[i].f.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + "(?!\\S)", "gi");
                                scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace(rx, filter_val);
                            }
                        }
                    }
                    filter += ' AND ( ' + scheduleObj.Base_Object_Evaluate_Criteria + ' ) ';
                }
            } else {
                filter = ' WHERE (' + filter + ') ';
            }
        } else if ($A.util.isUndefinedOrNull(scheduleObj.SObject_RecordId) || $A.util.isEmpty(scheduleObj.SObject_RecordId)) {
            if (!$A.util.isUndefinedOrNull(scheduleObj.Related_Object) && !$A.util.isEmpty(scheduleObj.Related_Object) && !$A.util.isUndefinedOrNull(scheduleObj.Related_Object_Evaluate_Criteria) && !$A.util.isEmpty(scheduleObj.Related_Object_Evaluate_Criteria)) {
                filter = ' WHERE ( (' + scheduleObj.Related_Object_Evaluate_Criteria + ')';
                if (!$A.util.isUndefinedOrNull(scheduleObj.Base_Object_Evaluate_Criteria) && !$A.util.isEmpty(scheduleObj.Base_Object_Evaluate_Criteria)) {
                    let criteria_obj = JSON.parse(scheduleObj.Base_Object_Evaluate_Criteria_JSON);
                    if (!$A.util.isUndefinedOrNull(criteria_obj.filters) && !$A.util.isEmpty(criteria_obj.filters)) {
                        for (let i = 0; i < criteria_obj.filters.length; i++) {
                            if (!$A.util.isUndefinedOrNull(criteria_obj.filters[i].f)) {
                                let filter_val = ' ' + scheduleObj.Related_Object_Relationship_Name + '.' + criteria_obj.filters[i].f;
                                if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(filter_val) == -1) {
                                    let rx = new RegExp("(^|\\s)" + criteria_obj.filters[i].f.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + "(?!\\S)", "gi");
                                    scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace(rx, filter_val);
                                }
                            }
                        }
                        filter += ' AND ( ' + scheduleObj.Base_Object_Evaluate_Criteria + ' ) ';
                    }
                }
                filter += ' ) ';
            } else if (!$A.util.isUndefinedOrNull(scheduleObj.Related_Object) && !$A.util.isEmpty(scheduleObj.Related_Object)) {
                if (!$A.util.isUndefinedOrNull(scheduleObj.Base_Object_Evaluate_Criteria) && !$A.util.isEmpty(scheduleObj.Base_Object_Evaluate_Criteria)) {
                    let criteria_obj = JSON.parse(scheduleObj.Base_Object_Evaluate_Criteria_JSON);
                    if (!$A.util.isUndefinedOrNull(criteria_obj.filters) && !$A.util.isEmpty(criteria_obj.filters)) {
                        for (let i = 0; i < criteria_obj.filters.length; i++) {
                            if (!$A.util.isUndefinedOrNull(criteria_obj.filters[i].f)) {
                                let filter_val = ' ' + scheduleObj.Related_Object_Relationship_Name + '.' + criteria_obj.filters[i].f;
                                if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(filter_val) == -1) {
                                    let rx = new RegExp("(^|\\s)" + criteria_obj.filters[i].f.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + "(?!\\S)", "gi");
                                    scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace(rx, filter_val);
                                }
                            }
                        }
                        filter += ' WHERE ( ' + scheduleObj.Base_Object_Evaluate_Criteria + ' ) ';
                    }
                }
            } else if (!$A.util.isUndefinedOrNull(scheduleObj.Base_Object_Evaluate_Criteria) && !$A.util.isEmpty(scheduleObj.Base_Object_Evaluate_Criteria)) {
                filter = ' WHERE (' + scheduleObj.Base_Object_Evaluate_Criteria + ') ';
            }
        } else if (!$A.util.isUndefinedOrNull(scheduleObj.SObject_RecordId) && !$A.util.isEmpty(scheduleObj.SObject_RecordId) && !$A.util.isUndefinedOrNull(scheduleObj.Base_Object_Evaluate_Criteria) && !$A.util.isEmpty(scheduleObj.Base_Object_Evaluate_Criteria)) {
            if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                    scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace('Id', scheduleObj.Related_Object_FieldAPIName);
                }
                if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                    scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace('conference360__Session__r.conference360__Event__c', scheduleObj.Related_Object_FieldAPIName);
                }
                if (scheduleObj.Base_Object_Evaluate_Criteria.indexOf(scheduleObj.Related_Object_FieldAPIName) == -1) {
                    scheduleObj.Base_Object_Evaluate_Criteria = scheduleObj.Base_Object_Evaluate_Criteria.replace('conference360__Event__c', scheduleObj.Related_Object_FieldAPIName);
                }
            }
            filter = ' WHERE (' + scheduleObj.Base_Object_Evaluate_Criteria + ') ';
        }

        let related_Object_FieldAPIName = component.get("v.scheduleObj.Related_Object_FieldAPIName");
        if (!$A.util.isUndefinedOrNull(related_Object_FieldAPIName) && !$A.util.isEmpty(related_Object_FieldAPIName)) {
            if (!$A.util.isUndefinedOrNull(filter) && !$A.util.isEmpty(filter)) {
                filter += ' AND ' + related_Object_FieldAPIName + ' != null';
            } else {
                filter += ' WHERE ' + related_Object_FieldAPIName + ' != null';
            }
        }
        component.set("v.filter", filter);
        helper.serverConnect(component, helper, 'getTotalAttendeeCount', {
            objName: component.get("v.selectScheduleAttendees"),
            filter: filter
        }, helper._TotalAttendeeCount);
    },

    _TotalAttendeeCount: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        if (!$A.util.isUndefinedOrNull(result)) {
            component.set("v.scheduleObj.Recipient", result);
        } else {
            component.set("v.scheduleObj.Recipient", 0);
        }
    },

    handleAttendeeFilterChangeJS: function (component, helper) {
        let filter = '';
        let filterJSON = '';
        let selectedAttendeeFilterValue = component.get("v.selectedAttendeeFilterValue");
        let selectedAttendeeFilter = component.get("v.selectedAttendeeFilter");
        if (selectedAttendeeFilter != null && selectedAttendeeFilter != '' && selectedAttendeeFilter != undefined) {
            filter += ' ' + selectedAttendeeFilter + ' != null';
            filterJSON = '{"logic_exp":"1", "filters":[{"f_id":1,"f":"' + selectedAttendeeFilter + '","op":"is_not_null","val":null,"f_type":"PICKLIST"}]}';
            if (selectedAttendeeFilterValue != null && selectedAttendeeFilterValue != undefined && selectedAttendeeFilterValue.length > 0) {
                filter += ' AND ' + selectedAttendeeFilter + ' IN (';
                let glue = '';
                let pick_values = ''
                for (let i = 0; i < selectedAttendeeFilterValue.length; i++) {
                    if (selectedAttendeeFilterValue[i].indexOf("'") != -1) {
                        pick_values += glue + selectedAttendeeFilterValue[i];
                        glue = ',';
                    } else {
                        pick_values += glue + "'" + selectedAttendeeFilterValue[i] + "'";
                        glue = ',';
                    }
                }
                filter += pick_values + ' )';
                filterJSON = '{"logic_exp":"1 AND 2", "filters":[{"f_id":1,"f":"' + selectedAttendeeFilter + '","op":"is_not_null","val":null,"f_type":"PICKLIST"}, {"f_id":2,"f":"' + selectedAttendeeFilter + '","op":"=","val":"' + pick_values + '"}]}';

            }
        }
        component.set("v.filter", filter);
        component.set("v.scheduleObj.Related_Object_Evaluate_Criteria", filter);
        component.set('v.scheduleObj.Related_Object_Evaluate_Criteria_JSON', filterJSON);
        if (component.get("v.selectScheduleAttendees") != null && component.get("v.selectScheduleAttendees") != undefined && component.get("v.selectScheduleAttendees") != '') {
            window.setTimeout($A.getCallback(function () {
                helper.fetchTotalAttendeeCount(component, helper, filter);
            }), 500);
        }
    },

    selectedAttendeeFilterLabelJS: function (component) {
        let attendeeFilterOptions = component.get("v.attendeeFilterOptions");
        if (attendeeFilterOptions != null && attendeeFilterOptions != undefined) {
            for (let i = 0; i < attendeeFilterOptions.length; i++) {
                if (attendeeFilterOptions[i].value == component.get("v.selectedAttendeeFilter")) {
                    component.set("v.selectedAttendeeFilterLabel", attendeeFilterOptions[i].label);
                }
            }
        }
    },

    selectedAttendeeFilterOptionsJS: function (component, helper) {
        component.set("v.selectedAttendeeFilterOptions", []);
        let attendeeFilter = component.get("v.selectedAttendeeFilter");
        if (attendeeFilter != null && attendeeFilter != undefined && attendeeFilter != '') {
            helper.serverConnect(component, helper, 'getPicklistValues', {
                objectName: component.get("v.selectScheduleAttendees"),
                fieldName: component.get("v.selectedAttendeeFilter")
            }, helper._selectedAttendeeFilterOptionsJS);
        }
    },

    _selectedAttendeeFilterOptionsJS: function (component, helper, response, cbInfo) {
        let result = response.getReturnValue();
        let opt = [];
        for (let key in result) {
            opt.push({
                'label': key,
                'value': result[key]
            });
        }
        component.set("v.selectedAttendeeFilterOptions", opt);
    },

    viewTotalRecipientsJS: function (component, helper) {
        component.set("v.isShowViewRecipientsModal", true);
    },
    _prepareFilters: function (cmp, hlpr, filterKey) {
        let baseObjectCriteria = cmp.get("v.scheduleObj." + filterKey.toLowerCase() + "ObjectCriteria");
        if (baseObjectCriteria === 'matchCriteria') {
            let sObjectFilterBase = cmp.find("sObjectFilter" + filterKey);
            if (sObjectFilterBase) {
                let filterData = sObjectFilterBase.getQueryFilter();
                if (filterData) {
                    if (filterData.validity) {
                        hlpr._maintainFilterData(cmp, filterKey, filterData);
                    } else {
                        hlpr._showMessage(cmp, {
                            message: filterData.message,
                            type: "error"
                        });
                        return false;
                    }
                }
            }
        } else {
            cmp.set('v.scheduleObj.' + filterKey + '_Object_Evaluate_Criteria', '');
            cmp.set('v.scheduleObj.' + filterKey + '_Object_Evaluate_Criteria_JSON', '');
        }
        return true;
    },
    submitRecipientsJS: function (component, helper) {
        let isValid = helper.jsValidate(component, helper);
        if (isValid) {
            let currentStepCount = component.get("v.currentStep");
            if (currentStepCount < 2) {
                component.set("v.currentStep", 2);
                component.set("v.selectedActiveSectionName", "Schedule");
            }
            let accordin_Recipients = component.find("accordion");
            if (accordin_Recipients) {
                accordin_Recipients.set("v.activeSectionName", []);
            }

            let accordion_schedule = component.find("accordion_schedule");
            if (accordion_schedule) {
                accordion_schedule.set("v.activeSectionName", ['Schedule']);
            }
        }
    },
    validatedFormJS: function (component, helper) {
        let isValid = helper.jsValidate(component, helper);
        if (isValid) {
            let scheduleCmp = component.find("schedule");
            if (scheduleCmp) {
                isValid = scheduleCmp.validateScheduleNowForm();
            }
            let emailmessageCmp = component.find("email_message");
            if (emailmessageCmp && isValid) {
                isValid = emailmessageCmp.validateScheduleForm();
            }
            let messageCmp = component.find("message");
            if (messageCmp && isValid) {
                isValid = messageCmp.validateScheduleForm();
            }
        }
        return isValid;
    },

    jsValidate: function (component, helper) {
        let isValid = (this).validateForm(component, 'name,smsfrom,smsto,fromemailaddress,toemail');
        if (isValid) {
            let relatedRecordId = component.get("v.relatedRecordId");
            if ($A.util.isUndefinedOrNull(relatedRecordId) || $A.util.isEmpty(relatedRecordId)) {
                isValid = helper._prepareFilters(component, helper, "Base");
                if (!isValid) {
                    return isValid;
                }
                isValid = helper._prepareFilters(component, helper, "Related");
                if (!isValid) {
                    return isValid;
                }
            }

            let related_object = component.get("v.scheduleObj.Related_Object");
            if ($A.util.isUndefinedOrNull(related_object) || $A.util.isEmpty(related_object)) {
                isValid = false;
                (this)._showMessage(component, {
                    message: 'Please choose Related Object',
                    type: "error"
                });
            }
        } else {
            (this)._showMessage(component, {
                message: 'Please fill all required fields and try again.',
                type: "error"
            });
        }
        return isValid;
    },

    jsCreteriaChanged: function (cmp, evt, hlpr) {
        let src = evt.getSource();
        if (src) {
            let fname = src.get("v.name");
            let val = src.getLocalId();
            if (val === 'noCriteria') {
                if (fname === 'baseObjectCriteria') {
                    cmp.set('v.scheduleObj.Base_Object_Evaluate_Criteria', '');
                    cmp.set('v.scheduleObj.Base_Object_Evaluate_Criteria_JSON', '');
                } else if (fname === 'relatedObjectCriteria') {
                    cmp.set('v.scheduleObj.Related_Object_Evaluate_Criteria', '');
                    cmp.set('v.scheduleObj.Related_Object_Evaluate_Criteria_JSON', '');
                }
            }
            cmp.set("v.scheduleObj." + fname, val);
            hlpr.fetchTotalAttendeeCount(cmp, hlpr, '');
        }
    },
    jsChangesObjectFilterBase: function (cmp, evt, hlpr) {
        let filter = cmp.find("sObjectFilterBase");
        let filterData = filter.getFilters();
        if (filterData && filterData.validity == true) {
            hlpr._maintainFilterData(cmp, 'Base', filterData);
        } else {
            cmp.set('v.scheduleObj.Base_Object_Evaluate_Criteria', '');
            cmp.set('v.scheduleObj.Base_Object_Evaluate_Criteria_JSON', '');
        }
        hlpr.fetchTotalAttendeeCount(cmp, hlpr, '');
    },
    jsChangesObjectFilterRelated: function (cmp, evt, hlpr) {
        let filter = cmp.find("sObjectFilterRelated");
        let filterData = filter.getFilters();
        if (filterData && filterData.validity == true) {
            hlpr._maintainFilterData(cmp, 'Related', filterData);
        } else {
            cmp.set('v.scheduleObj.Related_Object_Evaluate_Criteria', '');
            cmp.set('v.scheduleObj.Related_Object_Evaluate_Criteria_JSON', '');
        }
        hlpr.fetchTotalAttendeeCount(cmp, hlpr, '');
    },
    _maintainFilterData: function (cmp, filterKey, filterData) {
        if (filterData && filterData.validity == true) {
            // use filter and json to store with record
            cmp.set('v.scheduleObj.' + filterKey + '_Object_Evaluate_Criteria', filterData.query_filter);
            delete filterData.query_filter;
            delete filterData.validity;
            delete filterData.message;
            if (filterData.filters) {
                filterData.filters.forEach((element) => {
                    if (element.filter) {
                        delete element.filter;
                    }
                });
            }
            cmp.set('v.scheduleObj.' + filterKey + '_Object_Evaluate_Criteria_JSON', JSON.stringify(filterData));
        }
    },
    jsToEmailChange: function (cmp, evt, hlpr) {
        let selectedValue = evt.getSource().get("v.value");
        let configChioces = false;
        let scheduleObj = cmp.get("v.scheduleObj")
        if (selectedValue == hlpr.config.selectAll.text) {
            cmp.set("v.allowFieldSelection", true);
            return;
        } else if (selectedValue.indexOf('.') != -1) {
            if (scheduleObj.SObject_RecordId) {
                configChioces = selectedValue != 'conference360__Attendee__r.conference360__Phone__c';
            } else {
                configChioces = true;
            }
        }
        if (configChioces) {
            hlpr._prepareReferenceOptions(cmp, hlpr, selectedValue);
            cmp.set("v.scheduleObj.Associate_With_Referenced_Record", 'true');
        } else {
            cmp.set("v.scheduleObj.AssociateWithReferencedRecordOptions", []);
            cmp.set("v.scheduleObj.Associate_With_Referenced_Record", 'false');
        }
    },
    jsChangesObjectToEmailSelector: function (cmp, evt, hlpr) {
        let filter = cmp.find("sObjectFieldSelector");
        let filterData = filter.getFilters();
        let AssociateWithReferencedRecordOptionsArr = [];
        let fVal = '';
        if (filterData && filterData.data && filterData.data[0].queryFieldTooltip && filterData.data[0].queryField) {
            let scheduleObj = cmp.get("v.scheduleObj");
            if (filterData.data[0].queryField.indexOf('.') != -1) {
                let queryFieldRelationshipName = filterData.data[0].queryFieldTooltip.substring(0, filterData.data[0].queryFieldTooltip.lastIndexOf("."));
                let relationshipName = '';
                let glue = '';
                if (filterData.data[0].selectedFields) {
                    filterData.data[0].selectedFields.forEach(function (data) {
                        if (data.field.type == "REFERENCE") {
                            relationshipName += glue + data.field.sObjectName;
                            glue = '.';
                        }
                    });
                }
                if (relationshipName != '') {
                    relationshipName = queryFieldRelationshipName.substring(0, queryFieldRelationshipName.indexOf(']') + 2) + relationshipName;
                }
                AssociateWithReferencedRecordOptionsArr.push({
                    'label': relationshipName,
                    'value': 'true',
                    'queryFieldRelationshipName': queryFieldRelationshipName.substring(queryFieldRelationshipName.indexOf('].') + 2, queryFieldRelationshipName.length)
                });
                AssociateWithReferencedRecordOptionsArr.push({
                    'label': (scheduleObj.Related_Object ? scheduleObj.Related_Object : scheduleObj.Base_Object),
                    'value': 'false'
                });
            }

            if (scheduleObj.Action == 'Email') {
                let sendToEmailOptionsArr = cmp.get("v.sendToEmailOptions");
                sendToEmailOptionsArr.pop();
                let isFieldAlreadyExist = false;
                for (let i = 0; i < sendToEmailOptionsArr.length; i++) {
                    if (sendToEmailOptionsArr[i].value == filterData.data[0].queryField) {
                        isFieldAlreadyExist = true;
                        break;
                    }
                }
                if (!isFieldAlreadyExist) {
                    sendToEmailOptionsArr.push({
                        'label': filterData.data[0].queryFieldTooltip,
                        'value': filterData.data[0].queryField
                    });
                }
                sendToEmailOptionsArr.push({
                    'label': hlpr.config.selectAll.label,
                    'value': hlpr.config.selectAll.text
                });
                cmp.set("v.sendToEmailOptions", sendToEmailOptionsArr);
                fVal = filterData.data[0].queryField;
                cmp.set("v.scheduleObj.Email_To_Address", fVal);
            } else {
                let sendSMSToOptionsArr = cmp.get("v.sendSMSToOptions");
                sendSMSToOptionsArr.pop();
                let isFieldAlreadyExist = false;
                for (let i = 0; i < sendSMSToOptionsArr.length; i++) {
                    if (sendSMSToOptionsArr[i].value == filterData.data[0].queryField) {
                        isFieldAlreadyExist = true;
                        break;
                    }
                }
                if (!isFieldAlreadyExist) {
                    sendSMSToOptionsArr.push({
                        'label': filterData.data[0].queryFieldTooltip,
                        'value': filterData.data[0].queryField
                    });
                }
                sendSMSToOptionsArr.push({
                    'label': hlpr.config.selectAll.label,
                    'value': hlpr.config.selectAll.text
                });
                cmp.set("v.sendSMSToOptions", sendSMSToOptionsArr);
                fVal = filterData.data[0].queryField;
                cmp.set("v.scheduleObj.SMS_To_Number", fVal);
                if (scheduleObj.SObject_RecordId && fVal === 'conference360__Attendee__r.conference360__Phone__c') {
                    fVal = '';
                }
            }
        }
        if (filterData && filterData.closeFieldSelection == false) {
            let scheduleObj = cmp.get("v.scheduleObj");
            if (scheduleObj.Action == 'Email' && scheduleObj.Email_To_Address == hlpr.config.selectAll.text) {
                let sendToEmailOptions = cmp.get("v.sendToEmailOptions");
                if (sendToEmailOptions && sendToEmailOptions.length > 0) {
                    fVal = sendToEmailOptions[0].value;
                }
                if (fVal == hlpr.config.selectAll.text) {
                    fVal = '';
                }
                cmp.set("v.scheduleObj.Email_To_Address", fVal);
            } else if (scheduleObj.Action == 'SMS' && scheduleObj.SMS_To_Number == hlpr.config.selectAll.text) {
                let sendSMSToOptions = cmp.get("v.sendSMSToOptions");
                if (sendSMSToOptions && sendSMSToOptions.length > 0) {
                    fVal = sendSMSToOptions[0].value;
                }
                if (fVal == hlpr.config.selectAll.text) {
                    fVal = '';
                }
                cmp.set("v.scheduleObj.SMS_To_Number", fVal);
                if (scheduleObj.SObject_RecordId && fVal === 'conference360__Attendee__r.conference360__Phone__c') {
                    fVal = '';
                }
            }
            cmp.set("v.allowFieldSelection", false);
        }
        cmp.set("v.scheduleObj.AssociateWithReferencedRecordOptions", AssociateWithReferencedRecordOptionsArr);
        cmp.set("v.scheduleObj.Associate_With_Referenced_Record", 'true');
        hlpr._prepareReferenceOptions(cmp, hlpr, fVal);
    },
    jsFromEmailAddressChange: function (cmp, evt, hlpr) {
        cmp.set("v.spinner", 'message-loading');
        hlpr.serverConnect(cmp, hlpr, 'checkOrgWideEmailAddress', {
            emailAddress: cmp.get("v.scheduleObj.Email_From_Address"),
            userId: cmp.get("v.account.authenticatedUser.salesforceId")
        }, hlpr._FromEmailAddressValidate);
    },
    _FromEmailAddressValidate: function (cmp, hlpr, response, cbInfo) {
        let result = response.getReturnValue();
        cmp.set("v.scheduleObj.isEmailVerified", result);
        cmp.set("v.spinner", '');
    },
    jsAssociateReferenceChange: function (cmp, evt, hlpr) {
        let sendTestCmp = cmp.find("sendTest");
        if (sendTestCmp && Array.isArray(sendTestCmp)) {
            sendTestCmp[0].resetInit();
        } else if (sendTestCmp) {
            sendTestCmp.resetInit();
        }
    },
    _prepareReferenceOptions: function (cmp, hlpr, val) {
        let scheduleObj = cmp.get("v.scheduleObj");
        val = (val + '');
        if (val.length > 0 && val.indexOf(".") > -1) {
            let refObjectName = scheduleObj.Related_Object ? scheduleObj.Related_Object : scheduleObj.Base_Object;
            hlpr.fetchAssociateReference(cmp, hlpr, refObjectName, val.substring(0, (val + '').lastIndexOf(".")));
        } else {
            cmp.set("v.scheduleObj.Associate_With_Referenced_Record", 'false');
        }
    },
})