//
//  NewCardViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewCardViewController.h"

@implementation NewCardViewController

@synthesize uploadTypeTable;
@synthesize imagePicker;
@synthesize uploadInfoButton;
@synthesize uploadingSpinner;
@synthesize creditInfo;
@synthesize pickedCardImage;
@synthesize managedObjectContext;
@synthesize delegate;
@synthesize connectionCreateCard;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

    // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		responseData = [[NSMutableData alloc] init];

		connectionToResponseMapping = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);		
	}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self showCreditsInfo];
	
	if ([SharedStore store].userSignedIn && [(NSArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser] count] > 0 && uploadInfoButton.hidden) {
		[self showUploadingInfo];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [SharedStore store].backColorForViews;
	uploadTypeTable.separatorColor = [SharedStore store].colorForTableSeperators;
	uploadTypeTable.backgroundColor = [UIColor clearColor];
	
}

#pragma mark -
#pragma mark ---------- UITABLEVIEW DEFAULT METHODS ----------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell...
	if (indexPath.row == 0) {
		cell.imageView.image = [UIImage imageNamed:@"camera.png"];
		cell.textLabel.text = @"Camera";		
		cell.detailTextLabel.text = @"Take pictures of your biz-cards";		
	}
	else if(indexPath.row == 1){
		cell.imageView.image = [UIImage imageNamed:@"flower.png"];
		cell.textLabel.text = @"Photo Library";
		cell.detailTextLabel.text = @"Search photo library";		
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	if (indexPath.row == 0) {
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
			imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentModalViewController:imagePicker animated:YES];		
		}
		else {
			Toast *toast = [[[Toast alloc] initWithMessage:@"Device doesn't have a camera."] autorelease];
			toast.frame = CGRectMake(20, 300, 280, 50);
			toast.borderOffset = CGSizeMake(2, 2);
			toast.tint = [UIColor orangeColor];
			toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
			[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];
		}
	}
	else if (indexPath.row == 1) {
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:imagePicker animated:YES];			
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	UIBarButtonItem *done = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(imagePickerDoneUsing)] autorelease];
	viewController.navigationItem.rightBarButtonItem = done;
}

#pragma mark -
#pragma mark ---------- IMAGEPICKER DELEGATE METHODS ----------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{	
	if(picker.allowsEditing)
		self.pickedCardImage = [info objectForKey:UIImagePickerControllerEditedImage];
	else
		self.pickedCardImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (pickedCardImage.size.width < 512 || pickedCardImage.size.height < 512) {
		Toast *toast = [[[Toast alloc] initWithMessage:@"Image must be at least 512x512 pixels."] autorelease];
		toast.frame = CGRectMake(20, 300, 280, 50);
		toast.borderOffset = CGSizeMake(2, 2);
		toast.tint = [UIColor orangeColor];
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
		[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];	
	}
	else {
		CGSize size;
		if (pickedCardImage.size.width > pickedCardImage.size.height) {
			size = CGSizeMake(800, 600);
		}
		else {
			size = CGSizeMake(600, 800);
		}
		
		self.pickedCardImage = [UIImage imageWithImage:self.pickedCardImage scaledProportionallyToSize:size];
		
		if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
			[self saveCard];
			[self dismissModalViewControllerAnimated:NO];
			[self presentModalViewController:imagePicker animated:NO];		
		}
		else if(imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
			[self performSelector:@selector(showUploadButton:) withObject:picker afterDelay:0.0];
		}		
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[picker.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)showUploadButton:(UIImagePickerController *)picker{
	UIActionSheet *uploadCard = [[[UIActionSheet alloc] initWithTitle: @"Use Image" delegate: self  cancelButtonTitle: @"Cancel" destructiveButtonTitle: @"Upload" otherButtonTitles: nil, NULL] autorelease];
	[uploadCard showInView:picker.view];
}

#pragma mark -
#pragma mark ---------- UIACTIONSHEET DELEGATE METHODS ----------

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0 && imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
	{			
	// User clicked on the Upload button	
		[self saveCard];		
	}
	else {
		self.pickedCardImage = nil;
	}

}

#pragma mark -
#pragma mark ---------- UIALERTVIEW DELEGATE METHODS ----------

//Asking User to buy credits
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		if ([self modalViewController] && ![SharedStore store].userOnBuyCreditView) {
			[self dismissModalViewControllerAnimated:NO];
		}
        if (![SharedStore store].userOnBuyCreditView) {
            BuyCreditsViewController *buyCreditsViewController = [[[BuyCreditsViewController alloc] init] autorelease];
            buyCreditsViewController.title = @"Buy Credits";
            [self presentModalViewController:buyCreditsViewController animated:YES];        
        }
        
	// Buy Credits through safari
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/sign_in?mobile=true",SERVER_STRING]]];
        
