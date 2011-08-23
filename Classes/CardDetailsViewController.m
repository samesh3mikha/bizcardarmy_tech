//
//  CardDetailsViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CardDetailsViewController.h"


@implementation CardDetailsViewController

@synthesize scrollView;
@synthesize cardDetailsTable;
@synthesize cardImageButton;
@synthesize cardEventToolBar;
@synthesize nameLabel;
@synthesize detailInfoLabel;
@synthesize statusImageView;
@synthesize overlayView;
@synthesize cardDetailKeys;
@synthesize cardDetailsValue;
@synthesize cardUpdateDictionary;
@synthesize managedObjectContext;
@synthesize  connectionUpdateCard, connectionDisputeCard;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

-(id) initWithCard:(Card *)_card cardImage:(UIImage *)_cardImage{
	if((self = [super init])){
		card = _card;
		cardImage = _cardImage;
		if ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"]) {
			self.cardDetailKeys = [[[NSMutableArray alloc] initWithObjects:@"Name",@"Company",@"Post",@"Email",@"Website",@"Phone",@"Mobile",@"Fax",@"Address1",@"Address2",@"City",@"State",@"Country",@"Zip",nil] autorelease];			
		}
		else {
			self.cardDetailKeys = [[[NSMutableArray alloc] initWithObjects:@"N/A info",nil] autorelease];
		}

		changesMade = NO;
		self.hidesBottomBarWhenPushed = YES;
		
		overlayView = [[OverlayView alloc] init];
	}
	return self;
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 [super viewDidLoad];
	 responseDataUpdateCard = [[NSMutableData alloc] init];
	 responseDataDisputeCard = [[NSMutableData alloc] init];
	 cardUpdateDictionary = [[NSMutableDictionary alloc] init];

	 self.view.backgroundColor = [SharedStore store].backColorForViews;
	 cardDetailsTable.separatorColor = [SharedStore store].colorForTableSeperators;
	 cardDetailsTable.backgroundColor = [UIColor clearColor];
	 [[SharedStore store] setRoundedBorder:[cardImageButton layer]];
	 
	 if (cardImage) {
		 [cardImageButton setBackgroundImage:cardImage forState:UIControlStateNormal];
	 }
	 if (card.status) {
		 statusImageView.image = [[SharedStore store] imageForStatus:card.status];

		 if ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"]) {
			 //Add alert button if no internet
			 self.navigationItem.rightBarButtonItem = self.editButtonItem;
			 cardEventToolBar.hidden = NO;
		 }
		 else {
			 cardEventToolBar.hidden = YES;
		 }
	 }
	 [self displayCardInfo];
	 [self adjustScrollViewContent];
 }

