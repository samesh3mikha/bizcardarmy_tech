//
//  Card.h
//  BizCardArmy
//
//  Created by IphoneMac on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Card :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * card_id;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * updated_at;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * middle_name;
@property (nonatomic, retain) NSString * address1;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * image_url_medium;
@property (nonatomic, retain) NSString * image_url_original;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * image_url_thumb;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * job_title;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * photo_file_name;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSNumber * addressbookID;

@property (nonatomic, readonly) NSString *first_name_char1; //get the initials
@property (nonatomic, readonly) NSString *last_name_char1; //get the initials
@property (nonatomic, readonly) NSString *company_char1; //get the initials
@property (nonatomic, readonly) NSString *city_char1; //get the initial

@end



