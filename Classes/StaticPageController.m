//
//  StaticPageController.m
//  BizCardArmy
//
//  Created by IphoneMac on 2/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StaticPageController.h"
#import "Toast.h"
#import "BizCardArmyAppDelegate.h"

@implementation StaticPageController

@synthesize webView;
@synthesize helpLabel;

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)openCloudFactory:(id)sender{
	if (![SharedStore store].hostActive) {
		Toast *toast = [[[Toast alloc] initWithMessage:@"Could not connect to the server"] autorelease];
		toast.frame = CGRectMake(20, 300, 280, 50);
		toast.borderOffset = CGSizeMake(2, 2);
		toast.tint = [UIColor orangeColor];
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
		[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];	
		return;
	}	
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cloudfactory.com"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	WebDetailViewController *webVC = [[[WebDetailViewController alloc] initWithURLRequest:request] autorelease];
	webVC.title = @"CloudFactory";
	[self.navigationController pushViewController:webVC animated:YES];
	
}

#pragma mark -
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
    [super dealloc];
}


@end
