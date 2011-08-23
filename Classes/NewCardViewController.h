//
//  NewCardViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "SharedStore.h"
#import "Toast.h"
#import "UIImage+Extras.h"
#import "PaypalWebViewController.h"
#import "AccountViewController.h"

#define UPLOADMESSAGE @"Uploading card"
#define	UPLOADMESSAGENONET @"Couldn't upload due to lack of connection. It has been saved and will be uploaded later automatically."

@protocol NewCardViewControllerDelegate;

@interface NewCardViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, AccountViewControllerDelegate> {
	IBOutlet UITableView *uploadTypeTable;
	IBOutlet UIImagePickerController *imagePicker; //image picker for camera and photo library
	IBOutlet UIButton *uploadInfoButton;
	IBOutlet UIActivityIndicatorView *uploadingSpinner;
	IBOutlet UILabel *creditInfo;
	
	UIImage *pickedCardImage;

	NSManagedObjectContext *managedObjectContext;
		
	CFMutableDictionaryRef connectionToResponseMapping;
	NSURLConnection *connectionCreateCard;
	NSMutableData *responseData;		/* Response Data For newly created Card */

	id <NewCardViewControllerDelegate> delegate;	
}

//---------  PROPERTIES ---------
@property(nonatomic, retain) IBOutlet UITableView *uploadTypeTable;
@property(nonatomic, retain) IBOutlet UIImagePickerController *imagePicker;
@property(nonatomic, retain) IBOutlet UIButton *uploadInfoButton;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *uploadingSpinner;
@property(nonatomic, retain) IBOutlet UILabel *creditInfo;
@property(nonatomic, retain) UIImage *pickedCardImage;
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) NSURLConnection *connectionCreateCard;
@property(nonatomic, assign) id <NewCardViewControllerDelegate> delegate;

//---------  URLCONNECTION METHODS ---------
-(void)createCard;
-(void)saveCard;

//---------  CUSTOM METHODS ---------
-(void)imagePickerDoneUsing;
-(void)showUploadingInfo;
-(void)showCreditsInfo;
-(void)askToBuyCredits;

@end

//--------- PROTOCOLS --------- 
@protocol NewCardViewControllerDelegate

@optional
	-(void)createNewCard:(NSDictionary *)cardDictionary;
	-(void)cancelDashboardUrlConnections;
	-(void)callShowPaypalWebView;
@end

