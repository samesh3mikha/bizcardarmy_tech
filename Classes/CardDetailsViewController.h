//
//  CardDetailsViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Card.h"
#import "BizCardArmyAppDelegate.h"
#import "SharedStore.h"
#import "DashboardViewController.h"
#import "CardImageViewController.h"
#import "ABManager.h"
#import "EditFieldCell.h"
#import "OverlayView.h"

@interface CardDetailsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,ABPersonViewControllerDelegate, EditFieldCellDelegate, UITextFieldDelegate> {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UITableView *cardDetailsTable;
	IBOutlet UIButton *cardImageButton;
	IBOutlet UIToolbar *cardEventToolBar;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *detailInfoLabel;
	IBOutlet UIImageView *statusImageView;
	OverlayView *overlayView;

	Card *card;
	UIImage *cardImage;
	NSMutableArray *cardDetailKeys;
	NSMutableDictionary *cardDetailsValue;
	NSMutableDictionary *cardUpdateDictionary;
	BOOL changesMade;
	
	NSManagedObjectContext *managedObjectContext;
	
	NSURLConnection *connectionUpdateCard, *connectionDisputeCard;
	NSMutableData *responseDataUpdateCard, *responseDataDisputeCard;
}

//---------  PROPERTIES --------- 
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UITableView *cardDetailsTable;
@property(nonatomic, retain) IBOutlet UIButton *cardImageButton;
@property(nonatomic, retain) IBOutlet UIToolbar *cardEventToolBar;
@property(nonatomic, retain) IBOutlet UILabel *nameLabel;
@property(nonatomic, retain) IBOutlet UILabel *detailInfoLabel;
@property(nonatomic, retain) IBOutlet UIImageView *statusImageView;
@property(nonatomic, retain) OverlayView *overlayView;
@property(nonatomic, retain) NSMutableArray *cardDetailKeys;
@property(nonatomic, retain) NSMutableDictionary *cardDetailsValue;
@property(nonatomic, retain) NSMutableDictionary *cardUpdateDictionary;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) NSURLConnection *connectionUpdateCard, *connectionDisputeCard;

//---------  SELF METHODS ---------
-(id) initWithCard:(Card *)_card cardImage:(UIImage *)_cardImage;

//---------  IBACTION METHODS --------- 
-(IBAction)showLargeCard:(id)sender;
-(IBAction)addressBookButtonClicked:(id)sender;
-(IBAction)deleteCardButtonClicked:(id)sender;

//---------  URLCONNECTION METHODS --------- 
-(void)updateCardInWebServer:(NSString *)updateParam;
-(void)sendDisputeRequest;

//---------  CUSTOM METHODS --------- 
-(void)displayCardInfo;
-(void)adjustScrollViewContent;
-(void)deleteCardFromDB;
-(NSString *)cardValueForField:(NSString *)field;
- (void)updateCardInIphone;

@end
