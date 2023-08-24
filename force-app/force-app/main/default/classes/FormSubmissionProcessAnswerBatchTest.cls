@IsTest
private class FormSubmissionProcessAnswerBatchTest {
    
    static Contact c;
	static Form__c f1;
	static Form_Element__c fe1;
	static Form_Submission__c submission;
    static Form_Submission_Answer__c[] formAnswer;
	static String TEXT_ANSWER = 'I am good';

	static void testHelper(String questionType, String answer, String mapsToObject, String mapsToField) {
		c = new Contact(LastName='Testing', Email='test@test.com');
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
		
		
        submission = new Form_Submission__c(Key__c = Helpers.generateKey(), Form__c = f1.Id, Status__c = FormSubmissionAPIService.STATUS_TOPROCESS, Contact__c=c.Id);
		insert submission;

		formAnswer = new List<Form_Submission_Answer__c>();
		formAnswer.add(new Form_Submission_Answer__c(Form_Submission__c=submission.Id, Form_Element__c=fe1.Id, Answer__c= answer,Answer_Text_Long__c = answer ));
        insert formAnswer;
	}

    @IsTest
    private static void testBatchConstructor_withNoParams() {
        Test.startTest();
		FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Test.stopTest();   
        Assert.areEqual(null, batch.query, 'Since it has no query paam passed this var is not yet set');
    }

    @IsTest
    private static void testBatchConstructor_withParams() {
        Test.startTest();
		FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch('SELECT Id from Account');
		Test.stopTest();   
        Assert.areEqual('SELECT Id from Account', batch.query, 'Since it has  query param passed this var is set');
    }

	static void checkCompleteStatus(List<Form_Submission__c> submissions) {
		Assert.areEqual(FormSubmissionAPIService.STATUS_COMPLETE, submissions[0].Status__c, 'The form must be processed and marked as complete');
	}

