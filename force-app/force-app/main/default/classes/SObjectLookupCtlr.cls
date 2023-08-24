/**
 * @name : SObjectLookupCtlr
 * @description containing methods to handle sObjectLookup component
 * 
 * @test SObjectLookupCtlrTest
 * @date 2021-June-01
 * @author : Dharmendra Karamchandani
 */
public with sharing class SObjectLookupCtlr {

    public final static Map<String, Schema.SObjectType> GLOBAL_SOBJECT_TYPE {
        get {
            if (GLOBAL_SOBJECT_TYPE == null) {
                GLOBAL_SOBJECT_TYPE = Schema.getGlobalDescribe();
            }
            return GLOBAL_SOBJECT_TYPE;
        }
        set;
    }
    static Map<String, Map<String, SobjectField>> sobjectWithFieldMap {
        get {
            if (sobjectWithFieldMap == null) {
                sobjectWithFieldMap = new Map<String, Map<String, SobjectField>>();
            }
            return sobjectWithFieldMap;
        }
        set;
    }

    static Map<String, DescribeFieldResult> validateField(String fKey, String fieldName, Map<String, SobjectField> sFieldMap) {
        Map<String, DescribeFieldResult> data = new Map<String, DescribeFieldResult>();
        // System.debug(fKey);
        // System.debug(fieldName);
        List<String> parts = fieldName.split('\\.');
        // System.debug(parts);
        if(parts.size() > 1){
            fieldName = parts.remove(0);
            // System.debug(fieldName);
            if(fieldName.endsWithIgnoreCase('__r')){
                fieldName = fieldName.substring(0, fieldName.length()-3)+'__c';
            } else {
                fieldName += 'Id';
            }
            // System.debug(parts);
            // System.debug(fieldName);
        }
        if(sFieldMap.containsKey(fieldName)){
            DescribeFieldResult dfr = sFieldMap.get(fieldName).getDescribe();
            if (dfr.isAccessible()) {
                data.put(fKey, dfr);
            }
        } else {
            /*
             List<String> parts = fieldName.split('\\.');
            System.debug(parts);
            if(parts.size() > 1){
                String fName = parts.remove(0);
                System.debug(fName);
                if(fName.endsWithIgnoreCase('__r')){
                    fName = fName.substring(0,fName.length()-3)+'__c';
                } else {
                    fName+='Id';
                }
                System.debug(parts);
                System.debug(fName);
                validateField(fKey, fName, sFieldMap);
            }
			*/
        }
        return data;
    }
    /*******************************************************************************************************
     * @description Method used to get sObject records
     * @return Map<String, Object>
     * @param objectName: sObject API Name
     * @param fields: List of sObject fields
     * @param value: used to filter records
     * @param filter: collection of filters
     * @param additionalFields: collection of related fields
     * @param recordIds: collection of record Id's
     * @param isInclude: used to include filters
     **/
    @AuraEnabled
    public static Map<String, Object> getData(String objectName, Map<String, String> fields, String value, String filter, String additionalFields,
        List<String> recordIds, Boolean isInclude) {
        // Security Review fixes
        objectName = SCH_BtBaseUtils.secureIdInjection(objectName);
        Map<String, Object> result = new Map<String, Object>();
        String dataStr = '{}';

        result.put('status', false);
        Map<String, String> dataMap = (Map<String, String>) JSON.deserialize(dataStr, Map<String, String> .class);
        String objName = objectName;

        if (String.isNotBlank(objName)) {
            SObjectType sObjectType = GLOBAL_SOBJECT_TYPE.get(objName);

            if (sObjectType != null) {
                DescribeSObjectResult dsr = sObjectType.getDescribe();
                if (dsr != null) {
                    result.put('label', dsr.getLabel());
                    Map<String, SobjectField> fMap = dsr.fields.getMap();
                    filter = filter == null ? '' : filter;

                    String nameField = '';
                    String idField = 'Id';
                    String searchField = '';
                    String fieldCSV = '';
                    String fieldOp = '';
                    String additionalDisplayField = '';
                    Set<String> additionalDisplayFields = new Set<String>();
                    Set<String> fieldsToQuery = new Set<String>();
                    Map<String, Object> fieldsRefrences = new Map<String, Object>();
                    Map<String, SobjectField> sFieldMap = getSobjectFieldsMap(dsr.getName());
                    String nameFieldType = 'string';

                    if (fields != null && fields.size() > 0) {
                        additionalDisplayField = fields.remove('additionalDisplayFields');
                        for (String fKey: fields.keySet()) {
                            String fieldVal = fields.get(fKey);
                            fieldVal = fieldVal.trim().toLowerCase();
                            System.debug(fKey + fieldVal);
                            Map<String, DescribeFieldResult> data = validateField(fKey, fieldVal, sFieldMap);
                            String lKey = fKey.toLowerCase();
                            if(data.containsKey(fKey)){
                                DescribeFieldResult dfr = data.get(fKey);
                                if (lKey == 'id') {
                                    idField = dfr.getName();
                                } else if (fKey == 'name') {
                                    nameField = dfr.getName();
                                } else if (fKey == 'search') {
                                    searchField = dfr.getName();
                                }
                                fieldVal = dfr.getName().toLowerCase();
                                if (!fieldsToQuery.contains(fieldVal)) {
                                    fieldsToQuery.add(fieldVal);
                                    validateAndAddReference(dfr, fieldsToQuery, fieldsRefrences);
                                }
                            }
                            /*
                            if (sFieldMap.containsKey(fieldVal)) {
                                DescribeFieldResult dfr = sFieldMap.get(fieldVal).getDescribe();
                                if (dfr.isAccessible()) {
                                    if (fKey == 'Id') {
                                        idField = dfr.getName();
                                    } else if (fKey == 'name') {
                                        nameField = dfr.getName();
                                    } else if (fKey == 'search') {
                                        searchField = dfr.getName();
                                    }
                                    if (!fieldsToQuery.contains(fieldVal)) {
                                        fieldsToQuery.add(fieldVal);
                                        validateAndAddReference(dfr, fieldsToQuery, fieldsRefrences);
                                    }
                                }
                            }
                            */
                        }
                    }
                    System.debug('> searchField ' +searchField);
                    System.debug('> idField ' +idField);
                    System.debug('> nameField ' +nameField);
                    if (additionalFields != null) {
                        for (String field: additionalFields.split(',')) {
                            field = field.toLowerCase();
                            if (sFieldMap.containsKey(field)) {
                                if (!fieldsToQuery.contains(field)) {
                                    fieldsToQuery.add(field);
                                    validateAndAddReference(sFieldMap.get(field).getDescribe(), fieldsToQuery, fieldsRefrences);
                                }
                            }
                        }
                    }

                    if (String.isNotBlank(additionalDisplayField)) {
                        for (String field: additionalDisplayField.split(',')) {
                            field = field.toLowerCase();
                            field = field.trim();
                            if (sFieldMap.containsKey(field)) {
                                DescribeFieldResult dfr = sFieldMap.get(field).getDescribe();
                                if (dfr.isAccessible()) {
                                    additionalDisplayFields.add(dfr.getName());
                                    if (!fieldsToQuery.contains(field)) {
                                        fieldsToQuery.add(field);
                                        validateAndAddReference(dfr, fieldsToQuery, fieldsRefrences);
                                    }
                                }
                            }
                        }
                    }

                    if (nameField == '') {
                        nameField = getNameField(objName.toLowerCase());
                    }
                    if (String.isNotEmpty(nameField)) {
                        result.put('fieldName', nameField);
                        // if (fieldsRefrences.containsKey(nameField)) {
                        //     Map<String, Object> data = (Map<String, Object>) fieldsRefrences.get(nameField);
                        //     result.put('fieldName', data.get('relationshipName') + '.' + data.get('name'));
                        // }
                        if (searchField == '') {
                            searchField = nameField;
                        }
                        nameField = nameField.toLowerCase();
                        if (!fieldsToQuery.contains(nameField)) {
                            fieldsToQuery.add(nameField);
                        }
                    }

                    String val = value != null ? String.escapeSingleQuotes(value) : '';
                    List<String> recIds = new List<String>();
                    if (recordIds != null) {
                        for (String recId: recordIds) {
                            if (recId instanceof Id) {
                                recIds.add(recId);
                            }
                        }
                    }
                    if (!fieldsToQuery.contains('id') && !fieldsToQuery.contains('Id')) {
                        fieldsToQuery.add('id');
                    }
                    System.debug('> searchField ' +searchField);
                    if (fieldsRefrences.containsKey(searchField)) {
                        Map<String, Object> data = (Map<String, Object>) fieldsRefrences.get(searchField);
                        searchField = data.get('relationshipName') + '.' + data.get('name');
                    }
                    System.debug('> searchField ' +searchField);
                    if (String.isNotEmpty(nameField)) {
                        String query = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ',') + ' FROM ' + objName;
                        String op = ' WHERE ';
                        String slimit = ' LIMIT 1000';
                        if (val != '') {
                            query += op + searchField + ' like \'%' + val + '%\' ';
                            op = ' AND ';
                        }
                        if (filter != '') {
                            query += op + filter;
                            op = ' AND ';
                        }
                        if (!recids.isEmpty()) {
                            if (isInclude == true) {
                                query += op + idField + ' in :recids';
                            } else {
                                query += op + idField + ' not in :recids';
                            }
                        }
                        query += ' ORDER BY ' + nameField + ' ASC' + slimit;
                        System.debug('fieldsRefrences ' + fieldsRefrences);
                        System.debug('>query '+ query);
                        result.put('query', query);
                        result.put('fieldId', idField);
                        result.put('fieldSearch', searchField);
                        result.put('additionalDisplayFields', additionalDisplayFields);
                        result.put('fieldsRefrences', fieldsRefrences);
                        result.put('status', true);
                        result.put('isCreateable', dsr.isCreateable());
                        result.put('records', Database.query(query));
                    }
                }
            }
        }
        return result;
    }

    /*******************************************************************************************************
     * @description Method used to get Reference field details
     * @return None
     * @param drf: sObject DescribeFieldResults
     * @param fieldsToQuery: List of sObject fields
     * @param fieldsRefrences: collection of field reference
     **/
    static void validateAndAddReference(DescribeFieldResult drf, Set<String> fieldsToQuery, Map<String, Object> fieldsRefrences) {
        if (drf.getType() == Schema.DisplayType.Reference && drf.getReferenceTo().size() > 0) {
            if (drf.getRelationshipName() != 'Owner') {
                DescribeSObjectResult dsr = drf.getReferenceTo()[0].getDescribe();
                String namedField = getNameField(dsr.getName().toLowerCase());
                if (namedField != null) {
                    fieldsToQuery.add(drf.getRelationshipName() + '.' + namedField);
                    Map<String, Object> data = new Map<String, Object>();
                    data.put('relationshipName', drf.getRelationshipName());
                    data.put('name', namedField);
                    fieldsRefrences.put(drf.getName(), data);
                }
            }
        }
    }

    /*******************************************************************************************************
     * @description Method used to get sObject fields
     * @return Map<String, SobjectField>
     * @param sObjectName: sObject API names
     **/
    static Map<String, SobjectField> getSobjectFieldsMap(String sObjectName) {
        if (sobjectWithFieldMap.containsKey(sObjectName)) {
            return sobjectWithFieldMap.get(sObjectName);
        }
        SObjectType sObjectType = GLOBAL_SOBJECT_TYPE.get(sObjectName);
        if (sObjectType != null) {
            DescribeSObjectResult dsr = sObjectType.getDescribe();
            sobjectWithFieldMap.put(sObjectName, dsr.fields.getMap());
            return dsr.fields.getMap();
        }
        return new Map<String, SobjectField>();
    }
    
    /**
     * @author Dharmendra
     * @name getNameField
     * @description returning named field name
     * @param sObjectName -> Name of Sobject
     * @return String
     */
    public static String getNameField(String sObjectName) {
        Map<String, SobjectField> fMap = getSobjectFieldsMap(sObjectName);
        for (String key: fMap.keySet()) {
            DescribeFieldResult dfr = fMap.get(key).getDescribe();
            if (dfr != null && dfr.isNameField()) {
                if (dfr.isAccessible()) {
                    return dfr.getName();
                }
            }
        }
        return null;
    }
}