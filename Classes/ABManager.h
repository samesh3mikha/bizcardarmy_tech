//
//  ABManager.h
//  BizCardArmy
//
//  Created by training2 on 2/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/**
 *	This class can access address book, then create, delete or update entries.
 *	Each thread needs a different instance of addressbook. So in a threaded environment,
 *	each thread should use a different instance of ABManager class 
 */


#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>


@interface ABManager : NSObject {
@private
	ABRecordRef group;
	ABAddressBookRef addressBook;
}

/**************************PROPERTIES*****************************/

/**
 *	The group to which all the bizcard army cards are saved to.
 **/
@property (nonatomic, readonly) ABRecordRef group;

/**
 *	The address book instance.
 **/
@property (nonatomic, readonly) ABAddressBookRef addressBook;
	

/**************************INSTANCE METHODS*****************************/

/**
 *	Creates a person in addressbook with the given info dictionary.
 **/
-(NSInteger)createPerson:(NSDictionary *)infoDict;
-(ABRecordRef)editPerson:(ABRecordRef )aRecord withDictionary:(NSDictionary *)infoDict;
-(ABRecordRef)editPerson:(ABRecordRef )aRecord withDictionary:(NSDictionary *)infoDict;
-(NSInteger)checkIfDuplicateContact:(NSDictionary *)infoDict;

@end
