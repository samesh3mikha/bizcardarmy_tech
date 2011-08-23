//
//  ABManager.m
//  BizCardArmy
//
//  Created by training2 on 2/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ABManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@implementation ABManager
@synthesize group;
@synthesize addressBook;

//get instance of addressBook
-(ABAddressBookRef)addressBook{
	if(!addressBook){
		addressBook = ABAddressBookCreate();
	}
	return addressBook;
}

//get instance of BizCardArmy group
-(ABRecordRef)group{
	//group instance is null
	if(!group){
		//group id exists. try to find group.
		CFArrayRef grpval= ABAddressBookCopyArrayOfAllGroups(self.addressBook);
		CFIndex groupCount = ABAddressBookGetGroupCount(self.addressBook);
		for (int i = 0; i < groupCount; i++) {
			ABRecordRef aGroup = CFArrayGetValueAtIndex(grpval, i);
			NSString *groupName = (NSString *)ABRecordCopyCompositeName(aGroup);
			if ([groupName isEqual:@"BizCardArmy"]) {
				group = CFRetain(aGroup);
			}
			[groupName release];
		}
		CFRelease(grpval);
		if(group)
			return group;
		
		//group could not be found, create new group.
		group = ABGroupCreate();
		ABRecordSetValue(group, kABGroupNameProperty, @"BizCardArmy", nil);
		ABAddressBookAddRecord(self.addressBook, group, nil);
		ABAddressBookSave(self.addressBook, nil);
	}
	return group;
	
}

-(NSInteger)createPerson:(NSDictionary *)infoDict{	

	//create addressbook and person
	ABRecordRef aRecord = ABPersonCreate();
	aRecord = [self editPerson:aRecord withDictionary:infoDict];
	
	/**********************************/
	/* save the contact */
	/**********************************/

	//add record to address book
	CFErrorRef anError = NULL;

	NSInteger id = -1;
	if(aRecord){
		ABAddressBookAddRecord(self.addressBook, aRecord, &anError);
		if(self.group)
			ABGroupAddMember(self.group, aRecord, &anError);
		//commit 
		ABAddressBookSave(self.addressBook, &anError);
		if(anError){
		
		}
		id = ABRecordGetRecordID(aRecord);
		//release memory
		CFRelease(aRecord);
	}
	return id;
}

