import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import apex_getData from '@salesforce/apex/SObjectLookupCtlr.getData';

export default class Lookup extends LightningElement {
    // The name for the lookup. This value is optional and can be used to identify the lookup in a callback of change.
    @api name;
    
    // Define SObject API name, also include namespace if the sobject is part of any manage package.
    @api sobjectApiName;
    
    // Define that help text to be displayed along with label
    @api helptext = '';
    
    // Define SObject label that you want to be display for selection
    @api label;
    
    // To hide label, specify label-hidden. Default is standard" 
    @api variant = 'standard';
    
    // Define icon, to be display along with lookup result.
    @api iconName = '';
    
    // Text that is displayed when the input is empty, to prompt the user for a valid entry.
    @api placeholder;
    
    // Text that is displayed when the no record found with search.
    @api noresultinfotext;
    
    // Define static filters that can be collaborate with SOQL.
    @api filter;
    
    // Provide record id for default selection or get selected record's Id. For Multi Selection specify comma separated value 
    @api value;
    
    // Define Field API name to override to display field value in the place of named field.
    @api
    get resultPrimaryField(){
        return this._resultPrimaryField;
    }
    set resultPrimaryField(data){
        this._resultPrimaryField = data;
    }
    
    // Define Field API names to be shown data underneath of primary field 
    @api resultSecondaryField;
    
    // Define Field API name to override to apply filter on the field in the place of named field.
    @api searchByField;
    
    // Define Field API name to override to Id field value in the place of Id field.
    @api fieldSearchId;
    
    // Define Additional Field(s) API name to query those fields as well.
    @api additionalFields;
    
    // Define that lookup must be searched out before submitting the form. Default is false.
    @api required;
    
    // 
    @api isreadonly = false;
    
    // Select a number to enable search when desired minimum characters are entered. Default is 3.
    @api searchMinLength = 2;
    
    // Define milliseconds as delay for searching. Default is 500 milliseconds(0.5 second).
    @api searchDelayInSeconds = 1;
    
    //  Define TRUE to indicate that data should be auto loaded initally in the backgroud. Default is false.
    @api autoload = false;

    //  Define TRUE to display create new option with option.
    @api enableCreateNew = false;
    
    /**
     * functions for public usage
     */
    @api 
    focus(){
        this._inputFocus();
    }
    
    @api
    checkValidity(){
        var self = this;
        return self.isRecordSelected;
    }
    
    @api
    reportValidity(){
        var self = this;
        let validate = self.isRecordSelected;
        if(self.required){
            self.hasError = !validate;
        }
        return validate;
    }
    
    @api
    resetSelection(data){
        var self = this;
        if(!data){
            data = {};
        }
        
        if(data.recordId){
            // self._userInputReadonly(true);
            let params = self._prepareParams()
            params.isInclude = true;
            params.recordIds = [data.recordId];
            params.resetSelection = true;
            // params.isLoadDefault = true;
            self.isLoadDefault = true;
            self.getData(params);
        }else{
            if(self.record && self.record.isSelected){
                self.records[self.record.selectedIndex].isSelected = false;
                self._maintainRecordClass(self.records[self.record.selectedIndex]);
                self.isRecordSelected = false;
                self._onChange();
                if(self.required){
                    self.reportValidity()
                }
            }
        }
    }
    
    @api
    validate(){
        let self = this;
        let reportValidity = self.reportValidity();
        let result = {
            isValid: reportValidity
        }
        if(self.hasError){
            result.errorMessage = 'Complete this field.';
        }
        return result;
    }
    /**
     * Internal usage
     */
    debug_mode = false;
    log_details(){
        if(this.debug_mode){
            var params = [];
            for(let ind=0, len = arguments.length; ind<len; ind++){
                params[ind] = arguments[ind];
            }
            console.log(params);
        }
    }
    @track
    data = {
        createNewLabel: 'Create New',
        createNewKey: 'create-new',
        createNewIcon: 'utility:add',
    };
    
    hasError = false;
    initialSearched = false;
    displaySubDetails = false;
    actionName = '';
    actionCount = 0;
    
