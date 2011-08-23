//
//  BuyCreditsViewController.m
//  BizCardArmy
//
//  Created by Samesh Swongamika on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BuyCreditsViewController.h"


@implementation BuyCreditsViewController
@synthesize navBar, creditsBox;
@synthesize button_package1, button_package2, button_package3, button_package4;
@synthesize productIdentifierList, productDetailsList;

#pragma mark - View lifecycle
#pragma mark -
#pragma mark ---------- SELF METHODS ----------

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [SharedStore store].userOnBuyCreditView = YES;
    
    productDetailsList    = [[NSMutableArray alloc] init];  
    productIdentifierList = [[NSMutableArray alloc] init];
    BCA_product_id = [[NSMutableString alloc] init];
    
    self.view.backgroundColor = [SharedStore store].backColorForViews;
    navBar.tintColor = [SharedStore store].navigationBarColor;
    [[SharedStore store] setRoundedBorder:[creditsBox layer]];
    [button_package1 setImage:[UIImage imageNamed:@"checked_box.png"] forState:UIControlStateSelected];
    [button_package2 setImage:[UIImage imageNamed:@"checked_box.png"] forState:UIControlStateSelected];
    [button_package3 setImage:[UIImage imageNamed:@"checked_box.png"] forState:UIControlStateSelected];
    [button_package4 setImage:[UIImage imageNamed:@"checked_box.png"] forState:UIControlStateSelected];
    [self checkboxButton:button_package1];
    
    [super viewDidLoad];
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)goBack:(id)sender{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
    [SharedStore store].userOnBuyCreditView = NO;
}

- (IBAction)checkboxButton:(UIButton *)button{
    
    for (UIButton *but in [self.creditsBox subviews]) {
        if ([but isKindOfClass:[UIButton class]] && ![but isEqual:button]) {
            [but setSelected:NO];
        }
    }
    if (!button.selected) {
        button.selected = !button.selected;
    }
    [BCA_product_id setString:[NSString stringWithFormat:@"%@%d", kBCAProductId, button.tag]];
} 

-(IBAction)buyCredits{
    //[self requestCreditsFromStore];
    
    if  ([self canMakePurchases]){
        [[SharedStore store].overlayView setFrame:CGRectMake(0, 0, 320, 460)];
        [[SharedStore store].overlayView showInView:self.view withActivityIndicator:YES];
        [self purchaseCredits];
    }    
}

#pragma mark -
#pragma mark ---------- SKPRODUCTSREQUEST DELEGATE METHODS ----------

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [productDetailsList addObjectsFromArray: response.products];
}

-(void)requestDidFinish:(SKRequest *)request
{
    [request release];
}  

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error  
{  
    NSLog(@"Failed to connect with error: %@", [error localizedDescription]);  
} 



#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

- (void)requestCreditsFromStore{
    [productIdentifierList addObject:[NSString stringWithFormat:@"com.sprout.bizcardarmy.credits.package1"]];
    [productIdentifierList addObject:[NSString stringWithFormat:@"com.sprout.bizcardarmy.credits.package2"]]; 
    [productIdentifierList addObject:[NSString stringWithFormat:@"com.sprout.bizcardarmy.credits.package3"]]; 
    [productIdentifierList addObject:[NSString stringWithFormat:@"com.sprout.bizcardarmy.credits.package4"]]; 
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifierList]];
    
    request.delegate = self;
    [request start];
}

// call this before making a purchase
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

// kick off the upgrade transaction
- (void)purchaseCredits
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:[NSString stringWithFormat:@"%@", BCA_product_id]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark -
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [navBar release];
    [creditsBox release];
    [button_package1 release];
    [button_package2 release];
    [button_package3 release];
    [button_package4 release];
    [productIdentifierList release];  
    [productDetailsList release];
    [BCA_product_id release];
    
    [super dealloc];
}

@end
