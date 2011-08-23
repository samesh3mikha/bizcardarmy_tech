//
//  CardImageViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CardImageViewController.h"
#import "Toast.h"
#import "BizCardArmyAppDelegate.h"

@implementation CardImageViewController

@synthesize scrollView;
@synthesize imageLoadingSpinner;
@synthesize cardImageURL;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

-(id) initWithCardImageUR:(NSString *)_cardImageURL{
	if((self = [super init])){
		self.cardImageURL = _cardImageURL;
	}
	return self;	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	responseDataCardImage = [[NSMutableData alloc] init];
	
	self.view.backgroundColor = [SharedStore store].backColorForViews;
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:cardImageURL]] delegate:self];
	if (conn) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self.imageLoadingSpinner startAnimating];
	}
}

#pragma mark -
#pragma mark  ---------- NSURLCONNECTION DELEGATE METHODS ----------

//Connection #1 (Goto S3) for downloading Card Image

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	[responseDataCardImage setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseDataCardImage appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	[imageLoadingSpinner stopAnimating];

	Toast *toast = [[[Toast alloc] initWithMessage:@"Error occured while downloading the image"] autorelease];
	toast.frame = CGRectMake(20, 300, 280, 50);
	toast.borderOffset = CGSizeMake(2, 2);
	toast.tint = [UIColor orangeColor];
	toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
	[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[imageLoadingSpinner stopAnimating];

    // Set appIcon and clear temporary data/image
	UIImage *image = [[UIImage alloc] initWithData:responseDataCardImage];
	UIImageView	*imageView = [[UIImageView alloc] initWithImage:image];
	[[SharedStore store] setRoundedBorder:[imageView layer]];

	CGFloat originX,originY, sizeX, sizeY;
	if ([imageView frame].size.width > 310) {
		originX = [imageView frame].origin.x;
	}
	else {
		originX = (310 - [imageView frame].size.width)/2;
	}
	if ([imageView frame].size.height > 400) {
		originY = [imageView frame].origin.y;
	}
	else {
		originY = (400 - [imageView frame].size.height)/2;
	}
	sizeX = [imageView frame].size.width;
	sizeY = [imageView frame].size.height;
	[imageView setFrame:CGRectMake(originX , originY, sizeX, sizeY)];
	
	[self.scrollView addSubview:imageView];
	[self.scrollView setContentSize:[image size]];

	[image release];
	[imageView release];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[connection release];
}

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[imageLoadingSpinner release];
	[cardImageURL release];
	[responseDataCardImage release];
    [super dealloc];
}

@end