#pragma mark -
#pragma mark ---------- UITABLEVIEW DELEGATE METHODS ----------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	NSInteger numSections;
	if ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"]) {
		numSections = 2;
	}
	else {
		numSections = 1;	
	}

    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger numRows;
	if ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"]) {
		if (section == 0) {
			numRows = [cardDetailKeys count];
		}
		else if (section == 1) {
			numRows = 1;
		}
	}
	else {
		numRows = 1;		
	}

	return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
	EditFieldCell *cell = (EditFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    if (cell == nil){  
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditFieldCell" owner:nil options:nil];  
        for(id currentObject in topLevelObjects) {  
            if([currentObject isKindOfClass:[EditFieldCell class]]) {  
                cell = (EditFieldCell *) currentObject;  
                break;  
            }  
        }  
    }  
	
	// Next line is very important ...   
    // you have to set the delegate from the cell back to this class  
    [cell setDelegate:self];
	
	if ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"]) {
		if (indexPath.section == 0) {
			cell.fieldLabel.text = [NSString stringWithFormat:@"%@",[cardDetailKeys objectAtIndex:indexPath.row]];
			if (card) {
				NSString *value = [self cardValueForField:[cardDetailKeys objectAtIndex:indexPath.row]];
				if (![value isEqualToString:@""]) {
					cell.textField.text = value;
				}
				else {
					cell.textField.text = @"N/A";
				}
			}
			
			if (!self.editing) {
				cell.textField.enabled = NO;
			}
			else {
				if ([cell.textField.text isEqualToString:@"N/A"]) {
					cell.textField.text = @"";
					cell.textField.placeholder = @"N/A";
				}
				cell.textField.enabled = YES;
			}			
		}
		else {
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			if ([card.dispute_status isEqualToString:@"undisputed"]) {
				cell.textLabel.text = @"Result not acceptable?";
			}
			else if ([card.dispute_status isEqualToString:@"disputed"]) {
				cell.textLabel.text = @"This card is currently being reviewed";				
			}
			else if ([card.dispute_status isEqualToString:@"resolved"]) {
				cell.textLabel.text = @"This card has been reviewed by senior transcribers";				
			}			
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		
			//Stop textfield from responding
			cell.textField.hidden = YES;
			cell.fieldLabel.hidden = YES;
		}
	}
	else {
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.text = @"No information available";

		//Stop textfield from responding
		cell.textField.enabled = NO;
	}

	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && indexPath.row == 0) {
		if ([card.dispute_status isEqualToString:@"undisputed"]) {
			return indexPath;			
		}
	}
	return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 1 && indexPath.row == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		if ([SharedStore store].hostActive && [SharedStore store].userSignedIn) {
			UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
			[alert setTitle:@"Result not acceptable"];
			[alert setMessage:@"If you are not satisfied with the result, our senior transcribers will correct the mistakes. Are you sure to mark this card as not acceptable?"];
			[alert addButtonWithTitle:@"Yes"];
			[alert addButtonWithTitle:@"No"];
			[alert setDelegate:self];
			alert.tag = 1;
			[alert show];
		}
		else {
			Toast *toast = [[[Toast alloc] initWithMessage:@"Could not connect to the server"] autorelease];
			toast.frame = CGRectMake(20, 300, 280, 50);
			toast.borderOffset = CGSizeMake(2, 2);
			toast.tint = [UIColor orangeColor];
			toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
			[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];	
		}

	}
}
	
#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)showLargeCard:(id)sender{
	CardImageViewController *cardImageViewController = [[[CardImageViewController alloc] initWithCardImageUR:card.image_url_medium] autorelease];
	cardImageViewController.title = @"Card";
	[self.navigationController pushViewController:cardImageViewController animated:YES];
}

-(IBAction)addressBookButtonClicked:(id)sender{
	NSInteger person_id = [card.addressbookID intValue];
	if (person_id > 0) {
		// Fetch the address book
		ABAddressBookRef addressBook = ABAddressBookCreate();

		// Search for the person 
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, person_id); ///*person_id*/-1);

		// Display PersonViewController
		if (person != nil) {
			ABPersonViewController *picker = [[[ABPersonViewController alloc] init] autorelease];
			picker.personViewDelegate = self;
			picker.displayedPerson = person;
			// Allow users to edit the person’s information
			picker.allowsEditing = NO;
			[self.navigationController pushViewController:picker animated:YES];
		}
		// Could not find in contacts
		else{
			Toast *toast = [[[Toast alloc] initWithMessage:@"No information found on contacts"] autorelease];
			toast.frame = CGRectMake(20, 300, 280, 50);
			toast.borderOffset = CGSizeMake(2, 2);
			toast.tint = [UIColor orangeColor];
			toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
			[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];	
		}
		CFRelease(addressBook);		
	}
}

-(IBAction)deleteCardButtonClicked:(id)sender{	
	UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
	[alert setTitle:@"Delete card!"];
	[alert setMessage:@"Are you sure you want to delete this card?"];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setDelegate:self];
	alert.tag = 2;
	[alert show];
}

#pragma mark -
#pragma mark ---------- ABPEOPLEPICKERNAVCONTROLLER DELEGATE METHODS ----------

// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue{
	return NO;
} 


#pragma mark -
#pragma mark ---------- UIALERTVIEW DELEGATE METHODS ----------

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {
		if (buttonIndex == 0) {
			[self sendDisputeRequest];	
		}
	}
	// Delete Card
	if (alertView.tag == 2) {
		if (buttonIndex == 0) {
			[self deleteCardFromDB];
		}
	}
}

#pragma mark -
#pragma mark ---------- EDIT_MODE DELEGATE METHODS ----------

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
	if (![SharedStore store].hostActive || ![SharedStore store].userSignedIn) {
		Toast *toast = [[[Toast alloc] initWithMessage:@"Cannot edit at this time due to connection problem. Please try later."] autorelease];
		toast.frame = CGRectMake(20, 300, 280, 80);
		toast.borderOffset = CGSizeMake(2, 2);
		toast.tint = [UIColor orangeColor];
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
		[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];
		return;
	}
	[super setEditing: editing animated: animated];
	if (self.editing) {
		[cardDetailKeys removeObjectAtIndex:0];
		[cardDetailKeys insertObject:@"FirstName" atIndex:0];
		[cardDetailKeys insertObject:@"MiddleName" atIndex:1];
		[cardDetailKeys insertObject:@"LastName" atIndex:2];	

		[self.cardDetailsTable reloadData];		
	}
	else {
		NSString *updateParam;
		NSString *encodedUpdateParam;
		NSMutableString *updateParamaterString = [[[NSMutableString alloc] initWithString:@""] autorelease];
		[cardUpdateDictionary removeAllObjects];
		
		for (int i=0; i<[cardDetailKeys count]; i++) {
			EditFieldCell *cell = (EditFieldCell *)[self.cardDetailsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			
			updateParam = [NSString stringWithFormat:@"card[%@]=%@", [[SharedStore store] swapCardFieldAndLabel:cell.fieldLabel.text] , cell.textField.text];
			encodedUpdateParam = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)updateParam,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
			[updateParamaterString appendFormat:@"%@",encodedUpdateParam];
			if (i<[cardDetailKeys count] -1 ) {
				[updateParamaterString appendString:@"&"];
			}
			[cardUpdateDictionary setObject:cell.textField.text forKey:cell.fieldLabel.text];
			[encodedUpdateParam release];
		}
		[self updateCardInWebServer:updateParamaterString];			
		
		[cardDetailKeys removeObjectAtIndex:0];
		[cardDetailKeys removeObjectAtIndex:0];
		[cardDetailKeys removeObjectAtIndex:0];
		[cardDetailKeys insertObject:@"Name" atIndex:0];		
	}

	[self adjustScrollViewContent];
}


#pragma mark -
#pragma mark ---------- EDITFIELDCELL DELEGATE METHODS ----------

- (void)relocateScrollView:(CGRect)cellFrame{
	NSInteger contentHeight = 288 + ([cardDetailKeys count] * 45);
	scrollView.contentSize = CGSizeMake(320, contentHeight);

	CGRect scrollBounds = scrollView.bounds;
	if (cellFrame.origin.y - scrollBounds.origin.y > 60) {
		scrollBounds.origin.y = scrollBounds.origin.y + (cellFrame.origin.y - scrollBounds.origin.y) - 60;
		[scrollView scrollRectToVisible:scrollBounds animated:YES];
	}
}

-(void)shrinkScrollContent{
	[self adjustScrollViewContent];
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)updateCardInWebServer:(NSString *)updateParam{
	NSString *auth_token = [[SharedStore store].userDictionary valueForKey:@"auth_token"];
	NSString *encodedAuthToken = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)auth_token,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *content = [NSString stringWithFormat: @"authenticity_token=%@&%@",encodedAuthToken,updateParam];
	[encodedAuthToken release];
	
	NSString *connectionString = [NSString stringWithFormat:@"%@/cards/%d.json", SERVER_STRING, [card.card_id intValue]];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"PUT"];
	[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
	connectionUpdateCard = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionUpdateCard) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		self.navigationItem.rightBarButtonItem.enabled = NO;

		[overlayView setFrame:self.view.frame];
		[overlayView showInView:self.view withActivityIndicator:YES];
	}			
}

