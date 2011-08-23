//
//  BuyCreditsViewController.h
//  BizCardArmy
//
//  Created by Samesh Swongamika on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#define kBCAProductId @"com.sprout.bizcardarmy.credits.package"
#define KBCAFullPackage @"com.sprout.bizcardarmy.credits.package4"
#define KBCAStandardPackage @"com.sprout.bizcardarmy.credits.package3"
#define KBCAExtendedPackage @"com.sprout.bizcardarmy.credits.package2"
#define KBCABasicPackage @"com.sprout.bizcardarmy.credits.package1"
#define KBCAFullPackage_price 75
#define KBCAStandardPackage_price 25
#define KBCAExtendedPackage_price 10
#define KBCABasicPackage_price 5
#define KBCAFullPackage_credits 400
#define KBCAStandardPackage_credits 100
#define KBCAExtendedPackage_credits 35
#define KBCABasicPackage_credits 15

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SharedStore.h"
#import "AccountViewController.h"


@interface BuyCreditsViewController : UIViewController < SKProductsRequestDelegate> {
    
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIView *creditsBox;
    IBOutlet UIButton *button_package1, *button_package2, *button_package3, *button_package4;
    
    NSMutableArray *productIdentifierList;  
    NSMutableArray *productDetailsList;
    NSMutableString *BCA_product_id;
}

//---------  PROPERTIES --------- 
@property(nonatomic, retain) UINavigationBar *navBar;
@property(nonatomic, retain) UIView *creditsBox;
@property(nonatomic, retain) UIButton *button_package1, *button_package2, *button_package3, *button_package4;
@property(nonatomic, retain) NSMutableArray *productIdentifierList;  
@property(nonatomic, retain) NSMutableArray *productDetailsList;

//---------  IBACTION METHODS --------- 
-(IBAction)checkboxButton:(UIButton *)button;
-(IBAction)buyCredits;


//---------  CUSTOM METHODS ---------
- (void)requestCreditsFromStore;
- (BOOL)canMakePurchases;
- (void)purchaseCredits;

@end
