({
    smsKey: 'bt_smspanel',
    jsInitMessenger: function (cmp, evt, hlpr) {
        var penal = cmp.find('smspenal');
        penal.set('v.body', []);
        var body = penal.get('v.body');
        let scheduleObj = cmp.get("v.scheduleObj");
        let sObjectName = scheduleObj.Related_Object ? scheduleObj.Related_Object : scheduleObj.Base_Object;
        if(scheduleObj.Associate_With_Referenced_Record && scheduleObj.AssociateWithReferencedRecordOptions && !$A.util.isUndefinedOrNull(scheduleObj.Associate_With_Referenced_Record) && !$A.util.isEmpty(scheduleObj.Associate_With_Referenced_Record)){
            for(let i=0; i<scheduleObj.AssociateWithReferencedRecordOptions.length; i++){
                if(scheduleObj.AssociateWithReferencedRecordOptions[i].value == scheduleObj.Associate_With_Referenced_Record){
                    if(scheduleObj.AssociateWithReferencedRecordOptions[i].label.indexOf('.') != -1){
                        sObjectName = (scheduleObj.AssociateWithReferencedRecordOptions[i].label.split('.')).pop();
                    }
                }
            }
        }
        if (sObjectName) {
            if (scheduleObj.SMS_From_Number) {
                $A.createComponent(
                    cmp.get("v.smsCmpName"), {
                        sObjectName: sObjectName,
                        fromNum: scheduleObj.SMS_From_Number,
                        newMessage: true,
                        allowNumberSelection: false,
                        allowSend: false,
                        smsMessageBody: scheduleObj.SMS_Message,
                        smsTemplateIdCode: scheduleObj.SMS_Template_Id,
                        smsAttachmentId: scheduleObj.SMS_Attachment_Id,
                        recordId: '',
                        'aura:id': hlpr.smsKey
                    },
                    function (newCmp, status, errorMessage) {
                        if (status === 'SUCCESS') {
                            body.push(newCmp);
                            penal.set('v.body', body);
                            cmp.set("v.messengerLoaded", true);
                        } else if (status === 'INCOMPLETE') {
                            console.log('No response from server or client is offline.');
                        } else if (status === 'ERROR') {
                            console.log('Error: ' + errorMessage);
                        }
                    }
                );
            }
        }
    },
    jsPrevious: function (cmp, evt, hlpr) {
        let sms = cmp.find(hlpr.smsKey);
        let validateData = sms.checkValidity();
        if (validateData.validity) {
            cmp.set("v.selectedActiveSectionName", "Schedule");
            cmp.set("v.scheduleObj.SMS_Message", validateData.data.message);
            cmp.set("v.scheduleObj.SMS_Template_Id", validateData.data.templateId);
            cmp.set("v.scheduleObj.SMS_Attachment_Id", validateData.data.attachmentId);
        } else {
            if (validateData.message.indexOf('SMS Message is not linked') != -1) {
                cmp.set("v.selectedActiveSectionName", "Schedule");
                cmp.set("v.scheduleObj.SMS_Message", "");
                cmp.set("v.scheduleObj.SMS_Template_Id", "");
                cmp.set("v.scheduleObj.SMS_Attachment_Id", "");
            } else {
                hlpr.__triggerToast(cmp, {
                    message: validateData.message,
                    type: 'error'
                });
            }
        }
    },
    jsNext: function (cmp, evt, hlpr) {
        let sms = cmp.find(hlpr.smsKey);
        let validateData = sms.checkValidity();
        if (validateData.validity) {
            cmp.set("v.currentStep", 4);
            cmp.set("v.selectedActiveSectionName", "Preview");
            cmp.set("v.scheduleObj.SMS_Message", validateData.data.message);
            cmp.set("v.scheduleObj.SMS_Template_Id", validateData.data.templateId);
            cmp.set("v.scheduleObj.SMS_Attachment_Id", validateData.data.attachmentId);
        } else {
            hlpr.__triggerToast(cmp, {
                message: validateData.message,
                type: 'error'
            });
        }
    },
    validatedFormJS: function (cmp, hlpr) {
        let isValid = false;
        let sms = cmp.find(hlpr.smsKey);
        let validateData = sms.checkValidity();
        if (validateData.validity) {
            cmp.set("v.scheduleObj.SMS_Message", validateData.data.message);
            cmp.set("v.scheduleObj.SMS_Template_Id", validateData.data.templateId);
            cmp.set("v.scheduleObj.SMS_Attachment_Id", validateData.data.attachmentId);
            isValid = true;
        }

        if(validateData.message && validateData.message.indexOf('SMS Message is not linked') != -1){
			isValid = true;            
        }else if (cmp.get('v.messengerLoaded') && !isValid) {
            hlpr.__triggerToast(cmp, {
                message: validateData.message,
                type: 'error'
            });
        }

        return isValid;
    },
    validatedSectionToggleFormJS: function (cmp, hlpr) {
        let isValid = false;
        let sms = cmp.find(hlpr.smsKey);
        let validateData = sms.checkValidity();
        if (validateData.validity) {
            cmp.set("v.scheduleObj.SMS_Message", validateData.data.message);
            cmp.set("v.scheduleObj.SMS_Template_Id", validateData.data.templateId);
            cmp.set("v.scheduleObj.SMS_Attachment_Id", validateData.data.attachmentId);
            isValid = true;
        }
        if (!cmp.get('v.messengerLoaded')) {
            isValid = true;
        }
        if(validateData.message && validateData.message.indexOf('SMS Message is not linked') != -1){
			isValid = true;            
        }else if (!isValid) {
            hlpr.__triggerToast(cmp, {
                message: validateData.message,
                type: 'error'
            });
        }
        return isValid;
    }
})