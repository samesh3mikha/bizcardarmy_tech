//
//  SharedStore.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SharedStore.h"


@implementation SharedStore
static SharedStore* _store = nil;

@synthesize overlayView;
@synthesize navigationBarColor;
@synthesize backColorForViews;
@synthesize colorForTableSeperators;
@synthesize hostActive;
@synthesize signingUser, syncingCards, loginConnectionFailed;
@synthesize userSignedIn, userSignedInOffline, dashboardLoaded;
@synthesize userSignedUp;
@synthesize uploadingCards, deletingCards, informingWebServerAboutPurchase;
@synthesize userOnBuyCreditView;
@synthesize allUsersDictionary, currentUser, userDictionary;
@synthesize cardsImageDictionary;
@synthesize createCardsDictionary;
@synthesize currentSortingOption;
@synthesize currentSortingOrderAsc;
@synthesize managedObjectContext;

+(SharedStore*)store
{
	@synchronized([SharedStore class])
	{
		if (!_store)
			[[self alloc] init];
		return _store;
	}
	
	return nil;
}

+(id)alloc
{
	@synchronized([SharedStore class])
	{
		NSAssert(_store == nil, @"Attempted to allocate a second instance of a singleton.");
		_store = [super alloc];
		return _store;
	}
	
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
		// initialize stuff here
        overlayView = [[OverlayView alloc] init];

		allUsersDictionary = [[NSMutableDictionary alloc] init];
		cardsImageDictionary = [[NSMutableDictionary alloc] init];
		createCardsDictionary = [[NSMutableDictionary alloc] init];	
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"cardsImageDictionary"]) {
			[cardsImageDictionary addEntriesFromDictionary:(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"cardsImageDictionary"]];
		}
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"createCardsDictionary"]) {
			createCardsDictionary = (NSMutableDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"createCardsDictionary"]; 			
		}			
		currentSortingOption = (NSInteger)[[NSUserDefaults standardUserDefaults] integerForKey:@"currentSortingOption"];

		if ([[NSUserDefaults standardUserDefaults] valueForKey:@"currentSortingOrderAsc"] ==  nil) {
			currentSortingOrderAsc = YES;
		}
		else {
			currentSortingOrderAsc = [[NSUserDefaults standardUserDefaults] boolForKey:@"currentSortingOrderAsc"];
		}
		
		hostActive = NO;
		signingUser = NO;
		syncingCards = NO;
		loginConnectionFailed = NO;
		userSignedIn = NO;
		userSignedInOffline = NO;
		dashboardLoaded = NO;
		userSignedUp = NO;
		uploadingCards = NO;
		deletingCards = NO;
        informingWebServerAboutPurchase = NO;
        userOnBuyCreditView = NO;
		self.navigationBarColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5];
		self.backColorForViews = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
		self.colorForTableSeperators = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
	}
	
	return self;
}

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)initUserDictionary:(NSMutableDictionary *)userDictionary_C{
	self.userDictionary = userDictionary_C;	
}

-(void)updateAddressBook:(NSInteger)pesond_ID usingDictionary:(NSDictionary *)personDictionary{
	if (pesond_ID > 0) {
		ABManager *abManager = [[[ABManager alloc] init] autorelease];
		// Fetch the address book 
		ABAddressBookRef addressBook = ABAddressBookCreate();
		
		// Search for the person 
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, pesond_ID);
		
		// Display PersonViewController
		if (person != nil) {
			CFErrorRef anError = NULL;
			person  = [abManager editPerson:person withDictionary:personDictionary];
			ABAddressBookSave(addressBook, &anError);
			if(anError){
				
			}
		}
		// Could not find in contacts
		CFRelease(addressBook);		
	}		
}

-(void)saveCard:(UIImage *)cardImage asFilename:(NSString *)filename{
	NSArray *docpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [docpaths objectAtIndex:0];
	NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];
	[UIImageJPEGRepresentation(cardImage, 0.9) writeToFile:imgPath atomically:YES];
}