    searchedKey = '';
    sobjData = {};
    tempData = {};
    records = [];
    noRecordFound = false;
    noRecordFoundInfo = '';
    
    isRecordSelected = false;
    
    record = {};
    
    apex_getData = false;
    isLoadDefault = false;
    resetData = {};
    doHide = false;
    
    /** Start of lwc dynamic properties */
    get cPlaceholder(){
        return (this.placeholder ? this.placeholder : 'Search'+ (this.objLabel ? ' '+this.objLabel : '') +'...');
    }
    
    get loadingData(){
        return this.apex_getData;
    }
    
    get cRecordNotFound(){
        return this.actionName ? false : this.noRecordFound;
    }
    
    _objLabel = '';
    get objLabel(){
        if(!this._objLabel){
            if(this.sobjData.label){
                this._objLabel = this.sobjData.label;
            }else if(this.sobjectApiName){
                return this.sobjectApiName;
            }else{
                return 'Record';
            }
        }
        return this._objLabel;
    }
    get showHelptext(){
        if(this.helptext !== ''){
            if((this.helptext+'').length > 0){
                return true;
            }
        }
        return false;
    }
    get cRecordNotFoundInfo(){
        return 'Nothing to display.';
        //  this.noresultinfotext ? this.noresultinfotext : (this.objLabel ? this.objLabel : 'result') + ' not found';
    }
    
    get showLabel(){
        return this.variant == 'label-hidden' ? false : this.label != undefined;
    }
    get lookupClass(){
        var self = this;
        let lookupClass = 'slds-form-element ';
        if(self.variant == 'label-inline'){
            lookupClass += 'slds-form-element_horizontal ';
        }
        if(self.isreadonly){
            if(self.loadingData){
                lookupClass+='slds-p-bottom_small ';
            }else{
                lookupClass+='slds-p-bottom_x-small ';
            }
            lookupClass+= 'slds-form-element_readonly ';
        }
        
        return lookupClass;
    }
    get comboboxClass(){
        return (this.hasError ? 'slds-has-error' : '' )+ ' slds-combobox_container '
                + (this.isRecordSelected ? ' slds-has-selection' :'');
    }
    get recordSelectedClass(){
        return "slds-combobox__form-element slds-input-has-icon slds-input-has-icon_"+(this.showIcon ? "left-" : "")+"right";
    }
    get visibleSearchIcon(){
        return this.isreadonly ? false : !this.loadingData;
    }
    get allowSearch(){
        return this.isreadonly || this.isLoadDefault ? false : true;
    }
    
    get showIcon(){
        return this.iconName && typeof this.iconName == 'string' ? true : false; 
    }
    @track
    comboboxClasses = ['slds-combobox','slds-dropdown-trigger','slds-dropdown-trigger_click'];
    get lookupComboboxClass(){
        return this.comboboxClasses.join(' ');
    }
    tempData = {};
    /** End of lwc dynamic properties */
    
    /** Starts of element functions */
    lookupCombobox() {
        var self = this;
        return self.template.querySelector('div[data-key="lookupcombobox"]');
    }
    _show(){
        var self = this;
        if(self.tempData.filter != self.filter){
            self.initialSearched = false;
            self.records = [];
            self.tempData.filter = self.filter;
            let val = self._getUserInput();
            if(val){
                self.doSearch();
            }
        }
        if(self.initialSearched){
            if(self.comboboxClasses.indexOf('slds-is-open') == -1){
                self.comboboxClasses.push('slds-is-open');
                self.doHide = true;
            }
            /* let lookupCombobox = self.lookupCombobox();
            if(lookupCombobox){
            } */
        }
    }
    _hide(){
        var self = this;
        let lookupCombobox = self.lookupCombobox();
        if(lookupCombobox){
            let clsIndex = self.comboboxClasses.indexOf('slds-is-open');
            if(clsIndex > -1){
                self.doHide = false;
                self.comboboxClasses.splice(clsIndex, 1);
            }
        }
    }
    searchInput(){
        var self = this;
        return self.template.querySelector('input[data-key="lookup-search"]')
    }
    _getUserInput(){
        var self = this;
        let val = '';
        let searchInput = self.searchInput();
        if(searchInput){
            val = searchInput.value;
        }
        return val;
    }
    _resetUserInput(){
        var self = this;
        let searchInput = self.searchInput();
        if(searchInput){
            searchInput.value = '';
        }
    }
    _inputFocus(){
        var self = this;
        self.doHide = true;
        window.setTimeout(function(){
            let searchInput = self.searchInput();
            if(searchInput){
                searchInput.focus();
            }
        },500);
    }
    /* 
    _userInputReadonly(readonly){
        var self = this;
        let searchInput = self.searchInput();
        if(searchInput){
            searchInput.readonly = readonly;
        }
    }
     */
    /** End of element functions */
    
    