-(void)sendDisputeRequest{
	NSString *connectionString = [NSString stringWithFormat:@"%@/cards/dispute.json?id=%d", SERVER_STRING,[card.card_id intValue]];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"GET"];
	connectionDisputeCard = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionDisputeCard) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;		
		
		[overlayView setFrame:self.tabBarController.view.frame];
		[overlayView showInView:self.tabBarController.view withActivityIndicator:YES];
	}		
}

#pragma mark -
#pragma mark ---------- NSURLCONNECTION DELEGATE METHODS ----------

//Connection #1 (www/cards.json)[DELETE] for deleting card

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	if (connection == connectionUpdateCard) {
		[responseDataUpdateCard setLength:0];
	}
	else if (connection == connectionDisputeCard) {
		[responseDataDisputeCard setLength:0];
	}

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (connection == connectionUpdateCard) {
		[responseDataUpdateCard appendData:data];
	}
	else if (connection == connectionDisputeCard) {
		[responseDataDisputeCard appendData:data];
	}
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	Toast *toast = [[[Toast alloc] initWithMessage:@"An error occured while trying to perform this action"] autorelease];
	toast.frame = CGRectMake(20, 300, 280, 50);
	toast.borderOffset = CGSizeMake(2, 2);
	toast.tint = [UIColor orangeColor];
	toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
	[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];

	[overlayView hide];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (connection == connectionUpdateCard) {
		self.connectionUpdateCard = nil;
	}
	else if (connection == connectionDisputeCard) {
		self.connectionDisputeCard = nil;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	if (connection == connectionUpdateCard) {
	// Response --> {"card":{"updated_at":"2011-01-10T09:21:45Z","id":456}}
		NSString *responseString = [[[NSString alloc] initWithData:responseDataUpdateCard encoding:NSUTF8StringEncoding] autorelease];
		NSDictionary *cardDictionary = [[responseString JSONValue] valueForKey:@"card"];
		
		if ([[cardDictionary  objectForKey:@"updated_at"] isKindOfClass:[NSString class]]){
			[cardUpdateDictionary setObject:[cardDictionary  objectForKey:@"updated_at"] forKey:@"updated_at"];
			[self updateCardInIphone];
		}
		else {
			Toast *toast = [[[Toast alloc] initWithMessage:@"An error occured while trying to perform this action"] autorelease];
			toast.frame = CGRectMake(20, 300, 280, 50);
			toast.borderOffset = CGSizeMake(2, 2);
			toast.tint = [UIColor orangeColor];
			toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
			[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];
		}
		self.connectionUpdateCard =nil;
	}
	else if (connection == connectionDisputeCard) {
	// Response --> {"card":677}
		
		if (card) {
			card.dispute_status = @"disputed";
			[self.cardDetailsTable reloadData];			
		}
		self.connectionDisputeCard = nil;
	}
	
	[overlayView hide];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)displayCardInfo{
	
	if ([card.first_name length]>0 || [card.middle_name length]>0 || [card.last_name length]>0) {
		nameLabel.text = [[SharedStore store] fullNameForFirstWord:card.first_name secondWord:card.middle_name thirdWord:card.last_name];
	}
	else {
		nameLabel.text = @"Untitled";
	}
	if ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"]) {
		if ([card.company length]>0) {
			detailInfoLabel.text = card.company;
		}
		else {
			detailInfoLabel.text = @"N/A";
		}			
	}
	else {
		detailInfoLabel.text = [NSString stringWithFormat:@"Uploaded %@ ago ",[[SharedStore store] timeDiffFromDate:card.created_at]];
	}
}