//		if ([self modalViewController]) {
//			[imagePicker.parentViewController dismissModalViewControllerAnimated:NO];
//		}
//
//		[delegate callShowPaypalWebView];
	}
}

-(void)saveCard{
	NSString *message;
	CGRect frame;	

	Toast *toast = [[[Toast alloc] init] autorelease];
	if ([SharedStore store].hostActive && [SharedStore store].userSignedIn) {
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;
		message = UPLOADMESSAGE;
		frame = CGRectMake(20, 300, 280, 50);
	}
	else {
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_LONG;
		message = UPLOADMESSAGENONET;
		frame = CGRectMake(20, 300, 280, 100);
	}
	toast.messageLabel.text = message;
	toast.frame = frame;
	toast.borderOffset = CGSizeMake(2, 2);
	toast.tint = [UIColor orangeColor];
	[toast showInView:self.imagePicker.view];				
	
	NSString *filename = [NSString stringWithFormat:@"iphone%d.jpg",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000]];
	[[SharedStore store] saveCard:pickedCardImage asFilename:filename];
	self.pickedCardImage = nil;

	[self showUploadingInfo];
	NSMutableArray *creatingCardsQueue = [[[NSMutableArray alloc] initWithArray:(NSMutableArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser]] autorelease];
	[creatingCardsQueue addObject:filename];
	[[SharedStore store].createCardsDictionary setValue:creatingCardsQueue forKey:[SharedStore store].currentUser];
	[[NSUserDefaults standardUserDefaults] setValue:[SharedStore store].createCardsDictionary forKey:@"createCardsDictionary"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if([creatingCardsQueue count] == 1 && [SharedStore store].hostActive && [SharedStore store].userSignedIn){
		[self createCard];
	}	
}

#pragma mark -
#pragma mark ---------- ACCOUNTVIEWCONTROLLERDELEGATE METHODS ----------

-(void)CancelUrlConnections{
	[delegate cancelDashboardUrlConnections];
	if (connectionCreateCard != nil) {
		[connectionCreateCard cancel];
		self.connectionCreateCard = nil;
	}
	[SharedStore store].uploadingCards = NO;
}

-(void)refreshUserCredit{
	[self showCreditsInfo];
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)createCard{
	if (self.connectionCreateCard != nil) {
		return;
	}
	NSMutableArray *creatingCardsQueue = [[[NSMutableArray axlloc] initWithArray:(NSMutableArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser]] autorelease];
	NSString *fileName = [creatingCardsQueue objectAtIndex:0];
	NSData *imageData = [[SharedStore store] imageDataForFilename:fileName];
	
	NSString *boundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat: @"%@/cards.json",SERVER_STRING]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setHTTPMethod:@"POST"];
	
	[urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	NSMutableData *postData = [NSMutableData data];
	NSString *auth_token = [[SharedStore store].userDictionary valueForKey:@"auth_token"];
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"authenticity_token\"\r\n\r\n%@\r\n", boundary,auth_token]  dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"source\"\r\n\r\n%@\r\n", boundary, @"iphone"]  dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];	
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]  dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"Filedata\"; filename=\"%@\"\r\n\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:imageData];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[urlRequest setHTTPBody:postData];
	
	connectionCreateCard = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionCreateCard) {
		[SharedStore store].uploadingCards = YES;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
    [self showUploadingInfo];
}

#pragma mark -
#pragma mark ---------- NSURLCONNECTION DELEGATE METHODS ----------

