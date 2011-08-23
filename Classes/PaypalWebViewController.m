//
//  PaypalWebViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaypalWebViewController.h"


@implementation PaypalWebViewController

@synthesize navBar;
@synthesize backButton, safariButton;
@synthesize paypalWeb;
@synthesize toolBar;
@synthesize prevPageButton, nextPageButton;
@synthesize delegate;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navBar.tintColor = [SharedStore store].navigationBarColor;
	self.toolBar.tintColor = [SharedStore store].navigationBarColor;
	[self.backButton setTarget:self];
	[self.safariButton setTarget:self];
	[self.prevPageButton setTarget:self];
	[self.nextPageButton setTarget:self];
	[self.backButton setAction:@selector(goBack:)];
	[self.safariButton setAction:@selector(openAppInSafari:)];
	[self.prevPageButton setAction:@selector(gotoPrevPage:)];
	[self.nextPageButton setAction:@selector(gotoNextPage:)];
	
	//Open Web BizCA page for allowing user to buy credits
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/mobile_buy_credit",SERVER_STRING]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[paypalWeb loadRequest:request];
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)goBack:(id)sender{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	[delegate callGetUserCreditInfo];
}

-(void)openAppInSafari:(id)sender{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/sign_in?mobile=true",SERVER_STRING]]];
}

-(IBAction)gotoPrevPage:(id)sender{
	[paypalWeb goBack];
}

-(IBAction)gotoNextPage:(id)sender{
	[paypalWeb goForward];
}

#pragma mark -
#pragma mark UIWebViewDelegate conformation

- (void)webViewDidStartLoad:(UIWebView *)aWebView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	if(!showingOverlay){
		NSLog(@"overlay");
		OverlayView *overlay = [[[OverlayView alloc] initWithFrame:CGRectMake(0, 0, paypalWeb.bounds.size.width, paypalWeb.bounds.size.height) 
														   opacity:0.6 color:[UIColor blackColor] animDuration:0.6] autorelease];
		[overlay showInView:paypalWeb withActivityIndicator:YES];
		showingOverlay = YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (showingOverlay) {
		[[[paypalWeb subviews] lastObject] hide];
		showingOverlay = NO;
	}
	prevPageButton.enabled = [paypalWeb canGoBack] ? YES : NO;
	nextPageButton.enabled = [paypalWeb canGoForward] ? YES : NO;	
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (showingOverlay) {
		[[[paypalWeb subviews] lastObject] hide];
		showingOverlay = NO;
	}
}


#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[navBar release];
	[backButton, safariButton release];
	[paypalWeb release];
	[toolBar release];
	[prevPageButton, nextPageButton release];
    [super dealloc];
}

@end