    @IsTest
	private static void testFormSubmission_caseTextAnswer_expectSuccessfulMapping() {
		
		testHelper('Text', TEXT_ANSWER, 'Contact', 'FirstName');

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT FirstName FROM Contact WHERE Id =: c.Id];
        Assert.areEqual(TEXT_ANSWER, cList[0].FirstName, 'The form must be processed & contact first name should be updated form the give text answer');
	}

    @IsTest
	private static void testFormSubmission_caseTextLongAnswer_expectSuccessfulMapping() {
		
		testHelper('Text (30,000)', TEXT_ANSWER, 'Contact', 'FirstName');

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c FROM Form_Submission_Answer__c];
		
		checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT FirstName FROM Contact WHERE Id =: c.Id];
        Assert.areEqual(answers[0].Answer__c, cList[0].FirstName, 'The form must be processed & contact first name should be updated from text long answer');
	}

    @IsTest
	private static void testFormSubmission_caseMultiPicklistAnswer_expectSuccessfulMapping() {
		
		testHelper('Multi-Select Picklist', 'Agriculture', 'Account', 'Industry');
        Account account = new Account(Name =' Test Account 1');
        insert account;

        submission.Account__c = account.Id;
        update submission;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Answer_Text_Long__c, Form_Element__c FROM Form_Submission_Answer__c];
		checkCompleteStatus(submissions); 
        List<Account> cList = [SELECT Industry FROM Account WHERE Id =: account.Id];
        Assert.areEqual(answers[0].Answer_Text_Long__c, cList[0].Industry, 'The form must be processed & account industry should be updated from multi picklist answer');
	}

    @IsTest
	private static void testFormSubmission_casePicklistAnswer_expectSuccessfulMapping() {
		
		testHelper('Picklist', 'Agriculture', 'Account', 'Industry');
        Account account = new Account(Name =' Test Account2');
        insert account;

        submission.Account__c = account.Id;
        update submission;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Answer_Text_Long__c, Form_Element__c FROM Form_Submission_Answer__c];
		
		checkCompleteStatus(submissions); 
        List<Account> cList = [SELECT Industry FROM Account WHERE Id =: account.Id];
        Assert.areEqual(answers[0].Answer_Text_Long__c, cList[0].Industry, 'The form must be processed & account  industry should be updated from picklist answer');
	}

    @IsTest
	private static void testFormSubmission_caseNumberAnswer_expectSuccessfulMapping() {
		
		testHelper('Number', '10000', 'Account', 'AnnualRevenue');
        Account account = new Account(Name =' Test Account3');
        insert account;

        submission.Account__c = account.Id;
        update submission;

        formAnswer[0].Answer_Number__c = 10000;
        update formAnswer;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Answer_Number__c, Form_Element__c FROM Form_Submission_Answer__c];
		
		checkCompleteStatus(submissions); 
        List<Account> cList = [SELECT AnnualRevenue FROM Account WHERE Id =: account.Id];
        Assert.areEqual(answers[0].Answer_Number__c, cList[0].AnnualRevenue, 'The form must be processed & account  AnnualRevenue should be updated from number answer');
	}

    @IsTest
	private static void testFormSubmission_caseNumberAnswerViaHiddenQuestion_expectSuccessfulMapping() {
		
		testHelper('Hidden', '10000', 'Account', 'AnnualRevenue');
        Account account = new Account(Name =' Test Account4');
        insert account;

        submission.Account__c = account.Id;
        update submission;

        formAnswer[0].Answer_Number__c = 10000;
        update formAnswer;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Answer_Number__c, Form_Element__c FROM Form_Submission_Answer__c];
		
		checkCompleteStatus(submissions); 
        List<Account> cList = [SELECT AnnualRevenue FROM Account WHERE Id =: account.Id];
        Assert.areEqual(answers[0].Answer_Number__c, cList[0].AnnualRevenue, 'The form must be processed & account  AnnualRevenue should be updated from hidden question answer');
	}

    @IsTest
	private static void testFormSubmission_caseDateAnswer_expectSuccessfulMapping() {
		
		testHelper('Date', ''+Date.today(), 'Contact', 'BirthDate');

        formAnswer[0].Answer_Date__c = Date.today();
        update formAnswer;


		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		
		checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT BirthDate FROM Contact WHERE Id =: c.Id];
        Assert.areEqual(Date.today(), cList[0].BirthDate, 'The form must be processed & contact BirthDate should be updated from date answer');
	}

    @IsTest
	private static void testFormSubmission_caseDateAnswerViaHiddenQuestion_expectSuccessfulMapping() {
		
		testHelper('Hidden', ''+Date.today(), 'Contact', 'BirthDate');

        formAnswer[0].Answer_Date__c = Date.today();
        update formAnswer;


		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		
		checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT BirthDate FROM Contact WHERE Id =: c.Id];
        Assert.areEqual(Date.today(), cList[0].BirthDate, 'The form must be processed & contact BirthDate should be updated from hidden question answer');
	}

    @IsTest
	private static void testFormSubmission_caseBooleanAnswer_expectSuccessfulMapping() {
		
		testHelper('Checkbox', '1', 'Contact', 'HasOptedOutOfFax');

        formAnswer[0].Answer_Date__c = Date.today();
        update formAnswer;


		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		
		checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT HasOptedOutOfFax FROM Contact WHERE Id =: c.Id];
        Assert.areEqual(true, cList[0].HasOptedOutOfFax, 'The form must be processed & contact HasOptedOutOfFax should be updated for checkbox answer');
	}

    @IsTest
	private static void testFormSubmission_caseBooleanAnswerViaHiddenQuestion_expectSuccessfulMapping() {
		
		testHelper('Hidden', '1', 'Contact', 'HasOptedOutOfFax');

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		
		checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT HasOptedOutOfFax FROM Contact WHERE Id =: c.Id];
        Assert.areEqual(true, cList[0].HasOptedOutOfFax, 'The form must be processed & contact HasOptedOutOfFax should be updated from hidden question answer');
	}

    @IsTest
	private static void testFormSubmission_caseTextAnswerViaHiddenQuestion_expectSuccessfulMapping() {
		
		testHelper('Hidden', 'John', 'Contact', 'FirstName');

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		
		checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT FirstName FROM Contact WHERE Id =: c.Id];
        Assert.areEqual('John', cList[0].FirstName, 'The form must be processed & contact first name should be updated from hidden question answer');
	}

    @IsTest
	private static void testFormSubmission_caseFileUpload_expectSuccessfulMapping() {
		
		testHelper('File Upload', 'Abc12345', 'Contact', null);

        ContentVersion cvlist = new Contentversion();
		cvlist.Title = 'CZDSTOU';
		cvlist.PathOnClient = 'test';
		cvlist.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
		cvlist.Related_Key__c ='Abc12345';
		insert cvlist;

        formAnswer[0].File_Upload_Key__c='Abc12345';
        update formAnswer;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
		
		checkCompleteStatus(submissions); 
        //there should be content document link
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: c.Id];
        Assert.areEqual(1, links.size(), 'Should have one associated record');
	}

    //Error Cases - Bad Mapping + Invalid Data

	static void assertErrorCheck(Form_Submission__c[] submissions) {
		Assert.areEqual(FormSubmissionAPIService.STATUS_ERROR, submissions[0].Status__c, 'The form must be processed and marked as error');	
	}

    @IsTest
	private static void testFormSubmission_parentObjectLookupMissing_expectUnSuccessfulMapping() {
		
		testHelper('Date', TEXT_ANSWER, 'Contact', 'BirthDate');

        submission.Contact__c = null;
        update submission;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c, Mapping_Error__c FROM Form_Submission_Answer__c];
		
		assertErrorCheck(submissions);
        Assert.areEqual(true, answers[0].Mapping_Error__c.contains('The  lookup is not set on the parent Form Submission record'), 'The  lookup is not set on the parent Form Submission record this message should be set');

        List<Contact> cList = [SELECT FirstName FROM Contact WHERE Id =: c.Id];
        System.assertNotEquals(TEXT_ANSWER, cList[0].FirstName, 'The form must be processed & contact first name should not be updated due to lookup value not set on submission');
	}

    @IsTest
	private static void testFormSubmission_formElementMappingFieldMissing_NoMappingDone() {
		
		testHelper('Date', TEXT_ANSWER, 'Contact',null);

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c, Mapping_Error__c FROM Form_Submission_Answer__c];
		
		assertErrorCheck(submissions);
        Assert.areEqual(true, answers[0].Mapping_Error__c.contains('The Map to field is not set on the parent Form Element record'), 'The Map to field is not set on the parent Form Element record this message should be set');
	}

    @IsTest
    private static void testFormSubmission_invalidMapping_dateToEmail() {
		//date question mapped to email field should throw an mapping error
		testHelper('Date', ''+Date.today(), 'Contact','Email');

        formAnswer[0].Answer_Date__c = Date.today();
        update formAnswer;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c, Mapping_Error__c FROM Form_Submission_Answer__c];
		
		assertErrorCheck(submissions);
        Assert.areEqual(true, answers[0].Mapping_Error__c.contains('Illegal assignment from Date to String'), 'DateToEmail- Invalid data mapping should throw an error - Illegal assignment from Date to String');
	}

    @IsTest
    private static void testFormSubmission_invalidMapping_invalidEmailAddress() {
		//date question mapped to email field should throw an mapping error
		testHelper('Text', 'bt@test', 'Contact','Email');

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c, Mapping_Error__c FROM Form_Submission_Answer__c];
		
		assertErrorCheck(submissions);
        Assert.areEqual(true, answers[0].Mapping_Error__c.contains('INVALID_EMAIL_ADDRESS: Email: invalid email address'), 'Invalid data mapping should throw an error - Invalid Email Address');
	}

    @IsTest
    private static void testFormSubmission_multipleFormBeingProcessed() {

        Contact contact = new Contact(LastName='Testing' , Email = 'testing@bt.com');
        Contact contact2 = new Contact(LastName='Doe' , Email = 'doe@bt.com');
        insert new List<Contact> { contact , contact2 };
		
        Form__c form = new Form__c(Name ='Form1');
        Form__c form2 = new Form__c(Name ='Form2');
        insert new List<Form__c> { form, form2 };

        Form_Element__c fe1 = createElement('Date', 'Contact', 'Email', form.Id); 
        Form_Element__c fe2 = createElement('Text', 'Contact', 'FirstName', form2.Id);  
		insert new List<Form_Element__c> { fe1, fe2};

        Form_Submission__c submission1 = new Form_Submission__c(Key__c = Helpers.generateKey(), Form__c = form.Id, Status__c = FormSubmissionAPIService.STATUS_TOPROCESS, Contact__c=contact.Id);
        Form_Submission__c submission2 = new Form_Submission__c(Key__c = Helpers.generateKey(), Form__c = form2.Id, Status__c = FormSubmissionAPIService.STATUS_TOPROCESS, Contact__c=contact2.Id);
		insert new List<Form_Submission__c> { submission1, submission2} ;

		formAnswer = new List<Form_Submission_Answer__c>();
		formAnswer.add(new Form_Submission_Answer__c(Form_Submission__c=submission1.Id, Form_Element__c=fe1.Id, Answer_Date__c = Date.today() ));
        formAnswer.add(new Form_Submission_Answer__c(Form_Submission__c=submission2.Id, Form_Element__c=fe2.Id, Answer__c = 'John' ));
        insert formAnswer;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c WHERE Status__c = 'Error'];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c, Mapping_Error__c FROM Form_Submission_Answer__c WHERE Form_Submission__c =: submissions[0].Id];
		
		assertErrorCheck(submissions);
        System.assertNotEquals(null, answers[0].Mapping_Error__c, 'Date/Email Conversion- Invalid data mapping should throw an error - Illegal assignment from Date to String');

        submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c WHERE Status__c =: FormSubmissionAPIService.STATUS_COMPLETE];
        answers = [SELECT Answer__c, Form_Element__c, Mapping_Error__c FROM Form_Submission_Answer__c WHERE Form_Submission__c =: submissions[0].Id];

        checkCompleteStatus(submissions); 
        List<Contact> cList = [SELECT FirstName FROM Contact WHERE Id =: contact2.Id];
        Assert.areEqual('John', cList[0].FirstName, 'The form must be processed & contact first name should be updated');
	}

    @IsTest
    private static void testFormSubmission_invalidMapping_dateToEmail_scheduledMethodCalled() {
		//date question mapped to email field should throw an mapping error
		testHelper('Date', ''+Date.today(), 'Contact','Email');

        formAnswer[0].Answer_Date__c = Date.today();
        update formAnswer;

		Test.startTest();
        FormSubmissionProcessAnswerBatch batch = new FormSubmissionProcessAnswerBatch();
		batch.execute(null);
		Test.stopTest();

		List<Form_Submission__c> submissions = [SELECT Form__c, Contact__c,Status__c FROM Form_Submission__c];
        List<Form_Submission_Answer__c> answers = [SELECT Answer__c, Form_Element__c, Mapping_Error__c FROM Form_Submission_Answer__c];
		
		assertErrorCheck(submissions);
        Assert.areEqual(true, answers[0].Mapping_Error__c.contains('Illegal assignment from Date to String'), 'Invalid data mapping should throw an error - Illegal assignment from Date to String');
	}

	private static Form_Element__c createElement(String type, String mapsto, String mapsfield, Id formId) {
		return  new Form_Element__c(
			Form__c = formId,
			Question__c = 'Where is Superman?',
			Type__c = type,
			Maps_To_Object__c = mapsto,
			Maps_To_Field__c = mapsfield
		);	
	}

}
