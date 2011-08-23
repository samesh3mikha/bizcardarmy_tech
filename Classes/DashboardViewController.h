//
//  DashboardViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "JSON.h"
#import "Card.h"
#import "InternetStatus.h"
#import "BizCardArmyAppDelegate.h"
#import "LoginViewController.h"
#import "ABManager.h"
#import "OverlayView.h"
#import "CardsTableCustomCell.h"
#import "IconDownloader.h"
#import "SortingOtionsViewController.h"
#import "CardDetailsViewController.h"
#import "NewCardViewController.h"
#import "AccountViewController.h"
#import "WelcomeViewController.h"

@interface DashboardViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSFetchedResultsControllerDelegate, IconDownloaderDelegate, NewCardViewControllerDelegate, InternetStatusDelegate, AccountViewControllerDelegate, SKPaymentTransactionObserver> {
	IBOutlet UISearchBar *searchBar;
	IBOutlet UITableView *cardsTable;
	IBOutlet UIImageView *bcaIcon;
	IBOutlet UILabel *bcaMessage;
	OverlayView *overlayView;
	
	UIAlertView *deleteCardAlertView, *gotoLoginAlertView;
	
	LoginViewController *loginController;
	BOOL syncedWithWebServer;
	
	NSMutableDictionary *cardsImage;
	NSInteger currentSortingOption;
	BOOL currentSortingOrderAsc;

	NSFetchedResultsController *fetchedResultsController;
	NSTimer *dashboardRefresher;
	NSMutableDictionary *imageDownloadsInProgress;
	
	NSManagedObjectContext *managedObjectContext;
	NSString *searchPredicate;
	
	Card *deleteCard;
	NSMutableArray *deleteCardsQueue, *creditPurchaseInfoQueue;
	NSMutableArray *iphoneDB_card_ids, *iphoneDB_only_card_ids;

	NSURLConnection *connectionSyncCards, *connectionDeleteCard, *connectionPurchaseInfo;
	NSMutableData *responseDataSyncCards, *responseDataDeleteCard, *responseDataPurchaseInfo;
}

//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UITableView *cardsTable;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UIImageView *bcaIcon;
@property (nonatomic, retain) IBOutlet UILabel *bcaMessage;
@property (nonatomic, retain) OverlayView *overlayView;
@property (nonatomic, retain) UIAlertView *deleteCardAlertView, *gotoLoginAlertView;
@property (nonatomic, retain) LoginViewController *loginController;
@property (nonatomic, assign) BOOL syncedWithWebServer;
@property (nonatomic, retain) IBOutlet NSMutableDictionary *cardsImage;
@property (nonatomic, assign) NSInteger currentSortingOption;
@property (nonatomic, assign) BOOL currentSortingOrderAsc;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSTimer *dashboardRefresher;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *searchPredicate;
@property (nonatomic, retain) Card *deleteCard;
@property (nonatomic, retain) NSMutableArray *deleteCardsQueue, *creditPurchaseInfoQueue;
@property (nonatomic, retain) NSURLConnection *connectionSyncCards, *connectionDeleteCard, *connectionPurchaseInfo;

//---------  IBACTION METHODS --------- 
-(void)showSortingOptions:(id)sender;
-(void)refreshDashboard:(id)sender;

//---------  URLCONNECTION METHODS --------- 
-(void)syncWithWebServer;
-(void)deleteCardFromWebServer:(NSInteger )card_ID;
-(void)notifyServerAboutCreditsPurchase:(NSString *)transactionID;

//---------  CUSTOM METHODS --------- 
-(void)configureCell:(CardsTableCustomCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)releaseLoginController;
-(void)showUploadStartMessage;
-(NSString *)getSortingOptionKey;
-(NSString *)getSectionKey;
-(void)startIconDownloadForCard:(Card *)card;
- (void)cancelIconDownloadForCard:(Card *)card;
-(void)showImagesForCard:(Card *)card;
-(BOOL)cardIsPresentWithID:(NSInteger)card_ID;
-(Card *)cardWithId:(NSInteger)card_Id;
-(Card *)card:(Card *)card ForDictionary:(NSDictionary *)cardDictionary;
-(NSDictionary *)dictionaryForCard:(Card *)card;
-(void)syncIphoneNwebDB:(NSArray *)cardsArray;
-(void)keepCreditsPurchaseRecord:(SKPaymentTransaction *)transaction;
-(void)deleteCard:(Card *)card;
-(void)updateDB;
-(void)saveContactInAB:(Card *)card;
-(void)refreshVisibleRows;
-(void)updateUserCredits:(NSObject *)user_credits;

@end

