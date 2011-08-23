//
//  WebDetailViewController.m
//  SchoolCalendar
//
//  Created by Bala Bhadra Maharjan on 8/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebDetailViewController.h"
#import "OverlayView.h"


@implementation WebDetailViewController

@synthesize toolbar;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

-(id)initWithURLRequest:(NSURLRequest *)aURLRequest{
	if((self = [super init])){
		URLRequest = [aURLRequest retain];
		[self setHidesBottomBarWhenPushed:YES];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Safari" style:UIBarButtonItemStyleBordered
																							target:self action:@selector(openInSafari:)] autorelease];
	toolbar = [[[UIToolbar alloc] init] autorelease];
	toolbar.tintColor = [SharedStore store].navigationBarColor;
	back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_left.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
	forward = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_right.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forward:)];
	back.enabled = NO;
	forward.enabled = NO;
	UIBarButtonItem *padding = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	[toolbar setItems:[NSArray arrayWithObjects:padding, back, forward, padding, nil]];
	[toolbar sizeToFit];
	toolbar.frame = CGRectMake(0, self.view.bounds.size.height - toolbar.bounds.size.height, self.view.bounds.size.width, toolbar.bounds.size.height);
	
	toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
	
	webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - toolbar.bounds.size.height)];
	webView.autoresizesSubviews = YES;
	webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	
	[self.view addSubview:webView];
	[self.view addSubview:toolbar];

	[webView loadRequest:URLRequest];
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

//Implementing a back button
- (void)back:(id)sender{
	[webView goBack];
}

//Implementing a back button
- (void)forward:(id)sender{
	[webView goForward];
}

//Open the current URL in Safari
-(void)openInSafari:(id)sender{
	[[UIApplication sharedApplication] openURL:[URLRequest URL]];
}

#pragma mark -
#pragma mark UIWebViewDelegate conformation

- (void)webViewDidStartLoad:(UIWebView *)aWebView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	if(!showingOverlay){
		NSLog(@"overlay");
		OverlayView *overlay = [[[OverlayView alloc] initWithFrame:CGRectMake(0, 0, webView.bounds.size.width, webView.bounds.size.height) 
														   opacity:0.6 color:[UIColor blackColor] animDuration:0.6] autorelease];
		overlay.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[overlay showInView:webView withActivityIndicator:YES];
		showingOverlay = YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (showingOverlay) {
		[[[webView subviews] lastObject] hide];
		showingOverlay = NO;
	}
	back.enabled = [webView canGoBack] ? YES : NO;
	forward.enabled = [webView canGoForward] ? YES : NO;	
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (showingOverlay) {
		[[[webView subviews] lastObject] hide];
		showingOverlay = NO;
	}
}

#pragma mark -
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[webView release];
	[back release];
	[URLRequest release];
    [super dealloc];
}


@end