    showNotification(toast) {
        const evt = new ShowToastEvent(toast);
        this.dispatchEvent(evt);
    }
    
    /** */
    _setDefaultConfigurations(){
        var self = this;
        /* set any default iconName here
        if(!self.iconName){
            self.iconName = 'utility:record';
        }
         */
        if(!self.variant){
            self.variant = 'standard';
        }
        
        if(!self.searchMinLength){
            self.searchMinLength = 2
        }
        let delay = Number(parseFloat(self.searchDelayInSeconds));
        if(!self.searchDelayInSeconds || isNaN(delay)){
            self.searchDelayInSeconds = 1;
        }
    }
    
    _loadDefault(){
        var self = this;
        let params = self._prepareParams()
        if(self.value){
            
            params.isInclude = true;
            if(!self.resetData.reloadDefault){
                params.recordIds = [self.value];
            }
            
            self.isLoadDefault = true;
            self.getData(params);
        }else if(self.autoload){
            self.isLoadDefault = true;
            self.getData(params);
        }
    }
    
    connectedCallback(){
        var self = this;
        self._setDefaultConfigurations();
        self._loadDefault();
    }
    
    handleFocusLost(){
        var self = this;
        window.setTimeout(function(){
            if(self.doHide == true){
                self._hide();
            }
        },150);
    }
    handleBlur(){
        
    }
    handleClick(){
        this._show();
    }
    handleFocus(){
        this._show();
    }
    
    handleKeyUp(evt){
        var self = this;
        self.searchedKey = evt.currentTarget.value;
        self.doSearch();
    }
    