-(void)adjustScrollViewContent{
	NSInteger contentHeight = 108 + ([cardDetailKeys count] * 45 + 80);
	scrollView.contentSize = CGSizeMake(320, contentHeight);	
}

-(NSString *)cardValueForField:(NSString *)field{
	NSString *value;
	
	if ([field isEqualToString:@"Name"]) {
		if ([card.first_name length] > 0 || [card.middle_name length] > 0 || [card.last_name length] > 0) {
			value = [[SharedStore store] fullNameForFirstWord:card.first_name secondWord:card.middle_name thirdWord:card.last_name];
		}
		else {
			value = @"N/A";
		}
	}
	else if ([field isEqualToString:@"FirstName"]) {
		value = [card.first_name length]>0 ? [NSString stringWithFormat:@"%@",card.first_name] : @"N/A";
	}
	else if ([field isEqualToString:@"MiddleName"]) {
		value = [card.middle_name length]>0 ? [NSString stringWithFormat:@"%@",card.middle_name] : @"N/A";
	}
	else if ([field isEqualToString:@"LastName"]) {
		value = [card.last_name length]>0 ? [NSString stringWithFormat:@"%@",card.last_name] : @"N/A";
	}
	else if ([field isEqualToString:@"Company"]) {
		value = [card.company length]>0 ? [NSString stringWithFormat:@"%@",card.company] : @"N/A";
	}
	else if ([field isEqualToString:@"Post"]) {
		value = [card.job_title length]>0 ? [NSString stringWithFormat:@"%@",card.job_title] : @"N/A";
	}
	else if ([field isEqualToString:@"Email"]) {
		value = [card.email length]>0 ? [NSString stringWithFormat:@"%@",card.email] : @"N/A";
	}
	else if ([field isEqualToString:@"Website"]) {
		value = [card.website length]>0 ? [NSString stringWithFormat:@"%@",card.website] : @"N/A";
	}
	else if ([field isEqualToString:@"Phone"]) {
		value = [card.phone length]>0 ? [NSString stringWithFormat:@"%@",card.phone] : @"N/A";
	}
	else if ([field isEqualToString:@"Mobile"]) {
		value = [card.mobile length]>0 ? [NSString stringWithFormat:@"%@",card.mobile] : @"N/A";
	}
	else if ([field isEqualToString:@"Fax"]) {
		value = [card.fax length]>0 ? [NSString stringWithFormat:@"%@",card.fax] : @"N/A";
	}
	else if ([field isEqualToString:@"Address1"]) {
		value = [card.address1 length]>0 ? [NSString stringWithFormat:@"%@",card.address1] : @"N/A";
	}
	else if ([field isEqualToString:@"Address2"]) {
		value = [card.address2 length]>0 ? [NSString stringWithFormat:@"%@",card.address2] : @"N/A";
	}
	else if ([field isEqualToString:@"City"]) {
		value = [card.city length]>0 ? [NSString stringWithFormat:@"%@",card.city] : @"N/A";
	}
	else if ([field isEqualToString:@"State"]) {
		value = [card.state length]>0 ? [NSString stringWithFormat:@"%@",card.state] : @"N/A";
	}
	else if ([field isEqualToString:@"Country"]) {
		value = [card.country length]>0 ? [NSString stringWithFormat:@"%@",card.country] : @"N/A";
	}
	else if ([field isEqualToString:@"Zip"]) {
		value = [card.zip length]>0 ? [NSString stringWithFormat:@"%@",card.zip] : @"N/A";
	}
	
	return value;
}

