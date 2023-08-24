@IsTest
private class FormSubmissionAPIServiceTest {
    static Contact c;
	static Form__c f1;
	static Form_Element__c fe1;
	static FormSubmissionAPIPayload form;

	static String TEXT_ANSWER = 'I am good';
	static String FILE_UPLOAD_DATATYPE= 'File Upload';
	static String BIGLIST_DATATYPE= 'Big List Group';

	static void testHelper(String questionType, String answer, String mapsToObject, String mapsToField) {
		c = new Contact(LastName='Testing', Email='test1@test.com');
		insert c;

		f1 = new Form__c(
			Name = 'Contact'
		);	
		insert f1;

		fe1 = new Form_Element__c(
			Form__c = f1.Id,
			Question__c = 'Where is Spiderman?',
			Type__c = questionType,
			Maps_To_Object__c = mapsToObject,
			Maps_To_Field__c = mapsToField
		);
		insert fe1;
		
		form = new FormSubmissionAPIPayload();
		form.relatedIds = new Set<String> { c.Id };
		form.sobjectKey = '123456677990';
		form.formId = f1.Id;

		FormSubmissionAPIPayload.FormElement ele1 = new FormSubmissionAPIPayload.FormElement();
		ele1.answer = answer;
		ele1.formElementId = fe1.Id;

		form.formElements = new  List<FormSubmissionAPIPayload.FormElement>();
		form.formElements.add(ele1);
	}

	private static void assertValues(List<Form_Submission_Answer__c> answers, List<Form_Submission__c> submissions) {
		assertAnswerSizeCheck(answers);
		assertSubmissionSizeCheck(submissions);
		Assert.areEqual(fe1.Id, answers[0].Form_Element__c, 'assertValues : Form element Id should be set');
		Assert.areEqual(f1.Id, submissions[0].Form__c, 'Form Id should be set');
		Assert.areEqual(c.Id, submissions[0].Contact__c, 'Since contact id was set in the reponse the lookup should have that value set');
	}

	private static void assertAnswerSizeCheck(List<Form_Submission_Answer__c> answers) {
		Assert.areEqual(1, answers.size(), 'One answer record should be created');
	}

	private static void assertSubmissionSizeCheck(List<Form_Submission__c> submissions) {
		Assert.areEqual(1, submissions.size(), 'One submission record should be created');
	}

	@IsTest
	private static void testFormSubmission_caseTextAnswer_expectSuccessfulSave() {
		
		testHelper('Text', TEXT_ANSWER, 'Contact', 'FirstName');
		Test.startTest();
		FormSubmissionAPIPayload[] response = new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		Assert.areEqual(1, response.size(), 'The response should have one record.');
		List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(TEXT_ANSWER, answers[0].Answer__c, 'The answer field should be set from the payload for Text');
	}

