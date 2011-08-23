// 
//  Card.m
//  BizCardArmy
//
//  Created by IphoneMac on 1/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Card.h"


@implementation Card 

@dynamic card_id;
@dynamic source;
@dynamic zip;
@dynamic status;
@dynamic company;
@dynamic country;
@dynamic user_id;
@dynamic updated_at;
@dynamic fax;
@dynamic middle_name;
@dynamic address1;
@dynamic city;
@dynamic last_name;
@dynamic state;
@dynamic image_url_medium;
@dynamic image_url_original;
@dynamic address2;
@dynamic website;
@dynamic image_url_thumb;
@dynamic phone;
@dynamic mobile;
@dynamic email;
@dynamic job_title;
@dynamic created_at;
@dynamic photo_file_name;
@dynamic first_name;
@dynamic addressbookID;

@synthesize first_name_char1;	//get the initials
@synthesize last_name_char1;	//get the initials
@synthesize company_char1;		//get the initials
@synthesize city_char1;			//get the initials


- (NSString *)first_name_char1{
    return [self.first_name substringToIndex:1];
}

- (NSString *)last_name_char1{
    return [self.last_name substringToIndex:1];
}

- (NSString *)company_name_char1{
    return [self.company substringToIndex:1];
}

- (NSString *)city_char1{
    return [self.city substringToIndex:1];
}

@end