-(ABRecordRef)editPerson:(ABRecordRef )aRecord withDictionary:(NSDictionary *)infoDict{
	CFErrorRef anError = NULL;

	/**********************************/
	/*set image*/
	/**********************************/
	if([infoDict objectForKey:@"CardImage"]){
		NSData *imageData = UIImagePNGRepresentation([infoDict objectForKey:@"CardImage"]);
		ABPersonSetImageData (aRecord, (CFDataRef)imageData, &anError);
	}
	
	
	/**********************************/
	/*set single valued properties first*/
	/**********************************/
	//
	
	//set first name
	if([infoDict valueForKey:@"FirstName"]){
		ABRecordSetValue(aRecord, kABPersonFirstNameProperty, [infoDict valueForKey:@"FirstName"], &anError);
	}
	//set middle name
	if([infoDict valueForKey:@"MiddleName"]){
		ABRecordSetValue(aRecord, kABPersonMiddleNameProperty, [infoDict valueForKey:@"MiddleName"], &anError);
	}
	//set last name
	if([infoDict valueForKey:@"LastName"]){
		ABRecordSetValue(aRecord, kABPersonLastNameProperty, [infoDict valueForKey:@"LastName"], &anError);
	}
	//set organization
	if([infoDict valueForKey:@"Company"]){
		ABRecordSetValue(aRecord, kABPersonOrganizationProperty, [infoDict valueForKey:@"Company"], &anError);
	}
	//set job title
	if([infoDict valueForKey:@"Post"]){
		ABRecordSetValue(aRecord, kABPersonJobTitleProperty, [infoDict valueForKey:@"Post"], &anError);
	}
	//set email address
	
	
	/**********************************/
	/*set multivalued properties*/
	/**********************************/
	
	/*set url*/
	/**********************************/
	if([infoDict valueForKey:@"Website"]){
		ABMutableMultiValueRef url = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(url, [infoDict valueForKey:@"Website"], kABPersonHomePageLabel, NULL);
		ABRecordSetValue(aRecord, kABPersonURLProperty, url, &anError);
		CFRelease(url);
	}
	
	/*set email address*/
	/**********************************/
	if([infoDict valueForKey:@"Email"]){
		ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(email, [infoDict valueForKey:@"Email"], kABWorkLabel, NULL);
		ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
		CFRelease(email);
	}
	
	/*set phone number*/
	/**********************************/
	
	if([infoDict valueForKey:@"Phone"] || [infoDict valueForKey:@"Mobile"] || [infoDict valueForKey:@"Fax"]){
		ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		if([infoDict valueForKey:@"Phone"]){
			ABMultiValueAddValueAndLabel(phone, [infoDict valueForKey:@"Phone"], kABPersonPhoneMainLabel, NULL);
		}
		if([infoDict valueForKey:@"Mobile"]){
			ABMultiValueAddValueAndLabel(phone, [infoDict valueForKey:@"Mobile"], kABPersonPhoneMobileLabel, NULL);
		}
		if([infoDict valueForKey:@"Fax"]){
			ABMultiValueAddValueAndLabel(phone, [infoDict valueForKey:@"Fax"], kABPersonPhoneWorkFAXLabel, NULL);
		}
		ABRecordSetValue(aRecord, kABPersonPhoneProperty, phone, &anError);
		CFRelease(phone);
	}
	
	/**********************************/
	/*set multivalued with dictionary properties*/
	/**********************************/
	
	ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
	CFStringRef keys[5];
	CFStringRef values[5];
	keys[0]      = kABPersonAddressStreetKey;
	keys[1]      = kABPersonAddressCityKey;
	keys[2]      = kABPersonAddressStateKey;
	keys[3]      = kABPersonAddressZIPKey;
	keys[4]      = kABPersonAddressCountryKey;
	values[0]    = [infoDict valueForKey:@"Address1"] ? (CFStringRef)[infoDict valueForKey:@"Address1"] : (CFStringRef)@"";
	values[1]    = [infoDict valueForKey:@"City"] ? (CFStringRef)[infoDict valueForKey:@"City"] : (CFStringRef)@"";
	values[2]    = [infoDict valueForKey:@"State"] ? (CFStringRef)[infoDict valueForKey:@"State"] : (CFStringRef)@"";
	values[3]    = [infoDict valueForKey:@"Zip"] ? (CFStringRef)[infoDict valueForKey:@"Zip"] : (CFStringRef)@"";
	values[4]    = [infoDict valueForKey:@"Country"] ? (CFStringRef)[infoDict valueForKey:@"Country"] : (CFStringRef)@""; 
	CFDictionaryRef aDict = CFDictionaryCreate(kCFAllocatorDefault, (void *)keys, (void *)values, 5,&kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	// Add the address to the person record.
	ABMultiValueAddValueAndLabel(address, aDict, kABWorkLabel, NULL);
	ABRecordSetValue(aRecord, kABPersonAddressProperty, address, &anError);
	
	CFRelease(aDict);
	CFRelease(address);
	
	return aRecord;
}

-(NSInteger)checkIfDuplicateContact:(NSDictionary *)infoDict{

	BOOL duplicate;
	NSInteger addressBookID = 0;
	
	CFArrayRef allPeople = (CFArrayRef)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
	for (int i=0; i < ABAddressBookGetPersonCount(self.addressBook); i++) {
		ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
		duplicate = YES;
		if (person) {
			NSString *fname = [(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) autorelease];
			if ((fname || [infoDict valueForKey:@"FirstName"]) && ![fname isEqualToString:[infoDict valueForKey:@"FirstName"]]) {
				duplicate = NO;
				continue;
			}
			NSString *mname = [(NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty) autorelease];
			if ((mname || [infoDict valueForKey:@"MiddleName"]) && ![mname isEqualToString:[infoDict valueForKey:@"MiddleName"]]) {
				duplicate = NO;
				continue;
			}
			NSString *lname = [(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) autorelease];
			if ((lname || [infoDict valueForKey:@"LastName"]) && ![lname isEqualToString:[infoDict valueForKey:@"LastName"]]) {
				duplicate = NO;
				continue;
			}
			NSString *company = [(NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty) autorelease];
			if ((company || [infoDict valueForKey:@"Company"]) && ![company isEqualToString:[infoDict valueForKey:@"Company"]]) {
				duplicate = NO;
				continue;
			}
			NSString *post = [(NSString *)ABRecordCopyValue(person, kABPersonJobTitleProperty) autorelease];
			if ((post || [infoDict valueForKey:@"Post"]) && ![post isEqualToString:[infoDict valueForKey:@"Post"]]) {
				duplicate = NO;
				continue;
			}
			ABMultiValueRef phoneMultiValue =[(NSString *)ABRecordCopyValue(person, kABPersonPhoneProperty) autorelease];
			for(CFIndex i=0;i<ABMultiValueGetCount(phoneMultiValue); i++)
			{
				if (ABMultiValueCopyValueAtIndex(phoneMultiValue, i) ) {
					NSString *value = [(NSString*)ABMultiValueCopyValueAtIndex(phoneMultiValue, i) autorelease];
					if (i==0 && (value || [infoDict valueForKey:@"Phone"]) && ![value isEqualToString:[infoDict valueForKey:@"Phone"]]) {
						duplicate = NO;
						continue;
					}
					else if (i==1 && (value || [infoDict valueForKey:@"Mobile"]) && ![value isEqualToString:[infoDict valueForKey:@"Mobile"]]) {
						duplicate = NO;
						continue;						
					}
					else if (i==2 && (value || [infoDict valueForKey:@"Fax"]) && ![value isEqualToString:[infoDict valueForKey:@"Fax"]]) {
						duplicate = NO;
						continue;						
					}
				}
			}
			ABMultiValueRef urlMultiValue =[(NSString *)ABRecordCopyValue(person, kABPersonURLProperty) autorelease];
			for(CFIndex i=0;i<ABMultiValueGetCount(urlMultiValue); i++)
			{
				if (ABMultiValueCopyValueAtIndex(urlMultiValue, i)) {
					NSString *value = [(NSString*)ABMultiValueCopyValueAtIndex(urlMultiValue, i) autorelease];
					if (i==0 && (value || [infoDict valueForKey:@"Website"]) && ![value isEqualToString:[infoDict valueForKey:@"Website"]]) {
						duplicate = NO;
						continue;
					}
				}
			}
			ABMultiValueRef emailMultiValue =[(NSString *)ABRecordCopyValue(person, kABPersonEmailProperty) autorelease];
			for(CFIndex i=0;i<ABMultiValueGetCount(emailMultiValue) ;i++)
			{
				if (ABMultiValueCopyValueAtIndex(emailMultiValue, i)) {
					NSString *value = [(NSString*)ABMultiValueCopyValueAtIndex(emailMultiValue, i) autorelease];
					if (i==0 && (value || [infoDict valueForKey:@"Email"]) && ![value isEqualToString:[infoDict valueForKey:@"Email"]]) {
						duplicate = NO;
						continue;
					}					
				}
			}
			ABMultiValueRef addressMultiValue =[(NSString *)ABRecordCopyValue(person, kABPersonAddressProperty) autorelease];
			for(CFIndex i=0;i<ABMultiValueGetCount(addressMultiValue); i++)
			{
				if (ABMultiValueCopyValueAtIndex(addressMultiValue, i)) {
					NSString *value = [(NSString*)ABMultiValueCopyValueAtIndex(addressMultiValue, i) autorelease];
					if ((![[value valueForKey:@"City"] isEqualToString:@""] || [infoDict valueForKey:@"City"]) && ![[value valueForKey:@"City"] isEqualToString:[infoDict valueForKey:@"City"]]) {
						duplicate = NO;
						continue;
					}
					else if ((![[value valueForKey:@"Country"] isEqualToString:@""] || [infoDict valueForKey:@"Country"]) && ![[value valueForKey:@"Country"] isEqualToString:[infoDict valueForKey:@"Country"]]) {
						duplicate = NO;
						continue;						
					}
					else if ((![[value valueForKey:@"State"] isEqualToString:@""] || [infoDict valueForKey:@"State"]) && ![[value valueForKey:@"State"] isEqualToString:[infoDict valueForKey:@"State"]]) {
						duplicate = NO;
						continue;						
					}					
					else if ((![[value valueForKey:@"Street"] isEqualToString:@""] || [infoDict valueForKey:@"Address1"]) && ![[value valueForKey:@"Street"] isEqualToString:[infoDict valueForKey:@"Address1"]]) {
						duplicate = NO;
						continue;						
					}					
					else if ((![[value valueForKey:@"ZIP"] isEqualToString:@""] || [infoDict valueForKey:@"Zip"]) && ![[value valueForKey:@"ZIP"] isEqualToString:[infoDict valueForKey:@"Zip"]]) {
						duplicate = NO;
						continue;						
					}					
				}
			}
			if (duplicate) {
				addressBookID = ABRecordGetRecordID(person);
				break;
			}
		}		
	}
	
	return addressBookID;
}


-(void)dealloc{
	if(group)
		CFRelease(group);
	if(addressBook)
		CFRelease(addressBook);
	[super dealloc];
}


@end
