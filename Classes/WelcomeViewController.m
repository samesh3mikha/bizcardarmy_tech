//
//  WelcomeViewController.m
//  BizCardArmy
//
//  Created by Bala Bhadra Maharjan on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WelcomeViewController.h"


@implementation WelcomeViewController

@synthesize navBar;
@synthesize labelMessage;
@synthesize gotoDashboardButton;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [SharedStore store].backColorForViews;
	self.navBar.tintColor = [SharedStore store].navigationBarColor;
		
	labelMessage.text = [NSString stringWithFormat:@"You have %@ free credits. \n Open your dusty desk drawer and start snapping to keep the army busy!\n\nYou can also login with this account at 'www.bizcardarmy.com' to access more features.",[[SharedStore store].userDictionary objectForKey:@"credit"]];
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)gotoDashboard:(id)sender{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[labelMessage release];
	[gotoDashboardButton release];
    [super dealloc];
}

@end