	@IsTest
	private static void testFormSubmission_caseTextLongAnswer_expectSuccessfulSave() {
		testHelper('Text (30,000)', TEXT_ANSWER, 'Contact', 'FirstName');
		Test.startTest();
		FormSubmissionAPIPayload[] response = new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();
		Assert.areEqual(1, response.size(), 'The response should have one record returned.');
		List<Form_Submission_Answer__c> answers = [SELECT Answer_Text_Long__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(TEXT_ANSWER, answers[0].Answer_Text_Long__c, 'The answer field should be set from the payload for Text (30,000)');
	}

	@IsTest
	private static void testFormSubmission_caseMultipicklistAnswer_expectSuccessfulSave() {
		testHelper('Multi-Select Picklist', TEXT_ANSWER, 'Contact', 'FirstName');
		
		Test.startTest();
		FormSubmissionAPIPayload[] response = new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();
		Assert.areEqual(1, response.size(), 'The response should have one record returned back.');
		List<Form_Submission_Answer__c> answers = [SELECT Answer_Text_Long__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(TEXT_ANSWER, answers[0].Answer_Text_Long__c, 'The answer field should be set from the payload for Multi-Select Picklist');
	}

	@IsTest
	private static void testFormSubmission_caseNumberAnswer_expectSuccessfulSave() {
		testHelper('Number', '50', 'Contact', 'FirstName');
		
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer_Number__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(50.0, answers[0].Answer_Number__c, 'Then answer field should be set from the payload for Number');
	}


	@IsTest
	private static void testFormSubmission_numberQuestion_allowsDecimalValues_expectSuccessfulSave() {
		testHelper('Number', '50.55', 'Contact', 'FirstName');

		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer_Number__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(50.55, answers[0].Answer_Number__c, 'Then answer field should be set from the payload for decimal values');
	}


	@IsTest
	private static void testFormSubmission_caseDateAnswer_expectSuccessfulSave() {
		testHelper('Date', ''+Date.today(), 'Contact', 'FirstName');

		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer_Date__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(Date.today(), answers[0].Answer_Date__c, 'Then answer field should be set from the payload for date.');
	}

	@IsTest
	private static void testFormSubmission_caseDateAnswer_format2_expectSuccessfulSave() {
		testHelper('Date', '2034-08-08', 'Contact', 'FirstName');

		Test.startTest();
		 new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer_Date__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(2034, answers[0].Answer_Date__c.year(), 'Then answer field should be set from the payload for data with different format');
	}

	@IsTest
	private static void testFormSubmission_caseHiddenQuestionType_expectSuccessfulSave_mapToNumber() {
		testHelper('Hidden', '100', 'Account', 'AnnualRevenue');
		
		Account a = new Account(Name='Testing');
		insert a;
		
		form.relatedIds.add(a.Id);

		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer_Number__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, Account__c FROM Form_Submission__c];

		assertAnswerSizeCheck(answers);
		assertSubmissionSizeCheck(submissions);
		Assert.areEqual(100.0, answers[0].Answer_Number__c, 'Then answer field should be set from the payload for hidden question type');
		Assert.areEqual(fe1.Id, answers[0].Form_Element__c, 'caseHiddenQuestionType: Form element Id should be set');
		Assert.areEqual(f1.Id, submissions[0].Form__c, 'Form Id should be set');
		Assert.areEqual(a.Id, submissions[0].Account__c, 'Since account id was set in the reponse the lookup should have that value set');
	}

	@IsTest
	private static void testFormSubmission_hiddenQuestion_expectSuccessfulSave_mapsToDate() {
		testHelper('Hidden', ''+Date.today(), 'Contact', 'Birthdate');
		

		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer_Date__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(Date.today(), answers[0].Answer_Date__c, 'Then answer field should be set from the payload for hidden date question type');
	}

	@IsTest
	private static void testFormSubmission_hiddenQuestion_expectSuccessfulSave_mapsToFieldOtherThanDateAndNumber() {
		testHelper('Hidden', 'test2@test.com', 'Contact', 'Email');
	
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual('test2@test.com', answers[0].Answer__c, 'Then answer field should be set from the payload for hidden email question type');
	}


	@IsTest
	private static void testFormSubmission_hiddenQuestion_expectUnSuccessfulSave_mapsToDate() {
		testHelper('Hidden', 'test3@test.com', 'Contact', 'Birthdate');
		
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Mapping_Error__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(true, answers[0].Mapping_Error__c.contains('Incorrect format provided.'), 'Then answer field should not be set from the payload as the data is not valid for hidden date datatype');
	}

	@IsTest
	private static void testFormSubmission_hiddenQuestion_expectUnSuccessfulSave_invalidDate() {
		testHelper('Date', 'test4@test.com', 'Contact', 'Birthdate');

		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Mapping_Error__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(true, answers[0].Mapping_Error__c.contains('Invalid Date provided'), 'Then answer field should not be set from the payload as the data is not valid for date datatype');
	}

	@IsTest
	private static void testFormSubmission_numberQuestion_expectUnSuccessfulSave_invalidNumber() {
		testHelper('Number', 'test5@test.com', 'Contact', 'Birthdate');
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Mapping_Error__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(true, answers[0].Mapping_Error__c.contains('expected a numeric value'), 'Then answer field should not be set from the payload as the data is not valid for number question type');
	}

	@IsTest
	private static void testFormSubmission_hiddenQuestion_expectUnSuccessfulSave_invalidNumber() {
		testHelper('Hidden', 'test6@test.com', 'Account', 'AnnualRevenue');
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Mapping_Error__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(true, answers[0].Mapping_Error__c.contains('Incorrect value provided for number datatype'), 'Then answer field should not be set from the payload as the data is not valid hidden number question type');
	}

	@IsTest
	private static void testFormSubmission_hiddenQuestion_expectSuccessfulSave_decimalNumber() {
		testHelper('Hidden', '205.55', 'Account', 'AnnualRevenue');
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer_Number__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(205.55, answers[0].Answer_Number__c, 'Then answer field should be set from the payload for hidden number question type');
	}


	@IsTest
	private static void testFormSubmission_bigListQuestion_expectUnSuccessfulSave_invalidBigListId() {
		testHelper(BIGLIST_DATATYPE, 'test7@test.com', 'Contact', 'Birthdate');
		
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Mapping_Error__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(true, answers[0].Mapping_Error__c.contains('Big List Option provided for Form Element'), 'Then answer field should not be set from the payload as the data is not valid for big list question type');
	}

	@IsTest
	private static void testFormSubmission_bigListQuestion_expectSuccessfulSave() {
		Form_Big_List_Group__c grp = new Form_Big_List_Group__c(Name='Test');
		insert grp;

		Form_Big_List_Option__c opt = new Form_Big_List_Option__c(Form_Big_List_Group__c = grp.Id, Option_Name__c = 'Red', Option_Value__c = 'Red');
		insert opt;

		testHelper(BIGLIST_DATATYPE, opt.Id, 'Contact', 'FirstName');
		

		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Form_Big_List_Option__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(opt.Id, answers[0].Form_Big_List_Option__c, 'Then answer field should be set from the payload as the data is valid');
	}

	@IsTest
	private static void testFormSubmission_caseTextAnswer_expectSuccessfulUpdate() {
		testHelper('Text', TEXT_ANSWER, 'Contact', 'FirstName');
		
		Form_Submission__c submission = new Form_Submission__c(Key__c = '123456677990');
		insert submission;

		Form_Submission_Answer__c answer = new Form_Submission_Answer__c(Form_Element__c = fe1.Id, Form_Submission__c = submission.Id);
		insert answer;

		form.key = '123456677990';
		
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, COntact__c FROM Form_Submission__c];

		assertValues(answers, submissions);
		Assert.areEqual(TEXT_ANSWER, answers[0].Answer__c, 'Then answer field should be set from the payload for text question type');
	}

