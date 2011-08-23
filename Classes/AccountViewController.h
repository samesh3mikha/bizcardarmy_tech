//
//  AccountViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "BizCardArmyAppDelegate.h"
#import "SharedStore.h"
#import "PaypalWebViewController.h"
#import "StaticPageController.h"
#import "BuyCreditsViewController.h"

@protocol AccountViewControllerDelegate;

@interface AccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PaypalWebViewControllerDelegate> {
	IBOutlet UITableView *accountOptionsTable;
    
	NSMutableArray *userInfoLabel;
	NSMutableArray *userInfoValue;
	
	NSManagedObjectContext *managedObjectContext;
	
	NSURLConnection *connectionGetUserIfo;
	NSMutableData *responseDataGetUserIfo;
	
	id <AccountViewControllerDelegate> delegate;
}
	
//---------  PROPERTIES --------- 
@property(nonatomic, retain) IBOutlet UITableView *accountOptionsTable;
@property(nonatomic, retain) NSMutableArray *userInfoLabel;
@property(nonatomic, retain) NSMutableArray *userInfoValue;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) NSURLConnection *connectionGetUserIfo;
@property(nonatomic, assign) id <AccountViewControllerDelegate> delegate;

//---------  IBACTION METHODS --------- 
-(IBAction)logOutOfSystem:(id)sender;

//---------  URLCONNECTION METHODS ---------
-(void)getUserCreditInfo;

//---------  CUSTOM METHODS ---------
-(void)askUserToBuyCreditThroughWeb;
-(void)showPaypalWebView;
-(void)showBuyCreditsView;
-(void)refreshUserInfo;

@end

//--------- PROTOCOLS --------- 
@protocol AccountViewControllerDelegate
	@optional
		-(void)CancelUrlConnections;
		-(void)refreshUserCredit;
@end