-(NSData *)imageDataForFilename:(NSString *)filename{
	NSArray *docpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [docpaths objectAtIndex:0];
	NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];
	UIImage* loadedImage = [UIImage imageWithContentsOfFile:imgPath];
	NSData *imageData = UIImageJPEGRepresentation(loadedImage, 0.9);		
	
	return imageData;
}

-(void)removeImageFromQueueWithFilename:(NSString *)filename{
	[self deleteImageWithFilename:filename];
	NSMutableArray *creatingCardsQueue = [[[NSMutableArray alloc] initWithArray:(NSMutableArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser]] autorelease];
	 for(int i=0; i<[creatingCardsQueue count]; i++){
		 if ([[creatingCardsQueue objectAtIndex:i] isEqualToString:filename]) {
			 [creatingCardsQueue removeObjectAtIndex:i];			 
		 }
	 }
	if ([createCardsDictionary objectForKey:[SharedStore store].currentUser]) {
		if ([creatingCardsQueue count] == 0) {
			[createCardsDictionary removeObjectForKey:[SharedStore store].currentUser];
		}
		else {
			[createCardsDictionary setObject:creatingCardsQueue forKey:[SharedStore store].currentUser];	
		}
		[[NSUserDefaults standardUserDefaults] setObject:createCardsDictionary forKey:@"createCardsDictionary"];
		[[NSUserDefaults standardUserDefaults] synchronize];		
	}
    
}


-(void)deleteImageWithFilename:(NSString *)filename{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *docpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [docpaths objectAtIndex:0];
	NSString *imgPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];
	[fileManager removeItemAtPath:imgPath error:NULL];	
}

-(NSString *)swapCardFieldAndLabel:(NSString *)fieldOrLabel{
	NSString *lableOrField;
	
	if ([fieldOrLabel isEqualToString:@"FirstName"]) {
		lableOrField = @"first_name";
	}
	else if	([fieldOrLabel isEqualToString:@"first_name"]){
		lableOrField = @"FirstName";
	}
	else if ([fieldOrLabel isEqualToString:@"MiddleName"]) {
		lableOrField = @"middle_name";
	}
	else if	([fieldOrLabel isEqualToString:@"middle_name"]){
		lableOrField = @"MiddleName";
	}
	else if ([fieldOrLabel isEqualToString:@"LastName"]) {
		lableOrField = @"last_name";
	}
	else if	([fieldOrLabel isEqualToString:@"last_name"]){
		lableOrField = @"LastName";
	}
	else if ([fieldOrLabel isEqualToString:@"Company"]) {
		lableOrField = @"company";
	}
	else if	([fieldOrLabel isEqualToString:@"company"]){
		lableOrField = @"Company";
	}
	else if ([fieldOrLabel isEqualToString:@"Post"]) {
		lableOrField = @"job_title";
	}
	else if	([fieldOrLabel isEqualToString:@"job_title"]){
		lableOrField = @"Post";
	}
	else if ([fieldOrLabel isEqualToString:@"Email"]) {
		lableOrField = @"email";
	}
	else if	([fieldOrLabel isEqualToString:@"email"]){
		lableOrField = @"Email";
	}
	else if ([fieldOrLabel isEqualToString:@"Website"]) {
		lableOrField = @"website";
	}
	else if	([fieldOrLabel isEqualToString:@"website"]){
		lableOrField = @"Website";
	}
	else if ([fieldOrLabel isEqualToString:@"Phone"]) {
		lableOrField = @"phone";
	}
	else if	([fieldOrLabel isEqualToString:@"phone"]){
		lableOrField = @"Phone";
	}
	else if ([fieldOrLabel isEqualToString:@"Mobile"]) {
		lableOrField = @"mobile";
	}
	else if	([fieldOrLabel isEqualToString:@"mobile"]){
		lableOrField = @"Mobile";
	}
	else if ([fieldOrLabel isEqualToString:@"Fax"]) {
		lableOrField = @"fax";
	}
	else if	([fieldOrLabel isEqualToString:@"fax"]){
		lableOrField = @"Fax";
	}
	else if ([fieldOrLabel isEqualToString:@"Address1"]) {
		lableOrField = @"address1";
	}
	else if	([fieldOrLabel isEqualToString:@"address1"]){
		lableOrField = @"Address1";
	}
	else if ([fieldOrLabel isEqualToString:@"Address2"]) {
		lableOrField = @"address2";
	}
	else if	([fieldOrLabel isEqualToString:@"address2"]){
		lableOrField = @"Address2";
	}
	else if ([fieldOrLabel isEqualToString:@"City"]) {
		lableOrField = @"city";
	}
	else if	([fieldOrLabel isEqualToString:@"city"]){
		lableOrField = @"City";
	}
	else if ([fieldOrLabel isEqualToString:@"State"]) {
		lableOrField = @"state";
	}
	else if	([fieldOrLabel isEqualToString:@"state"]){
		lableOrField = @"State";
	}
	else if ([fieldOrLabel isEqualToString:@"Country"]) {
		lableOrField = @"country";
	}
	else if	([fieldOrLabel isEqualToString:@"country"]){
		lableOrField = @"Country";
	}
	else if ([fieldOrLabel isEqualToString:@"Zip"]) {
		lableOrField = @"zip";
	}
	else if	([fieldOrLabel isEqualToString:@"zip"]){
		lableOrField = @"Zip";
	}
	
	return lableOrField;
}