	//HELPER UNIT TESTS
	@IsTest
	private static void testValidateAnswer_invalidDate_throwsException() {
		testHelper('Date', TEXT_ANSWER, 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			Assert.isInstanceOfType(e, FormSubmissionAPIService.FormSubmissionAPIServiceException.class, 'It is a FormSubmissionAPIServiceException exception while date is being validated.');
			Assert.isTrue(e.getMessage().contains('Invalid Date provided for Form Element'), 'Contains Invalid Date in the error while date is being validated.'); // Assertion succeeds
		}
		Assert.areEqual(true, hasError, 'Exception should be thrown as it contains Invalid Date.');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateAnswer_validDate_throwsNoException() {
		testHelper('Date', ''+Date.today(), 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			
		}
		Assert.areEqual(false, hasError, 'Exception should not be thrown since it is valid date');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateAnswer_validDecimalNumber_throwsNoException() {
		testHelper('Number', '50.56', 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			
		}
		Assert.areEqual(false, hasError, 'Exception should not be thrown since it is valid data');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateAnswer_validIntegerNumber_throwsNoException() {
		testHelper('Number', '50', 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			
		}
		Assert.areEqual(false, hasError, 'Exception should not be thrown since it is valid data');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateAnswer_invalidIntegerNumber_throwsException() {
		testHelper('Number', 'abc', 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			Assert.isInstanceOfType(e, FormSubmissionAPIService.FormSubmissionAPIServiceException.class, 'It is a FormSubmissionAPIServiceException exception thrown for number validation');
			Assert.isTrue(e.getMessage().contains('Invalid data provided for Form Element'), 'Contains Invalid data in the error message for number validation '); // Assertion succeeds
		}
		Assert.areEqual(true, hasError, 'Exception should be thrown as it has invalid number');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateAnswer_invalidBiglistId_throwsException() {
		testHelper(BIGLIST_DATATYPE, 'abc', 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			Assert.isInstanceOfType(e, FormSubmissionAPIService.FormSubmissionAPIServiceException.class, 'It is a FormSubmissionAPIServiceException exception thrown while big list group validation');
			Assert.isTrue(e.getMessage().contains('The Big List Option provided for Form Element'), 'Contains Invalid data in the error while big list group validation error is thrown'); // Assertion succeeds
		}
		Assert.areEqual(true, hasError, 'Exception should be thrown as it has invalid sf id');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateAnswer_invalidBiglistIdUseDifferntId_throwsException() {
		testHelper(BIGLIST_DATATYPE, Helpers.getFakeId(Account.SObjectType), 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			Assert.isInstanceOfType(e, FormSubmissionAPIService.FormSubmissionAPIServiceException.class, 'It is a FormSubmissionAPIServiceException exception thrown when a wrong sf id is passed');
			Assert.isTrue(e.getMessage().contains('The Big List Option provided for Form Element'), 'Contains Invalid data in the error when a wrong sf id is passed'); // Assertion succeeds
		}
		Assert.areEqual(true, hasError, 'Exception should be thrown as it has invalid big list id passed');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateAnswer_validBiglistId_throwsException() {
		testHelper(BIGLIST_DATATYPE, Helpers.getFakeId(Form_Big_List_Option__c.SObjectType), 'Contact', 'FirstName');	
		Test.startTest();
		Boolean hasError = false;
		try {
			new FormSubmissionAPIService().validateAnswer(form.formElements[0], fe1);
		} catch(Exception e) {
			hasError = true;
			
		}
		Assert.areEqual(false, hasError, 'Exception should not be thrown');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateDate_invalidDate_returnFalse() {
		Test.startTest();
		Boolean isValid = false;
		isValid = new FormSubmissionAPIService().isValidDate('abc');
		Assert.areEqual(false, isValid, 'Since the date is invalid should return false');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateDate_validDate_returnTrue() {
		Test.startTest();
		Boolean isValid = false;
		isValid = new FormSubmissionAPIService().isValidDate(''+Date.today());
		Assert.areEqual(true, isValid, 'Since the date is valid should return true');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateSFId_expectReturnValueTrue() {
		testHelper('Date', ''+Date.today(), 'Contact', 'FirstName');	
		Test.startTest();
		Boolean isValid = false;
		isValid = new FormSubmissionAPIService().isValidSalesforceId(fe1.Id, Form_Element__c.SObjectType);
		Assert.areEqual(true, isValid, 'Since the Id is valid should return true');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateSFId_expectReturnValueFalse() {
		testHelper('Date', ''+Date.today(), 'Contact', 'FirstName');	
		Test.startTest();
		Boolean isValid = false;
		isValid = new FormSubmissionAPIService().isValidSalesforceId(fe1.Id, Account.SObjectType);
		Assert.areEqual(false, isValid, 'Since the Id is valid but not matching to account should return false');
		Test.stopTest();
	}

	@IsTest
	private static void testValidateSFId_withString_expectReturnValueFalse() {
		testHelper('Date', ''+Date.today(), 'Contact', 'FirstName');	
		Test.startTest();
		Boolean isValid = false;
		isValid = new FormSubmissionAPIService().isValidSalesforceId('abcd', Account.SObjectType);
		Assert.areEqual(false, isValid, 'Since the Id is valid but not matching to account should return false');
		Test.stopTest();
	}

	@IsTest
	private static void testSetFormLookupRelation_checkAll3Lookups() {
		c = new Contact(LastName='Testing', Email='ctest@test.com');
		insert c;

		Account account = new Account(name =' Test');
		insert account;

		Lead ld = new Lead(LastName='Testing', Email='ltest@test.com', Company = 'Test Company');
		insert ld;

		Form_Submission__c submission = new Form_Submission__c(Key__c = '123456677990');
		insert submission;

		Test.startTest();
		new FormSubmissionAPIService().setFormLookupRelation(submission, new Set<String> { c.Id, account.Id, ld.Id});
		update submission;
		Test.stopTest();

		submission = [SELECT Contact__c, Account__c, Lead__c FROM Form_Submission__c WHERE Id =: submission.Id];
		Assert.areEqual(c.Id, submission.Contact__c, 'Contact Id is set');
		Assert.areEqual(account.Id, submission.Account__c, 'Account Id is set');
		Assert.areEqual(ld.Id, submission.Lead__c, 'Lead Id is set');
	}

	@IsTest
	private static void testFormSubmission_caseFileUploadQuestionType_expectSuccessfulSave() {
		testHelper(FILE_UPLOAD_DATATYPE, 'bac1234567', 'Account', null);
		
		
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT File_Upload_Key__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, Account__c FROM Form_Submission__c];

		assertAnswerSizeCheck(answers);
		assertSubmissionSizeCheck(submissions);
		Assert.areEqual('bac1234567', answers[0].File_Upload_Key__c, 'Then answer field should be set from the payload for file upload	question type');
		Assert.areEqual(fe1.Id, answers[0].Form_Element__c, 'caseFileUploadQuestionType : Form element Id should be set');
		Assert.areEqual(f1.Id, submissions[0].Form__c, 'Form Id should be set');
	}

	@IsTest
	private static void testFormSubmission_caseNoFormElementListSent_expectNoAnswerCreated() {
		testHelper(FILE_UPLOAD_DATATYPE, 'bac1234567', 'Account', null);
		form.formElements = new List<FormSubmissionAPIPayload.FormElement>();
		
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT File_Upload_Key__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, Account__c FROM Form_Submission__c];

		Assert.areEqual(0, answers.size(), 'Since no answer were sent we cannot have any records');
		assertSubmissionSizeCheck(submissions);
	}

	@IsTest
	private static void testFormSubmission_caseNoFormElementIdSent_expectNoAnswerCreated() {
		testHelper(FILE_UPLOAD_DATATYPE, 'bac1234567', 'Account', null);
		form.formElements[0].formElementId = null;
		
		Test.startTest();
		new FormSubmissionAPIService().createFormSubmission(new List<FormSubmissionAPIPayload> { form });
		Test.stopTest();

		List<Form_Submission_Answer__c> answers = [SELECT File_Upload_Key__c, Form_Element__c FROM Form_Submission_Answer__c];
		List<Form_Submission__c> submissions = [SELECT Form__c, Account__c FROM Form_Submission__c];

		Assert.areEqual(0, answers.size(), 'Since no answer were sent we cannot have any records');
		assertSubmissionSizeCheck(submissions);
	}

	@IsTest
	private static void testParseDateStr_success() {
		Test.startTest();
		Form_Submission_Answer__c answer = new Form_Submission_Answer__c();
		new FormSubmissionAPIService().parseDateStr('2034-08-08' , answer);
		Test.stopTest();

		Assert.areEqual(2034, answer.Answer_Date__c.year());
	}

	@IsTest
	private static void testSetFormAnswerLookupRelation_expectFormSubmissionLookupSet() {
		Form_Submission__c submission = new Form_Submission__c(Key__c = '123456677990');
		insert submission;

		Form_Submission_Answer__c answer = new Form_Submission_Answer__c( Answer__c = 'Test');
		insert answer;

		Test.startTest();
		new FormSubmissionAPIService().setFormAnswerLookupRelation(answer, new Set<String> { submission.Id});
		update answer;
		Test.stopTest();
		answer = [SELECT Form_Submission__c FROM Form_Submission_Answer__c WHERE Id =: answer.Id];
		Assert.areEqual(submission.Id, answer.Form_Submission__c, 'Form Submission Id should be set');
	}
}