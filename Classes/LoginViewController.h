//
//  LoginViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "BizCardArmyAppDelegate.h"
#import "SharedStore.h"
#import "SignUpViewController.h"

@interface LoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
	IBOutlet UITableView *loginTable;
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIActivityIndicatorView *loadingSpinner;
	IBOutlet UILabel *message;
	
	NSString *username, *password;
	NSURLConnection *connectionSignIn;
	NSMutableData *responseDataLogin;
}

//---------  PROPERTIES --------- 
@property(nonatomic,retain) IBOutlet UITableView *loginTable;
@property(nonatomic,retain) IBOutlet UITextField *usernameField;
@property(nonatomic,retain) IBOutlet UITextField *passwordField;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property(nonatomic,retain) IBOutlet UILabel *message;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *password;
@property(nonatomic,retain) NSURLConnection *connectionSignIn;

//---------  IBACTION METHODS --------- 
-(void)signUp:(id)sender;

//---------  URLCONNECTION METHODS --------- 
-(void)signIn;

//---------  CUSTOM METHODS ---------
-(void)signInOffline;
-(void)signInAfterDashboard; 

@end
