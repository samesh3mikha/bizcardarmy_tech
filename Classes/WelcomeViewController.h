//
//  WelcomeViewController.h
//  BizCardArmy
//
//  Created by Bala Bhadra Maharjan on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedStore.h"


@interface WelcomeViewController : UIViewController {
	IBOutlet UINavigationBar *navBar;
	IBOutlet UILabel *labelMessage;
	IBOutlet UILabel *gotoDashboardButton;
}
@property(nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property(nonatomic, retain) IBOutlet UILabel *labelMessage;
@property(nonatomic, retain) IBOutlet UILabel *gotoDashboardButton;

-(IBAction)gotoDashboard:(id)sender;

@end