-(void)deleteCardFromDB{
	if (!card) {
		return;
	}
	
	BizCardArmyAppDelegate *appDelegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
	DashboardViewController *dashboardVC = (DashboardViewController *)[[[appDelegate.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
	if (dashboardVC) {
		[dashboardVC deleteCard:card];
	}
		
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)updateCardInIphone{
	if (!card) {
		return;
	}
	if ([cardUpdateDictionary valueForKey:@"FirstName"]) {
		card.first_name = [cardUpdateDictionary valueForKey:@"FirstName"];
	}
	if ([cardUpdateDictionary valueForKey:@"MiddleName"]) {
		card.middle_name = [cardUpdateDictionary valueForKey:@"MiddleName"];
	}
	if ([[cardUpdateDictionary objectForKey:@"LastName"] isKindOfClass:[NSString class]]) {
		card.last_name = [cardUpdateDictionary valueForKey:@"LastName"];
	}
	if ([[cardUpdateDictionary objectForKey:@"Company"] isKindOfClass:[NSString class]]) {
		card.company = [cardUpdateDictionary valueForKey:@"Company"];
	}
	if ([cardUpdateDictionary valueForKey:@"Post"]) {
		card.job_title = [cardUpdateDictionary valueForKey:@"Post"];
	}
	if ([cardUpdateDictionary valueForKey:@"Email"]) {
		card.email = [cardUpdateDictionary valueForKey:@"Email"];
	}
	if ([cardUpdateDictionary valueForKey:@"Website"]) {
		card.website = [cardUpdateDictionary valueForKey:@"Website"];
	}
	if ([cardUpdateDictionary valueForKey:@"Phone"]) {
		card.phone = [cardUpdateDictionary valueForKey:@"Phone"];
	}
	if ([cardUpdateDictionary valueForKey:@"Mobile"]) {
		card.mobile = [cardUpdateDictionary valueForKey:@"Mobile"];
	}
	if ([cardUpdateDictionary valueForKey:@"Fax"]) {
		card.fax = [cardUpdateDictionary valueForKey:@"Fax"];
	}	
	if ([cardUpdateDictionary valueForKey:@"Address1"]) {
		card.address1 = [cardUpdateDictionary valueForKey:@"Address1"];
	}
	if ([cardUpdateDictionary valueForKey:@"Address2"]) {
		card.address2 = [cardUpdateDictionary valueForKey:@"Address2"];
	}
	if ([cardUpdateDictionary valueForKey:@"City"]) {
		card.city = [cardUpdateDictionary valueForKey:@"City"];
	}
	if ([cardUpdateDictionary valueForKey:@"State"]) {
		card.state = [cardUpdateDictionary valueForKey:@"State"];
	}
	if ([cardUpdateDictionary valueForKey:@"Country"]) {
		card.country = [cardUpdateDictionary valueForKey:@"Country"];
	}
	if ([cardUpdateDictionary valueForKey:@"Zip"]) {
		card.zip = [cardUpdateDictionary valueForKey:@"Zip"];
	}
	card.updated_at = [[SharedStore store] dateFromString:[cardUpdateDictionary  valueForKey:@"updated_at"]];
		
	BizCardArmyAppDelegate *appDelegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
	DashboardViewController *dashboardVC = (DashboardViewController *)[[[appDelegate.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];
	if (dashboardVC) {
		[dashboardVC updateDB];
	}
	
	[self displayCardInfo];
	[self.cardDetailsTable reloadData];
	[[SharedStore store] updateAddressBook:[card.addressbookID intValue] usingDictionary:cardUpdateDictionary];				
}  

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[scrollView release];
	[cardDetailsTable release];
	[cardImageButton release];
	[cardEventToolBar release];
	[nameLabel release];
	[detailInfoLabel release];
	[statusImageView release];
	[overlayView release];
	[cardDetailKeys release];
	[cardUpdateDictionary release];
	[managedObjectContext release];
	[responseDataUpdateCard release];
	[responseDataDisputeCard release];
	if (self.connectionUpdateCard != nil) {
		[self.connectionUpdateCard cancel];
		self.connectionUpdateCard = nil;
	}
	if (self.connectionDisputeCard != nil) {
		[self.connectionDisputeCard cancel];
		self.connectionDisputeCard = nil;
	}
    [super dealloc];
}

@end
