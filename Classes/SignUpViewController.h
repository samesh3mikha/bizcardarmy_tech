//
//  SignUpViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "BizCardArmyAppDelegate.h"
#import "SharedStore.h"


@interface SignUpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
	IBOutlet UITableView *signUpTable;
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UITextField *confirmPasswordField;
	IBOutlet UIActivityIndicatorView *loadingSpinner;
	IBOutlet UILabel *message;
	
	NSMutableData *responseDataSignUp;		/* Response Data For each Connection */	
}

//---------  PROPERTIES --------- 
@property(nonatomic,retain) IBOutlet UITableView *signUpTable;
@property(nonatomic,retain) IBOutlet UITextField *usernameField;
@property(nonatomic,retain) IBOutlet UITextField *passwordField;
@property(nonatomic,retain) IBOutlet UITextField *confirmPasswordField;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property(nonatomic,retain) IBOutlet UILabel *message;

//---------  URLCONNECTION METHODS --------- 
-(void)signUp;

@end
