/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

@IsTest
private with sharing class fflib_SObjectUnitOfWorkTest 
{
	// SObjects (in order of dependency) used by UnitOfWork in tests bellow	
	private static List<Schema.SObjectType> MY_SOBJECTS = 
		new Schema.SObjectType[] { 
			Product2.SObjectType, 
			PricebookEntry.SObjectType, 
			Opportunity.SObjectType, 
			OpportunityLineItem.SObjectType };

	@IsTest
	private static void testUnitOfWorkNewDirtyDelete()
	{
		// Insert Opporunities with UnitOfWork
		{
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS);				
			for(Integer o=0; o<10; o++)
			{
				Opportunity opp = new Opportunity();
				opp.Name = 'UoW Test Name ' + o;
				opp.StageName = 'Open';
				opp.CloseDate = System.today();
				uow.registerNew(opp);		
				for(Integer i=0; i<o+1; i++)
				{						
					Product2 product = new Product2();
					product.Name = opp.Name + ' : Product : ' + i;
					uow.registerNew(product);		
					PricebookEntry pbe = new PricebookEntry();
					pbe.UnitPrice = 10;
					pbe.IsActive = true;
					pbe.UseStandardPrice = false;
					pbe.Pricebook2Id = Test.getStandardPricebookId();
					uow.registerNew(pbe, PricebookEntry.Product2Id, product);		
					OpportunityLineItem oppLineItem = new OpportunityLineItem();
					oppLineItem.Quantity = 1;
					oppLineItem.TotalPrice = 10;
					uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
					uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
				}
			}					
			uow.commitWork();
		}
		
		// Assert Results 
		assertResults('UoW');
		// Records to update
		List<Opportunity> opps = [select Id, Name, (Select Id from OpportunityLineItems) from Opportunity where Name like 'UoW Test Name %' order by Name];
		
		// Update some records with UnitOfWork
		{
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS);	
			Opportunity opp = opps[0];
			opp.Name = opp.Name + ' Changed';	
			uow.registerDirty(opp);			
			Product2 product = new Product2();
			product.Name = opp.Name + ' : New Product';
			uow.registerNew(product);		
			PricebookEntry pbe = new PricebookEntry();
			pbe.UnitPrice = 10;
			pbe.IsActive = true;
			pbe.UseStandardPrice = false;
			pbe.Pricebook2Id = Test.getStandardPricebookId();
			uow.registerNew(pbe, PricebookEntry.Product2Id, product);
			OpportunityLineItem newOppLineItem = new OpportunityLineItem();
			newOppLineItem.Quantity = 1;
			newOppLineItem.TotalPrice = 10;
			uow.registerRelationship(newOppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
			uow.registerNew(newOppLineItem, OpportunityLineItem.OpportunityId, opp);			
			OpportunityLineItem existingOppLine = opp.OpportunityLineItems[0];
			// Test that operations on the same object can be daisy chained, and the same object registered as dirty more than once
			// This verifies that using a Map to back the dirty records collection prevents duplicate registration.
			existingOppLine.Quantity = 2;
			uow.registerDirty(existingOppLine);
			existingOppLine.TotalPrice = 20;
			uow.registerDirty(existingOppLine);
			uow.commitWork();
		}
				
		opps = [select Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity, TotalPrice from OpportunityLineItems Order By PricebookEntry.Product2.Name) from Opportunity where Name like 'UoW Test Name %' order by Name];
		assertOppSize(10, opps);
		System.assertEquals('UoW Test Name 0 Changed', opps[0].Name, 'Name should be updated');
		System.assertEquals(2, opps[0].OpportunityLineItems.size(), 'Lineitems shoule be created');
		// Verify that both fields were updated properly
		System.assertEquals(2, opps[0].OpportunityLineItems[0].Quantity, 'Quantity should be updated');
		System.assertEquals(20, opps[0].OpportunityLineItems[0].TotalPrice, 'TotalPrice should be updated');
		System.assertEquals('UoW Test Name 0 Changed : New Product', opps[0].OpportunityLineItems[1].PricebookEntry.Product2.Name, 'Name should be updated');
		
		// Delete some records with the UnitOfWork
		{
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS);	
			uow.registerDeleted(opps[0].OpportunityLineItems[1].PricebookEntry.Product2); // Delete PricebookEntry Product 
			uow.registerDeleted(opps[0].OpportunityLineItems[1].PricebookEntry); // Delete PricebookEntry
			uow.registerDeleted(opps[0].OpportunityLineItems[1]); // Delete OpportunityLine Item
			// Register the same deletions more than once.
			// This verifies that using a Map to back the deleted records collection prevents duplicate registration.
			uow.registerDeleted(opps[0].OpportunityLineItems[1].PricebookEntry.Product2); // Delete PricebookEntry Product 
			uow.registerDeleted(opps[0].OpportunityLineItems[1].PricebookEntry); // Delete PricebookEntry
			uow.registerDeleted(opps[0].OpportunityLineItems[1]); // Delete OpportunityLine Item
			uow.commitWork();
		}		
		
		opps = [select Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity from OpportunityLineItems Order By PricebookEntry.Product2.Name) from Opportunity where Name like 'UoW Test Name %' order by Name];
		List<Product2> prods = [Select Id from Product2 where Name = 'UoW Test Name 0 Changed : New Product'];
		System.assertEquals(10, opps.size(), 'There should be 10 opportunity created');
		System.assertEquals('UoW Test Name 0 Changed', opps[0].Name, 'Name should be updated');
		System.assertEquals(1, opps[0].OpportunityLineItems.size(), 'Out of 2 only 1 is availabled since the other item was deleted'); // Should have deleted OpportunityLineItem added above
		System.assertEquals(0, prods.size(), 'Should be deleted.'); // Should have deleted Product added above				
	}


	@IsTest
	private static void testUnitOfWorkUpsert()
	{
		// Insert Opporunities with UnitOfWork
		{
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS);				
			for(Integer o=0; o<10; o++)
			{
				Opportunity opp = new Opportunity();
				opp.Name = 'UoW Test Name ' + o;
				opp.StageName = 'Open';
				opp.CloseDate = System.today();
				uow.registerUpsert(opp);		
				for(Integer i=0; i<o+1; i++)
				{						
					Product2 product = new Product2();
					product.Name = opp.Name + ' : Product : ' + i;
					uow.registerUpsert(product);		
					PricebookEntry pbe = new PricebookEntry();
					pbe.UnitPrice = 10;
					pbe.IsActive = true;
					pbe.UseStandardPrice = false;
					pbe.Pricebook2Id = Test.getStandardPricebookId();
					uow.registerNew(pbe, PricebookEntry.Product2Id, product);		
					OpportunityLineItem oppLineItem = new OpportunityLineItem();
					oppLineItem.Quantity = 1;
					oppLineItem.TotalPrice = 10;
					uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
					uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
				}
			}					
			uow.commitWork();
		}
		
		// Assert Results 
		assertResults('UoW');
		// Records to update
		List<Opportunity> opps = [select Id, Name, (Select Id from OpportunityLineItems) from Opportunity where Name like 'UoW Test Name %' order by Name];
		
		// Update some records with UnitOfWork
		{
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(MY_SOBJECTS);	
			Opportunity opp = opps[0];
			opp.Name = opp.Name + ' Changed';	
			uow.registerUpsert(opp);			
			Product2 product = new Product2();
			product.Name = opp.Name + ' : New Product';
			uow.registerUpsert(product);		
			PricebookEntry pbe = new PricebookEntry();
			pbe.UnitPrice = 10;
			pbe.IsActive = true;
			pbe.UseStandardPrice = false;
			pbe.Pricebook2Id = Test.getStandardPricebookId();
			uow.registerNew(pbe, PricebookEntry.Product2Id, product);
			OpportunityLineItem newOppLineItem = new OpportunityLineItem();
			newOppLineItem.Quantity = 1;
			newOppLineItem.TotalPrice = 10;
			uow.registerRelationship(newOppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
			uow.registerNew(newOppLineItem, OpportunityLineItem.OpportunityId, opp);			
			OpportunityLineItem existingOppLine = opp.OpportunityLineItems[0];
			// Test that operations on the same object can be daisy chained, and the same object registered as dirty more than once
			// This verifies that using a Map to back the dirty records collection prevents duplicate registration.
			existingOppLine.Quantity = 2;
			uow.registerUpsert(existingOppLine);
			existingOppLine.TotalPrice = 20;
			uow.registerUpsert(existingOppLine);
			uow.commitWork();
		}
		
		// Assert Results
				
		opps = [select Id, Name, (Select Id, PricebookEntry.Product2.Name, Quantity, TotalPrice from OpportunityLineItems Order By PricebookEntry.Product2.Name) from Opportunity where Name like 'UoW Test Name %' order by Name];
		assertOppSize(10, opps);
		System.assertEquals('UoW Test Name 0 Changed', opps[0].Name, 'Name should be updated');
		System.assertEquals(2, opps[0].OpportunityLineItems.size(), '2 lineitems should be created');
		// Verify that both fields were updated properly
		System.assertEquals(2, opps[0].OpportunityLineItems[0].Quantity, 'Quantity should be updated');
		System.assertEquals(20, opps[0].OpportunityLineItems[0].TotalPrice, 'Price should be updated');
		System.assertEquals('UoW Test Name 0 Changed : New Product', opps[0].OpportunityLineItems[1].PricebookEntry.Product2.Name, 'Name should be updated');	
	}

	static void assertOppSize(Integer size, List<Opportunity> opps ){
		System.assertEquals(size, opps.size(), 'There should be ' + size + ' opportunity created');
	}
	
	private static void assertResults(String prefix)
	{
		// Standard Assertions on tests data inserted by tests
		String filter = prefix + ' Test Name %';
		List<Opportunity> opps = [select Id, Name, (Select Id from OpportunityLineItems) from Opportunity where Name like :filter order by Name];
		assertOppSize(10, opps);
		System.assertEquals(1, opps[0].OpportunityLineItems.size(), 'Opportunity 1 should have lineitems');		
		System.assertEquals(2, opps[1].OpportunityLineItems.size(), 'Opportunity 2 should have lineitems');		
		System.assertEquals(3, opps[2].OpportunityLineItems.size(), 'Opportunity 3 should have lineitems');		
		System.assertEquals(4, opps[3].OpportunityLineItems.size(), 'Opportunity 4 should have lineitems');		
		System.assertEquals(5, opps[4].OpportunityLineItems.size(), 'Opportunity 5 should have lineitems');		
		System.assertEquals(6, opps[5].OpportunityLineItems.size(), 'Opportunity 6 should have lineitems');		
		System.assertEquals(7, opps[6].OpportunityLineItems.size(), 'Opportunity 7 should have lineitems');		
		System.assertEquals(8, opps[7].OpportunityLineItems.size(), 'Opportunity 8 should have lineitems');		
		System.assertEquals(9, opps[8].OpportunityLineItems.size(), 'Opportunity 9 should have lineitems');		
		System.assertEquals(10, opps[9].OpportunityLineItems.size(), 'Opportunity 10 should have lineitems');		
	}
}