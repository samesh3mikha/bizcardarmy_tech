//
//  SharedStore.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"
#import"JSON.h"
#import "Card.h"
#import "ABManager.h"
#import "OverlayView.h"

#define SERVER_STRING @"http://bizcardarmy.com"


enum sortingOptions {
	by_firstname = 0,
	by_lastname,
	by_company,
	by_status,
	by_city,
	by_dateCreated
};


@interface SharedStore : NSObject {
    OverlayView *overlayView;
	UIColor *navigationBarColor;
	UIColor *backColorForViews;
	UIColor *colorForTableSeperators;
    
	BOOL hostActive;
	BOOL signingUser, syncingCards, loginConnectionFailed;
	BOOL userSignedIn, userSignedInOffline, dashboardLoaded, userSignedUp;
	BOOL uploadingCards, deletingCards, informingWebServerAboutPurchase;
    BOOL userOnBuyCreditView;
	NSMutableDictionary *allUsersDictionary;
	NSString *currentUser;
	NSMutableDictionary *userDictionary;
	NSMutableDictionary *cardsImageDictionary;
	NSMutableDictionary *createCardsDictionary;
	
	NSInteger currentSortingOption;
	BOOL currentSortingOrderAsc;
	
	NSManagedObjectContext *managedObjectContext;
}
+(SharedStore*)store;

//---------  PROPERTIES ---------
@property(nonatomic, retain) OverlayView *overlayView;
@property (nonatomic, retain) UIColor *navigationBarColor;
@property (nonatomic, retain) UIColor *backColorForViews;
@property (nonatomic, retain) UIColor *colorForTableSeperators;
@property (nonatomic, assign) BOOL hostActive;
@property (nonatomic, assign) BOOL signingUser, syncingCards, loginConnectionFailed;
@property (nonatomic, assign) BOOL userSignedIn, userSignedInOffline;
@property (nonatomic, assign) BOOL dashboardLoaded;
@property (nonatomic, assign) BOOL userSignedUp;
@property (nonatomic, assign) BOOL uploadingCards, deletingCards, informingWebServerAboutPurchase;
@property (nonatomic, assign) BOOL userOnBuyCreditView;
@property (nonatomic, retain) NSMutableDictionary *allUsersDictionary;
@property (nonatomic, retain) NSString *currentUser;
@property (nonatomic, retain) NSMutableDictionary *userDictionary;
@property (nonatomic, retain) NSMutableDictionary *cardsImageDictionary;
@property(nonatomic, retain) NSMutableDictionary *createCardsDictionary;
@property (nonatomic, assign) NSInteger currentSortingOption;
@property (nonatomic, assign) BOOL currentSortingOrderAsc;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//---------  CUSTOM METHODS ---------
-(void)initUserDictionary:(NSMutableDictionary *)userDictionary_C;
-(void)updateAddressBook:(NSInteger)pesond_ID usingDictionary:(NSDictionary *)personDictionary;
-(void)saveCard:(UIImage *)cardImage asFilename:(NSString *)filename;
-(NSData *)imageDataForFilename:(NSString *)filename;
-(void)removeImageFromQueueWithFilename:(NSString *)filename;
-(void)deleteImageWithFilename:(NSString *)filename;
-(NSString *)swapCardFieldAndLabel:(NSString *)fieldOrLabel;
-(NSString *)fullNameForFirstWord:(NSString *)first_word secondWord:(NSString *)second_word thirdWord:(NSString *)third_word;
-(NSDate *)dateFromString:(NSString*)dateString;
-(NSString *)timeDiffFromDate:(NSDate *)refDate;
-(void)setRoundedBorder:(CALayer *)item;
-(UIImage *)imageForStatus:(NSString *)status;


@end
