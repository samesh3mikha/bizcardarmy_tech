//
//  StaticPageController.h
//  BizCardArmy
//
//  Created by IphoneMac on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebDetailViewController.h"


@interface StaticPageController : UIViewController {
	IBOutlet UIWebView *webView;
	IBOutlet UILabel *helpLabel;
}

//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *helpLabel;

//---------  IBACTION METHODS --------- 
-(IBAction)openCloudFactory:(id)sender;

@end