    handleKeyDown(evt){
        switch (evt.key){
            case 'ArrowUp':
            case 'ArrowDown':
                evt.stopPropagation();
                break;
                
            case 'Enter':
                evt.stopPropagation();
                break;
            default:
                break;
                
        }
    }
    handlePanel(){
        var self = this;
        self.doHide = self.cRecordNotFound;
    }
    handleSelection(evt){
        var self = this;
        let selectedIndex = evt.currentTarget.dataset.index;
        if(selectedIndex == self.data.createNewKey){
            let params = { 'config': self._prepareConfig()};
            let createNewmEvent = new CustomEvent('createnew', {
                detail: params
            });
            self.dispatchEvent(createNewmEvent);
            self._hide();
        }else{
            let record = self.records[selectedIndex];
            if(!record.isSelected){
                record.isSelected = true;
                record.selectedIndex = selectedIndex;
                self.record = record;
                self.isRecordSelected = true;
            }
            self._hide();
            self.hasError = false;
            self._maintainRecordClass(record);
            self._onChange();
        }
    }
    _prepareConfig(){
        var self = this;
        return {
            name: self.name,
            sobjectApiName: self.sobjectApiName,
            label: self.label,
            variant: self.variant,
            iconName: self.iconName,
            required: self.required,
            searchMinLength: self.searchMinLength,
            searchDelayInSeconds: self.searchDelayInSeconds,
            filter: self.filter,
            searchByField: self.searchByField,
            resultPrimaryField: self.resultPrimaryField ? self.resultPrimaryField : (self.sobjData && self.sobjData.nameField ? self.sobjData.nameField : ''),
            resultSecondaryField: self.resultSecondaryField
        }
    }
    _onChange(){
        var self = this;
        let params = {
            name: self.name,
            record: {},
        };
        let excludedFields = ['className', 'id', 'isHide', 'isSelected', 'name', 'search', 'selectedIndex', 'subDetails'];
        self.value = null;
        let idKey = 'Id';
        if (self.sobjData.Id) {
            idKey = self.sobjData.Id;
        }
        if (self.isRecordSelected) {
            params.record = JSON.parse(JSON.stringify(self.record));
            for (let field in params.record) {
                if (excludedFields.indexOf(field) > -1) {
                    delete params.record[field];
                }
            }
            self.value = params.record[idKey];
        }
        params.nameField = self.sobjData.nameField;

        params.config = self._prepareConfig();

        let recordsFoundEvent = new CustomEvent('change', {
            detail: params
        });
        self.dispatchEvent(recordsFoundEvent);
    }
    handleSelectionRemove(evt){
        var self = this;
        let record = self.records[self.record.selectedIndex];
        record.isSelected = false;
        self.isRecordSelected = false;
        self._inputFocus();
        if(self.resetData && self.resetData.reloadDefault){
            self._loadDefault();
            self.resetData.reloadDefault = false;
        }
        if(record){
            self._maintainRecordClass(record);
            self.noRecordFound = false;
        }
        if(self.required){
            self.reportValidity();
        }
        self._onChange();
    }
    _prepareParams() {
        var self = this;
        let params = {};
        params.objectName = self.sobjectApiName;
        params.value = self.searchedKey;
        params.fields = {};
        if (!self.sobjData.fields) {
            self.sobjData.fields = {};
        }

        if (self.resultPrimaryField) {
            params.fields.name = self.resultPrimaryField;
        }
        // if (params.objectName == 'OpportunityContactRole') {
        //     if (!params.fields.name) {
        //         params.fields.name = 'ContactId'
        //     }
        // }
        if (self.resultSecondaryField) {
            params.fields.additionalDisplayFields = self.resultSecondaryField;
        }
        if (self.searchByField) {
            params.fields.search = self.searchByField;
        }
        if (self.fieldSearchId) {
            params.fields.Id = self.fieldSearchId;
        }

        if (self.additionalFields) {
            params.additionalFields = self.additionalFields;
        }
        if (self.filter) {
            params.filter = self.filter;
        }
        return params;
    }
    doSearch(){
        var self = this;
        try{
            self._prepareNoRecordFound(self.searchedKey);
            if(!self.searchMinLength){
                self.searchMinLength = 3;
            }
            // validating minimum characters for searching...
            if(self.searchedKey.length < self.searchMinLength){
                return;
            }
            let params = self._prepareParams();
            if(self.tempData['timeOut']){
                clearTimeout(self.tempData['timeOut']);
            }
            // doing call with specified delay
            self.tempData['timeOut'] = setTimeout(() => {
                self.getData(params);
            }, self.searchDelayInSeconds * 1000);
        }catch(e){
            console.log('Lookup -> doSearch ',e);
            self._handleErrors(e);
        }
    }
    
