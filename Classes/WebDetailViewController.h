//
//  WebDetailViewController.h
//  SchoolCalendar
//
//  Created by Bala Bhadra Maharjan on 8/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedStore.h"
#import "OverlayView.h"

/**
 *	This view controller provides the functionality of a minimal web browser.
 *	User can browse through a provided URL with back and forward functionalities. 
 */

@interface WebDetailViewController : UIViewController <UIWebViewDelegate>{
	NSURLRequest *URLRequest;
	UIWebView *webView;
	UIToolbar *toolbar;
	UIBarButtonItem *back, *forward;
	BOOL showingOverlay;
}

//---------  PROPERTIES --------- 
@property(nonatomic, retain) UIToolbar *toolbar;

//---------  SELF METHODS ---------
-(id)initWithURLRequest:(NSURLRequest *)aURLRequest;	
@end
