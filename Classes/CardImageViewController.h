//
//  CardImageViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "SharedStore.h"

@interface CardImageViewController : UIViewController {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIActivityIndicatorView *imageLoadingSpinner;
	
	NSString *cardImageURL;
	
	NSMutableData *responseDataCardImage;
}

//---------  PROPERTIES --------- 
@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *imageLoadingSpinner;
@property(nonatomic, retain) NSString *cardImageURL;

//---------  SELF METHODS --------- 
-(id) initWithCardImageUR:(NSString *)_cardImageURL;

@end