    getData(params){
        var self = this;
        let actionName = 'apex_getData';
        
        if(self.tempData[actionName] === true){
            self.resetData.isResetSelection = params.resetSelection;
            self.resetData.recordIds = params.recordIds;
            self.resetData.isInclude = params.isInclude;
            self.tempData[actionName+'callagin'] = true;
            return;
        }
        self.apex_getData = true;
        self.tempData[actionName] = true;
        
        self.tempData.filter = self.filter;
        // if(self.initialSearched == false && !params.isLoadDefault){
        if(self.initialSearched == false && !self.isLoadDefault){
            self.initialSearched = true;
            self._show();
        }
        
        self.log_details('params', JSON.parse(JSON.stringify(params)));
        let resetSelection = params.resetSelection;
        apex_getData({
            objectName: params.objectName,
            fields: params.fields,
            value: params.value,
            filter: params.filter,
            additionalFields: params.additionalFields,
            recordIds: params.recordIds,
            isInclude: params.isInclude
        })
        .then(result => {
            if(self.enableCreateNew){
                self.data.isCreateable = result.isCreateable;
            }
            self.tempData[actionName] = false;
            self.apex_getData = false;
            
            if(self.tempData[actionName+'callagin']){
                self.tempData[actionName+'callagin'] = false;
                params.value = self.searchedKey;
                
                self.resetData.reloadDefault = params.filter != self.filter;
                params.filter = self.filter;
                
                if(params.resetSelection !== self.resetData.isResetSelection){
                    params.resetSelection = self.resetData.isResetSelection;
                    params.recordIds = self.resetData.recordIds;
                }
                if(params.isInclude !== self.resetData.isInclude){
                    params.isInclude = self.resetData.isInclude;
                }
                self.getData(params);
            }
            self.records = self._prepareRecords(result, self.isLoadDefault);
            
            if(self.isLoadDefault || resetSelection){
                self.initialSearched = true;
                params.recordIds = params.recordIds ? params.recordIds : [];
                self._selectDefault(params.recordIds);
                if(self.required && params.recordIds.length > 0){
                    self.reportValidity();
                }else{
                    self.autoload = false;
                }
            }else{
                let val = self._getUserInput();
                self._prepareNoRecordFound(val);
            }
            self.isLoadDefault = false;
            
        })
        .catch(error => {
            console.log('Lookup -> getData ',error);
            self.isLoadDefault = false;
            self._handleErrors(error);
            
            self.tempData[actionName] = false;
            self.apex_getData = false;
            if(self.tempData[actionName+'callagin']){
                self.tempData[actionName+'callagin'] = false;
            }
        });
    }
    _prepareNoRecordFound(val){
        val = val.toLowerCase();
        var self = this;
        self.noRecordFound = true;
        if(!self.records){
            self.records = [];
        }
        self.records.forEach(function(rec){
            rec.isHide = rec.name && rec.name.toLowerCase().indexOf(val)==-1 && rec.search.toLowerCase().indexOf(val)==-1;
            self._maintainRecordClass(rec);
            if(!rec.isHide && !rec.isSelected){
                self.noRecordFound = false;
            }
        })
    }
    _maintainRecordClass(record){
        record.className='slds-listbox__item';
        if(record.isHide || record.isSelected){
            record.className+= ' slds-hide';
        }
    }
    _selectDefault(recordIds){
        var self = this;
        let index = 0;
        self.records.forEach(function(record){
            record.isSelected = recordIds.indexOf(record.id)>-1;
            if(record.isSelected){
                record.selectedIndex = index;
                self.record = record;
                self.isRecordSelected = true;
            }
            index++;
        })
        self._prepareNoRecordFound('');
        self._onChange();
    }
    _prepareRecords(data, isSelected, val) {
        var self = this;
        let recMap = {};
        let idKey = 'Id';
        if (data.fieldId) {
            idKey = data.fieldId;
        }
        let records = self.records;
        for (let key in records) {
            recMap[records[key][idKey]] = records[key];
        }

        let newRecs = data.records;
        self.sobjData.label = data.label;
        self.sobjData.idKey = idKey;
        self.sobjData.nameField = data.fieldName;
        self.sobjData.searchField = data.fieldName;
        self.sobjData.additionalDisplayFields = data.additionalDisplayFields;

        if (!self.sobjData.additionalDisplayFields) {
            self.sobjData.additionalDisplayFields = [];
        }
        self.displaySubDetails = self.sobjData.additionalDisplayFields.length > 0;

        if (data.fieldName && data.fieldSearch && data.fieldName !== data.fieldSearch) {
            self.sobjData.nameField = data.fieldName;
            self.sobjData.searchField = data.fieldSearch;
        }
        records = [];
        try {
            if (newRecs) {
                for (let key in newRecs) {
                    let recId = newRecs[key][idKey];
                    let record = self._extractRecord(newRecs[key]);
                    if (recMap[recId]) {
                        recMap[recId].isHide = false;
                    } else {
                        let nameKey = self.sobjData.nameField;
                        if (nameKey.indexOf('.') > -1) {
                            let fieldKeys = nameKey.split('.');
                            record.name = record[fieldKeys[0]][fieldKeys[1]];
                        } else if (data.fieldsRefrences[nameKey]) {
                            record.name = record[data.fieldsRefrences[nameKey]['relationshipName']][data.fieldsRefrences[nameKey]['name']];
                        } else {
                            record.name = record[nameKey];
                        }
                        record.search = record.name;
                        if (self.sobjData.searchField != self.sobjData.nameField) {
                            if (self.sobjData.searchField.indexOf('.') > -1) {
                                let fieldKeys = self.sobjData.searchField.split('.');
                                record.search = record[fieldKeys[0]][fieldKeys[1]];
                            } else if (data.fieldsRefrences[searchField]) {
                                record.name = record[data.fieldsRefrences[searchField]['relationshipName']][data.fieldsRefrences[searchField]['name']];
                            } else {
                                record.search = record[self.sobjData.searchField];
                            }
                        }
                        record.id = record[idKey];

                        if (!record.isSelected) {
                            record.isSelected = false;
                        }
                        if (isSelected !== undefined && isSelected !== '') {
                            record.isSelected = isSelected;
                        }
                        recMap[recId] = record;
                    }

                    record.subDetails = '';
                    if (self.displaySubDetails) {
                        let op = '';
                        self.sobjData.additionalDisplayFields.forEach(function (field) {
                            if (record[field] !== undefined) {
                                if (data.fieldsRefrences[field] && data.fieldsRefrences[field]['relationshipName']) {
                                    record.subDetails += op + record[data.fieldsRefrences[field]['relationshipName']][data.fieldsRefrences[field]['name']];
                                    op = ' • ';
                                } else {
                                    record.subDetails += op + record[field];
                                    op = ' • ';
                                }
                            }
                        })
                    }
                    recMap[recId].subDetails = record.subDetails;
                }
                records = Object.values(recMap);
            }
        } catch (e) {
            self.log_details(e);
            self._handleErrors(e);
        }
        // records = Object.values(recMap);

        records.sort(function (a, b) {
            let fname = a['name'] == undefined || a['name'] == null ? '' : (a['name'] + '');
            let sname = b['name'] == undefined || b['name'] == null ? '' : (b['name'] + '');
            return fname.localeCompare(sname);
        })

        return records;
    }
    _extractRecord(record){
        let tempRecord = {};
        for(let key in record){
            tempRecord[key] = record[key];
        }
        return tempRecord;
    }
    