-(NSString *)fullNameForFirstWord:(NSString *)first_word secondWord:(NSString *)second_word thirdWord:(NSString *)third_word{
	NSMutableString *name = [[[NSMutableString alloc] initWithString:@""] autorelease];
	if (first_word) {
		[name appendFormat:@"%@",first_word];
	}
	if (second_word) {
		[name appendFormat:@" %@",second_word];
	}	
	if (third_word) {
		[name appendFormat:@" %@", third_word];
	}
	
	return name;
}

-(NSDate *)dateFromString:(NSString*)dateString{
	dateString = [[dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@" GMT"];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzzz"];
	NSDate *date = [[[NSDate alloc] init] autorelease];
	date = [dateFormatter dateFromString:dateString];

	return date;
}

-(NSString *)timeDiffFromDate:(NSDate *)refDate{
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;			
	NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:refDate  toDate:[NSDate date]  options:0];
	NSString *timeInterval;
	if ([conversionInfo month] > 0) {
		timeInterval = [NSString stringWithFormat:@"%d months", [conversionInfo month]];
	}
	else if ([conversionInfo day] > 0) {
		timeInterval = [NSString stringWithFormat:@"%d days", [conversionInfo day]];
	}
	else if ([conversionInfo hour] > 0) {
		timeInterval = [NSString stringWithFormat:@"%d hrs", [conversionInfo hour]];
	}
	else if ([conversionInfo minute] > 0) {
		timeInterval = [NSString stringWithFormat:@"%d min", [conversionInfo minute]];
	}
	else{
		timeInterval = [NSString stringWithFormat:@"few seconds"];
	}
	return timeInterval;
}

-(void)setRoundedBorder:(CALayer *)item{
	CALayer *l = item;
	l.masksToBounds = YES;
	l.cornerRadius = 8.0;
	l.borderWidth = 1.5;
	UIColor *grayColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.5];
	l.borderColor = [grayColor CGColor];				
}

-(UIImage *)imageForStatus:(NSString *)status{
	UIImage	*statusImage;
	if ([status isEqualToString:@"completed"] || [status isEqualToString:@"sample"]) {
		statusImage = [UIImage imageNamed:@"button-completed.png"];
	}
	else if ([status isEqualToString:@"pending"] || [status isEqualToString:@"queued"]) {
		statusImage = [UIImage imageNamed:@"button-pending.png"];
	}
	else if ([status isEqualToString:@"unpaid"]) {
		statusImage = [UIImage imageNamed:@"button-unpaid.png"];
	}
	
	return statusImage;
}

@end