//Connection #1 (www/cards.json)[POST-multipart] for creating new card

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	if (connection == connectionCreateCard) {
		NSMutableData *tempData = [NSMutableData data];
		[tempData setLength:0];
		CFDictionaryAddValue(connectionToResponseMapping, connection, tempData);		
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (connection == connectionCreateCard) {
		NSMutableData * tempData = (NSMutableData *)CFDictionaryGetValue(connectionToResponseMapping, connection);
		[tempData appendData:data];		
	}
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	if (connection == connectionCreateCard) {
		Toast *toast = [[[Toast alloc] initWithMessage:@"An error occured while trying to perform this action"] autorelease];
		toast.frame = CGRectMake(20, 300, 280, 50);
		toast.borderOffset = CGSizeMake(2, 2);
		toast.tint = [UIColor orangeColor];
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
		[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];
		
		NSMutableArray *creatingCardsQueue = [[[NSMutableArray alloc] init] autorelease];
		
		[self showUploadingInfo];
		CFDictionaryRemoveValue(connectionToResponseMapping, connection);
		[creatingCardsQueue setArray:(NSArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser]];
		NSString *filename = [creatingCardsQueue objectAtIndex:0];
		[[SharedStore store] removeImageFromQueueWithFilename:filename];
			
		[creatingCardsQueue setArray:(NSArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser]];
		if ([creatingCardsQueue count] > 0) {
			[self createCard];
		}
		
		[SharedStore store].uploadingCards = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		self.connectionCreateCard = nil;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (connection == connectionCreateCard) {
		
	//Response --> {"card":{id:1,,,,,},"user_credits":11} OR -->{"card":".UPLOAD FAILED..."}
		NSString *responseString = [[[NSString alloc] initWithData:(NSData *)CFDictionaryGetValue(connectionToResponseMapping, connection) encoding:NSUTF8StringEncoding] autorelease];
		CFDictionaryRemoveValue(connectionToResponseMapping, connection);
		self.connectionCreateCard = nil;
		
		NSRange textUserCreditRange =[[responseString lowercaseString] rangeOfString:[[NSString stringWithString:@"user_credits"] lowercaseString]];
		if(textUserCreditRange.location != NSNotFound){
		//Card uploaded successfully
			NSObject *user_credits = [[responseString JSONValue] valueForKey:@"user_credits"];
			NSDictionary *cardDictionary = [[responseString JSONValue] objectForKey:@"card"];
			if (user_credits) {
				[[SharedStore store].userDictionary setValue:user_credits forKey:@"credit"];
				
				[[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].userDictionary forKey:[SharedStore store].currentUser];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[self showCreditsInfo];
			}
			
			if (cardDictionary) {
				//Call DashboardViewController to add card into DB
				[delegate createNewCard:cardDictionary];				
			}
		}
		else {
		//Upload Failed
			//NSString *errorMessage = [[responseString JSONValue] objectForKey:@"card"];
			
			Toast *toast = [[[Toast alloc] initWithMessage:@"An error occured while uploading image."] autorelease];
			toast.frame = CGRectMake(20, 300, 280, 50);
			toast.borderOffset = CGSizeMake(2, 2);
			toast.tint = [UIColor orangeColor];
			toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
			[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];

			NSMutableArray *creatingCardsQueue = [[[NSMutableArray alloc] initWithArray:(NSMutableArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser]] autorelease];
			NSString *filename = [creatingCardsQueue objectAtIndex:0];
			[[SharedStore store] removeImageFromQueueWithFilename:filename];
		}

		[self showUploadingInfo];
				
		NSMutableArray *creatingCardsQueue = [[[NSMutableArray alloc] initWithArray:(NSMutableArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser]] autorelease];
		if ([creatingCardsQueue count] > 0) {
			[self createCard];
		}
		else if ([creatingCardsQueue count] == 0 && [[[SharedStore store].userDictionary valueForKey:@"credit"] intValue] == 0) {
			[self askToBuyCredits];
		}
	}	

	[SharedStore store].uploadingCards = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)imagePickerDoneUsing{
	[imagePicker.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)showUploadingInfo{
    NSInteger numUploadingCards = [(NSArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser] count];
	if ([SharedStore store].hostActive && numUploadingCards > 0) {
		if (numUploadingCards == 1) {
			uploadInfoButton.titleLabel.text = [NSString stringWithFormat:@"Uploading %d card ",numUploadingCards];			
		}else {
			uploadInfoButton.titleLabel.text = [NSString stringWithFormat:@"Uploading %d cards ",numUploadingCards];
		}
		
		uploadInfoButton.hidden = NO;
		[uploadingSpinner startAnimating];		
	}
	else {
		uploadInfoButton.hidden = YES;
		[uploadingSpinner stopAnimating];
	}
}

-(void)showCreditsInfo{
	NSInteger credits = [[[SharedStore store].userDictionary valueForKey:@"credit"] intValue];
	if (credits > 1) {
		creditInfo.text = [NSString stringWithFormat:@"%d credits remaining",credits];			
	}	
	else {
		creditInfo.text = [NSString stringWithFormat:@"%d credit remaining",credits];					
	}


}

-(void)askToBuyCredits{
	UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
	[alert setTitle:@"No credits!"];
	[alert setMessage:@"You have no credits left."];
	[alert addButtonWithTitle:@"Buy Now"];
	[alert addButtonWithTitle:@"Later"];
	[alert setDelegate:self];
    [alert setTag:1];
	[alert show];
}


#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[uploadTypeTable release];
	[imagePicker release];
	[uploadInfoButton release];
	[uploadingSpinner release];
	[creditInfo release];
	[pickedCardImage release];
	[managedObjectContext release];
	[responseData release];
	
	CFRelease(connectionToResponseMapping);
    [super dealloc];
}


@end