    _handleErrors(errors) {
        var self = this;
        // Configure error toast
        let toastParams = {
            title: "Error",
            // Default error message
            message: "Unknown error",
            variant: "error"
        };
        // Pass the error message if any
        if (errors && !Array.isArray(errors)) {
            errors = [errors];
        }
        var errorMsg = '';
        if (errors && errors.length > 0) {
            if (errors[0]) {
                if(typeof errors == 'object'){
                    let error = errors[0];
                    if(error.body){
                        error = error.body;
                    }
                    if (error.pageErrors && error.pageErrors.length > 0) {
                        errorMsg = error.pageErrors[0].message;
                    } else if (error.fieldErrors) {
                        let fieldWithErrors = {}
                        errorMsg = self._extractFieldsErrorMsg(error.fieldErrors, fieldWithErrors);
                    } else if (error.message) {
                        errorMsg = error.message
                    }
                }else{
                    errorMsg = errors[0];
                }
            }
        }
        toastParams.message = errorMsg;
        if (toastParams.message) {
            self.showNotification(toastParams);
        }
    }
    // Extracting fields Error Message
    _extractFieldsErrorMsg(fieldErrors, fieldWithErrors) {
        var keys = Object.keys(fieldErrors);
        var msg = 'Unknown error';
        if (keys.length > 0) {
            msg = '';
            for (var keyInd in keys) {
                let key = keys[keyInd];
                var fErrors = fieldErrors[key];
                fErrors.forEach(function (fErr) {
                    let errorField = key;
                    if (fErr.columnApiName) {
                        errorField = fErr.columnApiName;
                    }
                    if (!fieldWithErrors[errorField]) {
                        fieldWithErrors[errorField] = '';
                    }
                    fieldWithErrors[errorField] += (fieldWithErrors[errorField] != '' ? '\n' : '') + fErr.message;
                    msg += fErr.message + ' \n';
                })
            }
        }
        return msg;
    }
}