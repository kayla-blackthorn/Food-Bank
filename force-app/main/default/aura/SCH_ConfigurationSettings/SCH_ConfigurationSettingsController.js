({
    doInit: function (component, event, helper) {
        helper.jsDoInit(component, helper);
    },

    handleChange: function (component, event, helper) {
        let account = {
            'attach_log_records_in_email': component.find('attchlog').get('v.checked')
        };
        helper.updateAccounthelper(component, account);
    },

    handleRadioSelect: function (component, event, helper) {
        let selectedOption = component.get('v.selectedOption');
        let account = {
            'create_execution_records_in_org': !$A.util.isEmpty(selectedOption) ? true : false,
            'create_log_records_in_org_as': selectedOption,
            'attach_log_records_in_email': component.find('attchlog').get('v.checked')
        };
        helper.updateAccounthelper(component, account);
    }
})