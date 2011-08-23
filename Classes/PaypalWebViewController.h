//
//  PaypalWebViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedStore.h"
#import "OverlayView.h"

@protocol PaypalWebViewControllerDelegate;

@interface PaypalWebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UINavigationBar *navBar;
	IBOutlet UIBarButtonItem *backButton, *safariButton;
	IBOutlet UIWebView *paypalWeb;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *prevPageButton, *nextPageButton;		
	BOOL showingOverlay;
	id <PaypalWebViewControllerDelegate> delegate;
}

//---------  PROPERTIES --------- 
@property(nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *backButton, *safariButton;
@property(nonatomic, retain) IBOutlet UIWebView *paypalWeb;
@property(nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *prevPageButton, *nextPageButton;
@property(nonatomic, assign) id <PaypalWebViewControllerDelegate> delegate;

//---------  IBACTION METHODS --------- 
-(IBAction)goBack:(id)sender;
-(void)openAppInSafari:(id)sender;
-(IBAction)gotoPrevPage:(id)sender;
-(IBAction)gotoNextPage:(id)sender;

@end

//--------- PROTOCOLS --------- 
@protocol PaypalWebViewControllerDelegate

@optional
	-(void)callGetUserCreditInfo;
@end

