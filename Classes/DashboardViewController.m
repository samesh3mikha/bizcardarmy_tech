 //
//  DashboardViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DashboardViewController.h"

@implementation DashboardViewController

@synthesize	cardsTable;
@synthesize searchBar;
@synthesize bcaIcon, bcaMessage;
@synthesize overlayView;
@synthesize deleteCardAlertView, gotoLoginAlertView;
@synthesize loginController;
@synthesize syncedWithWebServer;
@synthesize cardsImage;
@synthesize currentSortingOption;
@synthesize currentSortingOrderAsc;
@synthesize fetchedResultsController;
@synthesize dashboardRefresher;
@synthesize imageDownloadsInProgress;
@synthesize managedObjectContext;
@synthesize searchPredicate;
@synthesize deleteCardsQueue, creditPurchaseInfoQueue;
@synthesize deleteCard;
@synthesize connectionSyncCards, connectionDeleteCard, connectionPurchaseInfo;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		overlayView = [[OverlayView alloc] init];
		gotoLoginAlertView = [[UIAlertView alloc] init];
		
		responseDataSyncCards = [[NSMutableData data] retain];	
		responseDataDeleteCard = [[NSMutableData data] retain];
        responseDataPurchaseInfo = [[NSMutableData data] retain];
		self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
		self.cardsImage = [NSMutableDictionary dictionary];
		iphoneDB_card_ids = [[NSMutableArray alloc] init];
		
		self.deleteCard = nil;
		self.deleteCardsQueue = [[[NSMutableArray alloc] init] autorelease];
		self.creditPurchaseInfoQueue = [[[NSMutableArray alloc] init] autorelease];
		if ([(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"deleteCardsQueue"] count] > 0) {
			[deleteCardsQueue addObjectsFromArray:(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"deleteCardsQueue"]];
		}
		if ([(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"creditPurchaseInfoQueue"] count] > 0) {
			[creditPurchaseInfoQueue addObjectsFromArray:(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"creditPurchaseInfoQueue"]];
		}
		
		dashboardRefresher = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refreshVisibleRows) userInfo:nil repeats:YES];
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
    [super viewDidLoad];
	[SharedStore store].dashboardLoaded = YES;

	self.view.backgroundColor = [SharedStore store].backColorForViews;
	cardsTable.separatorColor = [SharedStore store].colorForTableSeperators;
	cardsTable.backgroundColor = [UIColor clearColor];
		
	if ([SharedStore store].userSignedUp) {
		WelcomeViewController *welcomeVC = [[[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil] autorelease];
		welcomeVC.title = @"Bizcardarmy";
		[self presentModalViewController:welcomeVC animated:NO];
	}		
	
	UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshDashboard:)] autorelease];
	self.navigationItem.rightBarButtonItem = refreshButton;			
	
	if ([SharedStore store].hostActive && [SharedStore store].userSignedIn && syncedWithWebServer == NO) {
		[self syncWithWebServer];		
	}
    
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//User have changed sorting option
	if (currentSortingOption != [SharedStore store].currentSortingOption || currentSortingOrderAsc != [SharedStore store].currentSortingOrderAsc) {
		self.fetchedResultsController = nil;
		[self.cardsTable reloadData];
	}	
}

#pragma mark -
#pragma mark ---------- UITableView DEFAULT METHODS ----------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	
	if ([sectionInfo numberOfObjects] > 0) {
		UIBarButtonItem *sort = [[[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(showSortingOptions:)] autorelease];
		self.navigationItem.leftBarButtonItem = sort;
		self.searchBar.hidden = NO;
		self.bcaIcon.hidden = YES;
		self.bcaMessage.hidden = YES;		
	}
	else {
		if (!searchPredicate) {
			self.navigationItem.leftBarButtonItem = nil;
			self.searchBar.hidden = YES;
			self.bcaIcon.hidden = NO;
			self.bcaMessage.hidden = NO;
			self.bcaMessage.text = [NSString stringWithFormat:@"You have %@ credits \n Open your dusty desk drawer and start snapping to keep the army busy!\n\nYou can also login with this account at 'www.bizcardarmy.com' to access more features.",[[SharedStore store].userDictionary objectForKey:@"credit"]];
		}
		else {
			self.bcaIcon.hidden = YES;
			self.bcaMessage.hidden = YES;
		}
	}

    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CardsTableCustomCell";
    
    CardsTableCustomCell *cell = (CardsTableCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CardsTableCustomCell" owner:nil options:nil];
		for (id currentObject in topLevelObjects) {
			if([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (CardsTableCustomCell *) currentObject;
			}
		}
    }
    
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

// Configure CELL
-(void)configureCell:(CardsTableCustomCell *)cell atIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row % 2 == 0) {
		cell.imageView.image = [UIImage imageNamed:@"cell-bk-dark.png"];
	}
	else {
		cell.imageView.image = [UIImage imageNamed:@"cell-bk-light.png"];
	}
	[[SharedStore store] setRoundedBorder:[cell.cardImageView layer]];
	
	Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.nameLabel.text = @"";
	cell.detailLabel.text = @"";
	
	//DISPlAY IMAGE FROM FILE OR AFTER DOWNLOAD
	if (![cardsImage objectForKey:card.card_id])
	{
		//Look for card_image in file
		BOOL imageLoadedFromFile = NO;
		cell.cardImageView.image = nil;
		NSString *imageFilename = [[SharedStore store].cardsImageDictionary valueForKey:[NSString stringWithFormat:@"%d",[card.card_id intValue]]];
		if (imageFilename) {
			NSData *imageData = [[SharedStore store] imageDataForFilename:imageFilename];
			if (imageData) {
				[cardsImage setObject:[UIImage imageWithData:imageData] forKey:card.card_id];
				cell.cardImageView.image = [cardsImage objectForKey:card.card_id];
				imageLoadedFromFile = YES;
				
				[self saveContactInAB:card];
			}
			else {
				[[SharedStore store] deleteImageWithFilename:imageFilename];
				[[SharedStore store].cardsImageDictionary removeObjectForKey:[NSString stringWithFormat:@"%d",[card.card_id intValue]]];
				if ([SharedStore store].cardsImageDictionary) {
					[[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].cardsImageDictionary forKey:@"cardsImageDictionary"];
					[[NSUserDefaults standardUserDefaults] synchronize];					
				}
			}
		}
		
		if (!imageLoadedFromFile) {			
			[self startIconDownloadForCard:card];
		}			
		
	}
	else {
		cell.cardImageView.image = [cardsImage objectForKey:card.card_id];		
	}
	
	//Name N Detail Label
	if (![card.status isEqualToString:@"completed"] && ![card.status isEqualToString:@"sample"]) {
		//Uncopleted cards
		cell.nameLabel.text = @"Untitled";
		cell.detailLabel.text = [NSString stringWithFormat:@"Uploaded %@ ago ",[[SharedStore store] timeDiffFromDate:card.created_at]];					
	}
	else {
		//completed cards	
		if ([card.first_name length]>0 || [card.last_name length]>0) {
			if (currentSortingOption == by_lastname){
				cell.nameLabel.text	= [[SharedStore store] fullNameForFirstWord:[NSString stringWithFormat:@"%@,",card.last_name] secondWord:card.first_name thirdWord:nil];
			}
			else {
				cell.nameLabel.text	= [[SharedStore store] fullNameForFirstWord:card.first_name secondWord:nil thirdWord:card.last_name];
			}			
		}
		else if ([card.middle_name length]>0) {
			cell.nameLabel.text = card.middle_name;
		}
		else {
			cell.nameLabel.text = @"N/A";
		}
		
		//DISPLAY DETAILS
		if ( currentSortingOption == by_firstname || currentSortingOption == by_lastname || currentSortingOption == by_company || currentSortingOption == by_status) {
			if ([card.company length]>0) {
				cell.detailLabel.text = card.company;				
			}
			else {
				cell.detailLabel.text = @"N/A";
			}
		}
		else if (currentSortingOption == by_city) {
			if ([card.city length]>0) {
				cell.detailLabel.text = card.city;
			}
			else {
				cell.detailLabel.text = @"N/A";
			}
		}
		else if (currentSortingOption == by_dateCreated) {		
			cell.detailLabel.text = [NSString stringWithFormat:@"Uploaded %@ ago ",[[SharedStore store] timeDiffFromDate:card.created_at]];
		}			
	}	
	
	//DISPLAY STATUS
	cell.statusImage.image = [[SharedStore store] imageForStatus:card.status];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	CardDetailsViewController *cardDetailsViewController = [[[CardDetailsViewController alloc] initWithCard:card cardImage:[cardsImage objectForKey:card.card_id]] autorelease];
	cardDetailsViewController.title = @"Card Details";
	cardDetailsViewController.managedObjectContext = ((BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;	
	[self.navigationController pushViewController:cardDetailsViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 71.0;
}

#pragma mark -
#pragma mark ---------- FETCHEDRESULTSCONTROLER delegate methods ----------

//override fetchedResultsController getter
- (NSFetchedResultsController *)fetchedResultsController {
	if (fetchedResultsController == nil) {
		currentSortingOption = [SharedStore store].currentSortingOption;
		currentSortingOrderAsc = [SharedStore store].currentSortingOrderAsc;
		
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
		[fetchRequest setFetchBatchSize:20];
		[fetchRequest setEntity:entity];
		NSPredicate *predicate;
		
		predicate = [NSPredicate predicateWithFormat:@"user_id = %d", [[[SharedStore store].userDictionary valueForKey:@"id"] intValue]];
		if ([[self.searchPredicate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
			if (currentSortingOption == by_lastname){
				predicate = [NSPredicate predicateWithFormat:@"last_name BEGINSWITH[cd] %@ && user_id = %d", searchPredicate, [[[SharedStore store].userDictionary valueForKey:@"id"] intValue]];
			}
			else {
				predicate = [NSPredicate predicateWithFormat:@"first_name BEGINSWITH[cd] %@ && user_id = %d", searchPredicate, [[[SharedStore store].userDictionary valueForKey:@"id"] intValue]];
			}
		}
		[fetchRequest setPredicate:predicate];
		
		NSString *sortingOptionKey = [self getSortingOptionKey];
		NSSortDescriptor *sortDescriptorStatus;
		NSSortDescriptor *sortDescriptor;

		if ([sortingOptionKey isEqualToString:@"status"] || [sortingOptionKey isEqualToString:@"created_at"]) {
			sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortingOptionKey ascending:currentSortingOrderAsc] autorelease];
			[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
		}
		else {
			sortDescriptorStatus = [[[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];			
			sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:sortingOptionKey ascending:currentSortingOrderAsc	selector:@selector(caseInsensitiveCompare:)] autorelease];
			[fetchRequest setSortDescriptors:[NSArray arrayWithObjects: sortDescriptorStatus, sortDescriptor, nil]];			
		}
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		fetchedResultsController.delegate = self;
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error]) {
			//handle the error...
			NSLog(@"error occured in fetched result controller");
		}
	}	
	return fetchedResultsController;
}  

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.cardsTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.cardsTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.cardsTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	switch(type) {
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(CardsTableCustomCell *)[self.cardsTable cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.cardsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.cardsTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeInsert:
			[self.cardsTable insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.cardsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.cardsTable endUpdates];
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(void)showSortingOptions:(id)sender{
	SortingOtionsViewController *sortingOtionsViewController = [[[SortingOtionsViewController alloc] init] autorelease];
	sortingOtionsViewController.title = @"Sort By";
	[self.navigationController pushViewController:sortingOtionsViewController animated:YES];
}

-(void)refreshDashboard:(id)sender{
	if (![SharedStore store].hostActive) {
		Toast *toast = [[[Toast alloc] initWithMessage:@"Could not connect to the server"] autorelease];
		toast.frame = CGRectMake(20, 300, 280, 50);
		toast.borderOffset = CGSizeMake(2, 2);
		toast.tint = [UIColor orangeColor];
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
		[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];	
	}
	
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Cancel sync"]) {
		[self cancelDashboardUrlConnections];
	}
	else if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Refresh"] && [SharedStore store].hostActive) {		
		if (![SharedStore store].userSignedIn) {
			self.loginController = [[[LoginViewController alloc] init] autorelease];
			[loginController signInAfterDashboard];
			
			if (loginController.connectionSignIn != nil) {
				self.navigationItem.rightBarButtonItem.title = @"Cancel sync";
				if (!overlayView.isActive) {
					[overlayView setFrame:[self.view frame]];
					[overlayView showInView:self.view withActivityIndicator:YES];			
				}	
			}
		}
		else if ([SharedStore store].userSignedIn) {
			[self syncWithWebServer];
		}
	}	
}


#pragma mark -
#pragma mark ---------- INTERNETSTATUS DELEGATE METHODS ----------

-(void)updateInternetStatus{	
	if ([SharedStore store].hostActive && ![SharedStore store].userSignedIn && ![SharedStore store].signingUser) {
		self.loginController = [[[LoginViewController alloc] init] autorelease];
		[loginController signInAfterDashboard];
		
		if (loginController.connectionSignIn != nil) {
			self.navigationItem.rightBarButtonItem.title = @"Cancel sync";
			if (!overlayView.isActive) {
				[overlayView setFrame:[self.view frame]];
				[overlayView showInView:self.view withActivityIndicator:YES];
			}			
		}
	}
	else if ([SharedStore store].hostActive && [SharedStore store].userSignedIn && !syncedWithWebServer && ![SharedStore store].syncingCards) {
		[self syncWithWebServer];		
	}
    else if ([SharedStore store].hostActive && [SharedStore store].userSignedIn && syncedWithWebServer && [creditPurchaseInfoQueue count] > 0) {
       	// Inform about reeemaining purchases in the Queue
        NSString *transactionID = (NSString *)[creditPurchaseInfoQueue objectAtIndex:0];
		[self notifyServerAboutCreditsPurchase:transactionID]; 
    }
	else if ([SharedStore store].hostActive && [SharedStore store].userSignedIn && syncedWithWebServer && [deleteCardsQueue count] > 0) {
			[self deleteCardFromWebServer:[[deleteCardsQueue objectAtIndex:0] intValue]];
	}
	else if	([SharedStore store].hostActive && [SharedStore store].userSignedIn && syncedWithWebServer && [deleteCardsQueue count] == 0) {
		if ([(NSArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser] count] > 0) {
			[self showUploadStartMessage];
			
			UITabBarController *tabBarController = (UITabBarController *)[[self navigationController] tabBarController];
			NewCardViewController *newcardController =  (NewCardViewController *)[[(UINavigationController *)[tabBarController.viewControllers objectAtIndex:1]viewControllers] objectAtIndex:0];
			[newcardController createCard];
		}		
	}
}

#pragma mark -
#pragma mark ---------- EDIT_MODE DELEGATE METHODS ----------

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	Card *card = [self.fetchedResultsController objectAtIndexPath:indexPath];
	if ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"]) {
		return UITableViewCellEditingStyleDelete;
	}
    else {
        // do your thing
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		self.deleteCardAlertView = [[[UIAlertView alloc] init] autorelease];
		[deleteCardAlertView setTitle:@"Delete card!"];
		[deleteCardAlertView setMessage:@"Are you sure you want to delete this card?"];
		[deleteCardAlertView addButtonWithTitle:@"Yes"];
		[deleteCardAlertView addButtonWithTitle:@"No"];
		[deleteCardAlertView setDelegate:self];
		[deleteCardAlertView show];
		
		self.deleteCard = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
}


#pragma mark -
#pragma mark ---------- UIALERTVIEW DELEGATE METHODS ----------

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == deleteCardAlertView) {
		if (buttonIndex == 0) {
		// Delete Card
			[self deleteCard:self.deleteCard];
			self.deleteCard = nil;
		}
		else {
		// Cancel Deleting
			return;
		}		
	}
	else if (alertView == gotoLoginAlertView) {
		if (buttonIndex == 0) {
		// Show Login screen
			[SharedStore store].loginConnectionFailed = NO;
			[SharedStore store].dashboardLoaded = NO;
			[SharedStore store].userSignedIn = NO;
			[SharedStore store].userSignedInOffline = NO;
			[SharedStore store].userSignedUp = NO;
			[SharedStore store].currentUser = nil;
			[SharedStore store].userDictionary = nil;		
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"currentUser"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			BizCardArmyAppDelegate *delegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
			[delegate performSelector:@selector(gotoLoginPage) withObject:nil afterDelay:0.3];
		}
	}
}


#pragma mark -
#pragma mark ---------- UISEARCHBAR DELEGATE METHODS ----------

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar{
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText{
	[self.fetchedResultsController setDelegate:nil];
	self.fetchedResultsController = nil;	
	
	self.searchPredicate = searchBar.text;
	[self.cardsTable reloadData];
	
}	

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar{	
	[aSearchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar{
	[aSearchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar{
	aSearchBar.text = @"";
	self.searchPredicate = @"";
	[aSearchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark -
#pragma mark ---------- ICONDOWNLOADER DELEGATE METHODS ----------

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(Card *)card
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:card.card_id];
    if (iconDownloader != nil)
    {
        // Display the newly loaded image
		[cardsImage setObject:iconDownloader.cardImage forKey:card.card_id];
		[self showImagesForCard:card];

		if (![[SharedStore store].cardsImageDictionary valueForKey:[NSString stringWithFormat:@"%d",[card.card_id intValue]]]) {
			NSString *filename;
			filename = [NSString stringWithFormat:@"iphone%d.jpg",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]*1000]];
			[[SharedStore store] saveCard:[cardsImage objectForKey:card.card_id] asFilename:filename];
			
			[[SharedStore store].cardsImageDictionary setObject:filename forKey:[NSString stringWithFormat:@"%d",[card.card_id intValue]]];
			[[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].cardsImageDictionary forKey:@"cardsImageDictionary"];
			[[NSUserDefaults standardUserDefaults] synchronize];			
		}	
		
		[self saveContactInAB:card];
    }	
}

#pragma mark -
#pragma mark ---------- NEWCARDVIEWCONTROLLERDELEGATE METHODS ----------

-(void)cancelDashboardUrlConnections{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.navigationItem.rightBarButtonItem.title = @"Refresh";
	if (overlayView.isActive) {
		[overlayView hide];
	}	
	
	if (syncedWithWebServer && dashboardRefresher != nil) {
		[dashboardRefresher invalidate];
		dashboardRefresher = nil;		
	}
	if (self.loginController != nil) {
		if (loginController.connectionSignIn != nil) {
			[loginController.connectionSignIn cancel];
			[SharedStore store].signingUser = NO;
			loginController.connectionSignIn = nil;
			self.loginController = nil;
		}		
	}
    if (self.connectionPurchaseInfo != nil) {
        [connectionPurchaseInfo cancel];
        [SharedStore store].informingWebServerAboutPurchase = NO;
        self.connectionPurchaseInfo = nil;
    }
	if (self.connectionSyncCards != nil) {
		[connectionSyncCards cancel];
		[SharedStore store].syncingCards = NO;
		self.connectionSyncCards = nil;
	}
	if (self.connectionDeleteCard != nil) {
		[connectionDeleteCard cancel];
		[SharedStore store].deletingCards = NO;
		self.connectionDeleteCard = nil;
	}
}

-(void)callShowPaypalWebView{
	BizCardArmyAppDelegate *appDelegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
	AccountViewController *accountVC = (AccountViewController *)[[[appDelegate.tabBarController.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0];
	if (accountVC) {
		[accountVC showPaypalWebView];
	}		
}

#pragma mark -
#pragma mark ---------- SKPaymentTransactionObserver DELEGATE METHODS ----------

// saves a record of the transaction by storing the receipt to disk
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
}

// enable pro features
- (void)provideContent:(NSString *)productId
{
}

// removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{    
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];    
}

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{    
//    [self recordTransaction:transaction];
//    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    
    //Remove Overlay
    [[SharedStore store].overlayView hide];

    //Keep records of purchase N notify server
    [self keepCreditsPurchaseRecord:transaction];
}

// called when a transaction has been restored and and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
//    [self recordTransaction:transaction.originalTransaction];
//    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];

    [[SharedStore store].overlayView hide];
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{

    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    
    [[SharedStore store].overlayView hide];
}

// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)syncWithWebServer{
	if ([SharedStore store].syncingCards) {
		return;
	}
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %@", [[SharedStore store].userDictionary valueForKey:@"id"]];
	NSError *error;
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSArray *cards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

	
	NSString *ids_csv = [[[NSString alloc] init] autorelease];
	NSString *timestamps_csv = [[[NSString alloc] init] autorelease];
	for (int i=0; i<[cards count]; i++) {
		Card *card = [cards	objectAtIndex:i];
		[iphoneDB_card_ids addObject:card.card_id];
		ids_csv = [NSString stringWithFormat:@"%@%d",ids_csv, [card.card_id intValue]];
		timestamps_csv = [NSString stringWithFormat:@"%@%d",timestamps_csv,(int)[card.updated_at timeIntervalSince1970]];
		if (i < [cards count] -1) {
			ids_csv = [NSString stringWithFormat:@"%@,",ids_csv];
			timestamps_csv = [NSString stringWithFormat:@"%@,",timestamps_csv];
		}
	}
	NSString *connectionString = [NSString stringWithFormat:@"%@/cards/sync.json?ids=%@&updated_timestamps=%@", SERVER_STRING,ids_csv,timestamps_csv];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"GET"];
	connectionSyncCards = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionSyncCards) {
		[SharedStore store].syncingCards = YES;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		self.navigationItem.rightBarButtonItem.title = @"Cancel sync";
		if (!overlayView.isActive) {
			[overlayView setFrame:[self.view frame]];
			[overlayView showInView:self.view withActivityIndicator:YES];			
		}
	}	
}

-(void)deleteCardFromWebServer:(NSInteger )card_ID{
	NSString *connectionString = [NSString stringWithFormat:@"%@/cards/%d.json", SERVER_STRING, card_ID ];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"DELETE"];
	connectionDeleteCard = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionDeleteCard) {
		[SharedStore store].deletingCards = YES;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}		
}


- (void)notifyServerAboutCreditsPurchase:(NSString *)transactionID{
    NSString *purchaseInfo = [(NSMutableDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"purchaseInfoDictionary"] objectForKey:transactionID];
    
    NSString *connectionString = [NSString stringWithFormat:@"%@/credit_payment_notifications/create.json?%@", SERVER_STRING, purchaseInfo];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"GET"];
	connectionPurchaseInfo = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionPurchaseInfo) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

#pragma mark -
#pragma mark ---------- NSURLCONNECTION DELEGATE METHODS ----------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	if (connection == connectionSyncCards) {
		[responseDataSyncCards setLength:0];
	}
	else if (connection == connectionDeleteCard){
		[responseDataDeleteCard setLength:0];
	}
    else if (connection == connectionPurchaseInfo){
        [responseDataPurchaseInfo setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (connection == connectionSyncCards) {
		[responseDataSyncCards appendData:data];	
	}
	else if (connection == connectionDeleteCard){
		[responseDataDeleteCard appendData:data];
	}
    else if (connection == connectionPurchaseInfo){
        [responseDataPurchaseInfo appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (connection == connectionSyncCards) {
		self.navigationItem.rightBarButtonItem.title = @"Refresh";
		if (overlayView.isActive) {
			[overlayView hide];			
		}
		[SharedStore store].syncingCards = NO;
		self.connectionSyncCards = nil;
	}
	else if (connection == connectionDeleteCard){
		self.connectionDeleteCard = nil;
		[SharedStore store].deletingCards = NO;
	}
    else if (connection == connectionPurchaseInfo){
        self.connectionPurchaseInfo = nil;
        [SharedStore store].informingWebServerAboutPurchase = NO;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    BOOL justMadePurchase = NO;
    
    
	if (connection == connectionSyncCards) {
		self.connectionSyncCards = nil;
		
		NSString *responseStringCards = [[[NSString alloc] initWithData:responseDataSyncCards encoding:NSUTF8StringEncoding] autorelease];
		NSArray *cardsArray = [responseStringCards JSONValue];
        
        if ([cardsArray count] > 0) {
            //UPDATE USER CREDITS
            NSObject *user_credits = [[[(NSDictionary *)[cardsArray objectAtIndex:0] valueForKey:@"card"] valueForKey:@"user"] valueForKey:@"credit"];
            [self updateUserCredits:user_credits];
  
            //UPDATE CARDS    
            [self syncIphoneNwebDB:cardsArray];	
        }
        
        syncedWithWebServer = YES;
        [SharedStore store].syncingCards = NO;
        self.navigationItem.rightBarButtonItem.title = @"Refresh";
        if (overlayView.isActive) {
            [overlayView hide];			
        }	
	}
	else if (connection == connectionDeleteCard){
	//Response --> {"card":580}
		self.connectionDeleteCard = nil;
		
		if ([deleteCardsQueue count] > 0) {
			[deleteCardsQueue removeObjectAtIndex:0];
			[[NSUserDefaults standardUserDefaults] setObject:deleteCardsQueue forKey:@"deleteCardsQueue"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}

		[SharedStore store].deletingCards = NO;
	}	
    else if (connection == connectionPurchaseInfo){
    //Response --> {"transaction_id":"2312312312"}
        self.connectionPurchaseInfo = nil;
        
		NSString *responseString = [[[NSString alloc] initWithData:responseDataPurchaseInfo encoding:NSUTF8StringEncoding] autorelease];
        NSDictionary *responseDictionary = [responseString JSONValue];
        
        //UPDATE USER CREDITS
        NSObject *user_credits = [responseDictionary valueForKey:@"user_credits"];
        [self updateUserCredits:user_credits];

        NSString *transaction_id = (NSString *)[responseDictionary valueForKey:@"transaction_id"];
        if (![transaction_id isEqualToString:@"0"] && [creditPurchaseInfoQueue count] > 0) {
            [creditPurchaseInfoQueue removeObject:(NSString *)transaction_id];
            NSMutableDictionary *purchaseInfoDictionary = [[[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"purchaseInfoDictionary"]] autorelease];
            [purchaseInfoDictionary removeObjectForKey:transaction_id];
            
            [[NSUserDefaults standardUserDefaults] setObject:purchaseInfoDictionary forKey:@"purchaseInfoDictionary"];
            [[NSUserDefaults standardUserDefaults] setObject:creditPurchaseInfoQueue forKey:@"creditPurchaseInfoQueue"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [SharedStore store].informingWebServerAboutPurchase = NO;
        justMadePurchase = YES;
    }
	
    
    if  (justMadePurchase){
        [self performSelector:@selector(refreshDashboard:) withObject:nil afterDelay:0.3];        
    }
    else if ([creditPurchaseInfoQueue count] > 0 && ![SharedStore store].informingWebServerAboutPurchase) {
       	// Inform about reeemaining purchases in the Queue
        NSString *transactionID = (NSString *)[creditPurchaseInfoQueue objectAtIndex:0];
		[self notifyServerAboutCreditsPurchase:transactionID]; 
    }
	else if ([deleteCardsQueue count] > 0 && ![SharedStore store].deletingCards) {
	// Delete remainning cards in the Queue
		NSInteger card_ID = [[deleteCardsQueue objectAtIndex:0] intValue];
		[self deleteCardFromWebServer:card_ID];
	}
	else if ([(NSArray *)[[SharedStore store].createCardsDictionary objectForKey:[SharedStore store].currentUser] count] > 0  && ![SharedStore store].uploadingCards) {
	// Start creating cards if createcardsQueue	
		[self showUploadStartMessage];
		
		UITabBarController *tabBarController = (UITabBarController *)[[self navigationController] tabBarController];
		NewCardViewController *newcardController =  (NewCardViewController *)[[(UINavigationController *)[tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
		[newcardController createCard];
	}
}


#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)releaseLoginController{
	self.navigationItem.rightBarButtonItem.title = @"Refresh";
	self.loginController = nil;
	if (![SharedStore store].userSignedIn) {
		if (![SharedStore store].loginConnectionFailed) {
			if (overlayView.isActive) {
				[overlayView hide];
			}
			[gotoLoginAlertView setTitle:@"Login Error!"];
			[gotoLoginAlertView setMessage:@"Error occured while trying to connect to webserver.You will be redirected to login screen"];
			[gotoLoginAlertView addButtonWithTitle:@"Ok"];
			[gotoLoginAlertView setDelegate:self];
			[gotoLoginAlertView show];						
		}
	}
	else if ([SharedStore store].hostActive && [SharedStore store].userSignedIn) {
		[self syncWithWebServer];
	}
}

-(void)showUploadStartMessage{
	Toast *toast = [[[Toast alloc] initWithMessage:@"Uploading cards saved previously."] autorelease];
	toast.frame = CGRectMake(20, 300, 280, 50);
	toast.borderOffset = CGSizeMake(2, 2);
	toast.tint = [UIColor orangeColor];
	toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;
	if ([self.tabBarController modalViewController]) {
		[toast showInView:[self.tabBarController modalViewController].view];					
	}
	else {
		[toast showInView:self.tabBarController.view];	
	}	
}


-(NSString *)getSortingOptionKey{
	NSArray *sortingOptionKey = [NSArray arrayWithObjects:@"first_name", @"last_name", @"company", @"status", @"city", @"created_at", nil];
	return [sortingOptionKey objectAtIndex:currentSortingOption];	
}

-(NSString *)getSectionKey{
	NSArray *sectionsKeys = [NSArray arrayWithObjects:@"first_name_char1", @"last_name_char1", @"company_char1", @"status", @"city_char1", @"created_at", nil];
	return [sectionsKeys objectAtIndex:currentSortingOption];
}

- (void)startIconDownloadForCard:(Card *)card
{	
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:card.card_id];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[[IconDownloader alloc] init] autorelease];
		iconDownloader.card = card;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:card.card_id];
        [iconDownloader startDownload];
    }
}

- (void)cancelIconDownloadForCard:(Card *)card
{	
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:card.card_id];
    if (iconDownloader != nil) 
    {
		if (iconDownloader.connectionImage != nil) {
			[iconDownloader cancelDownload];
		}
		[imageDownloadsInProgress removeObjectForKey:card.card_id];	
    }
}

// Load downloaded Image into UIImageView
- (void)showImagesForCard:(Card *)card
{	
	NSIndexPath *indexPath =  [self.fetchedResultsController indexPathForObject:card];
	CardsTableCustomCell *cell = (CardsTableCustomCell*)[self.cardsTable cellForRowAtIndexPath:indexPath];
	if (![cardsImage objectForKey:card.card_id])
	{
		[self startIconDownloadForCard:card];
	}
	else
	{
		cell.cardImageView.image = [cardsImage objectForKey:card.card_id];
	}
}

-(BOOL)cardIsPresentWithID:(NSInteger)card_ID{
	BOOL cardPresent = NO;
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %d && card_id = %d", [[[SharedStore store].userDictionary valueForKey:@"id"] intValue], card_ID];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *cards = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([cards count] > 0) {
		cardPresent = YES;
	}
	
	return cardPresent;
}

-(Card *)cardWithId:(NSInteger)card_Id{
	NSArray *cards;
	Card *card = nil;
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity;
	NSPredicate *predicate;
	NSError *error;
	
	entity= [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	predicate = [NSPredicate predicateWithFormat:@"card_id = %d", card_Id];
	[fetchRequest setPredicate:predicate];
	cards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if ([cards count] > 0) {
		card = [cards objectAtIndex:0];
	}
	
	return card;
}

//This method is used to create a <card> for <dictionary> while updating a card
-(Card *)card:(Card *)card ForDictionary:(NSDictionary *)cardDictionary{		
	if ([[cardDictionary  objectForKey:@"id"] isKindOfClass:[NSDecimalNumber class]]){
		NSNumber *card_id = [[[NSNumber alloc] initWithInt: [[cardDictionary valueForKey:@"id"] intValue]] autorelease];
		card.card_id = card_id;
	}
	else if ([[cardDictionary  objectForKey:@"ID"] isKindOfClass:[NSDecimalNumber class]]){
		NSNumber *card_id = [[[NSNumber alloc] initWithInt: [[cardDictionary valueForKey:@"ID"] intValue]] autorelease];
		card.card_id = card_id;		
	}

	if ([[cardDictionary  objectForKey:@"user_id"] isKindOfClass:[NSDecimalNumber class]]){
		NSNumber *user_id = [[[NSNumber alloc] initWithInt: [[cardDictionary valueForKey:@"user_id"] intValue]] autorelease];
		card.user_id = user_id;
	}
	else if ([[cardDictionary  objectForKey:@"User_ID"] isKindOfClass:[NSDecimalNumber class]]) {
		NSNumber *user_id = [[[NSNumber alloc] initWithInt: [[cardDictionary valueForKey:@"User_ID"] intValue]] autorelease];
		card.user_id = user_id;		
	}
	if ([[cardDictionary  objectForKey:@"AddressBookId"] isKindOfClass:[NSNumber class]]){
		card.addressbookID = [cardDictionary  valueForKey:@"AddressBookId"];
	}
	if ([[cardDictionary  objectForKey:@"first_name"] isKindOfClass:[NSString class]]){
		card.first_name = [cardDictionary valueForKey:@"first_name"];
	}
	if ([[cardDictionary  objectForKey:@"middle_name"] isKindOfClass:[NSString class]]){
		card.middle_name = [cardDictionary valueForKey:@"middle_name"];
	}
	if ([[cardDictionary  objectForKey:@"last_name"] isKindOfClass:[NSString class]]){
		card.last_name = [cardDictionary valueForKey:@"last_name"];
	}
	if ([[cardDictionary  objectForKey:@"company"] isKindOfClass:[NSString class]]){
		card.company = [cardDictionary valueForKey:@"company"];
	}
	if ([[cardDictionary  objectForKey:@"job_title"] isKindOfClass:[NSString class]]){
		card.job_title = [cardDictionary valueForKey:@"job_title"];
	}
	if ([[cardDictionary  objectForKey:@"email"] isKindOfClass:[NSString class]]){
		card.email = [cardDictionary valueForKey:@"email"];
	}
	if ([[cardDictionary  objectForKey:@"phone"] isKindOfClass:[NSString class]]){
		card.phone = [cardDictionary valueForKey:@"phone"];
	}
	if ([[cardDictionary  objectForKey:@"mobile"] isKindOfClass:[NSString class]]){
		card.mobile = [cardDictionary valueForKey:@"mobile"];
	}
	if ([[cardDictionary  objectForKey:@"fax"] isKindOfClass:[NSString class]]){
		card.fax = [cardDictionary valueForKey:@"fax"];
	}
	if ([[cardDictionary  objectForKey:@"website"] isKindOfClass:[NSString class]]){
		card.website = [cardDictionary valueForKey:@"website"];
	}
	if ([[cardDictionary  objectForKey:@"country"] isKindOfClass:[NSString class]]){
		card.country = [cardDictionary valueForKey:@"country"];
	}
	if ([[cardDictionary  objectForKey:@"state"] isKindOfClass:[NSString class]]){
		card.state = [cardDictionary valueForKey:@"state"];
	}
	if ([[cardDictionary  objectForKey:@"city"] isKindOfClass:[NSString class]]){
		card.city = [cardDictionary valueForKey:@"city"];
	}
	if ([[cardDictionary  objectForKey:@"address1"] isKindOfClass:[NSString class]]){
		card.address1 = [cardDictionary valueForKey:@"address1"];
	}
	if ([[cardDictionary  objectForKey:@"address2"] isKindOfClass:[NSString class]]){
		card.address2 = [cardDictionary valueForKey:@"address2"];
	}
	if ([[cardDictionary  objectForKey:@"zip"] isKindOfClass:[NSString class]]){
		card.zip = [cardDictionary valueForKey:@"zip"];
	}
	if ([[cardDictionary  objectForKey:@"card_status"] isKindOfClass:[NSString class]]){
		card.status = [cardDictionary valueForKey:@"card_status"];
	}
	if ([[cardDictionary  objectForKey:@"dispute_status"] isKindOfClass:[NSString class]]){
		card.dispute_status = [cardDictionary valueForKey:@"dispute_status"];
	}
	if ([[cardDictionary  objectForKey:@"created_at"] isKindOfClass:[NSString class]]){
		card.created_at = [[SharedStore store] dateFromString:[cardDictionary  objectForKey:@"created_at"]];
	}
	if ([[cardDictionary  objectForKey:@"updated_at"] isKindOfClass:[NSString class]]){
		card.updated_at = [[SharedStore store] dateFromString:[cardDictionary  objectForKey:@"updated_at"]];
	}
	
	if ([[cardDictionary  objectForKey:@"image_url_original"] isKindOfClass:[NSString class]]){
		card.image_url_original = [cardDictionary valueForKey:@"image_url_original"];
	}
	if ([[cardDictionary  objectForKey:@"image_url_medium"] isKindOfClass:[NSString class]]){
		card.image_url_medium = [cardDictionary valueForKey:@"image_url_medium"];
	}
	if ([[cardDictionary  objectForKey:@"image_url_thumb"] isKindOfClass:[NSString class]]){
		card.image_url_thumb = [cardDictionary valueForKey:@"image_url_thumb"];
	}
	
	return card;
}

-(NSDictionary *)dictionaryForCard:(Card *)card{
	NSMutableDictionary *cardDictionary = [[[NSMutableDictionary alloc] init] autorelease];
	
	if (card.first_name || card.middle_name || card.last_name) {
		NSString *name = [[SharedStore store] fullNameForFirstWord:card.first_name secondWord:card.middle_name thirdWord:card.last_name];
		[cardDictionary setValue:name forKey:@"Name"];
	}
	[cardDictionary setValue:card.user_id forKey:@"User_ID"];	
	[cardDictionary setValue:card.card_id forKey:@"ID"];	
	[cardDictionary setValue:card.first_name forKey:@"FirstName"];
	[cardDictionary setValue:card.middle_name forKey:@"MiddleName"];
	[cardDictionary setValue:card.last_name forKey:@"LastName"];	
	[cardDictionary setValue:card.company forKey:@"Company"];
	[cardDictionary setValue:card.job_title forKey:@"Post"];
	[cardDictionary setValue:card.email forKey:@"Email"];
	[cardDictionary setValue:card.phone forKey:@"Phone"];
	[cardDictionary setValue:card.mobile forKey:@"Mobile"];
	[cardDictionary setValue:card.fax forKey:@"Fax"];
	[cardDictionary setValue:card.website forKey:@"Website"];
	[cardDictionary setValue:card.country forKey:@"Country"];
	[cardDictionary setValue:card.state forKey:@"State"];
	[cardDictionary setValue:card.city forKey:@"City"];
	[cardDictionary setValue:card.address1 forKey:@"Address1"];
	[cardDictionary setValue:card.address2 forKey:@"Address2"];
	[cardDictionary setValue:card.zip forKey:@"Zip"];		
	[cardDictionary setValue:card.status forKey:@"Status"];
	[cardDictionary setValue:card.dispute_status forKey:@"Dispute_Status"];
	[cardDictionary setValue:card.image_url_thumb forKey:@"Image_Url_Thumb"];	
	[cardDictionary setValue:card.image_url_medium forKey:@"Image_Url_Medium"];
	if ([cardsImage objectForKey:card.card_id]) {
		[cardDictionary setObject:[cardsImage objectForKey:card.card_id] forKey:@"CardImage"];
	}
	if (card.created_at) {
		NSString *timeDiff = [NSString stringWithFormat:@"%@ ago",[[SharedStore store] timeDiffFromDate:card.created_at]];
		[cardDictionary setValue:timeDiff forKey:@"Uploaded"];
	}
	[cardDictionary setValue:card.addressbookID forKey:@"AddressBookId"];
	
	return cardDictionary;
}

-(void)syncIphoneNwebDB:(NSArray *)cardsArray{
	if ([cardsArray count] == 0) {
		return;
	}
	
	BOOL changes_made = NO;
	for (int i = 0; i < [cardsArray count]; i++) {
		
		NSDictionary *cardDictionary = [[cardsArray objectAtIndex:i] objectForKey:@"card"];
		NSNumber *cardId = [cardDictionary valueForKey:@"id"];
		
		//Card present ONLY in WEB-DB
		if (![iphoneDB_card_ids containsObject:cardId] && ![deleteCardsQueue containsObject:cardId]) {
			[self createNewCard:cardDictionary];
			changes_made = YES;
		}
		//Card present BOTH in IPHONE-DB N WEB-DB
		else if ([iphoneDB_card_ids containsObject:cardId] && ![[cardDictionary valueForKey:@"card_status"] isEqualToString:@"deleted"]){
			
			Card *card = [self cardWithId:[cardId intValue]];
			if (card) {
				card = [self card:card ForDictionary:cardDictionary];
				[self saveContactInAB:card];
				[[SharedStore store] updateAddressBook:[card.addressbookID intValue] usingDictionary:[self dictionaryForCard:card]];
				changes_made = YES;
			}
		}
			 
		if ([[cardDictionary valueForKey:@"card_status"] isEqualToString:@"deleted"]) {
			Card *card = [self cardWithId:[cardId intValue]];
			if (card){
				[self.managedObjectContext deleteObject:card];
				changes_made = YES;
			}
		}
	}
	
	if (changes_made) {
		[self updateDB];
	}
	
	BizCardArmyAppDelegate *appDelegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
	AccountViewController *accountVC = (AccountViewController *)[[[appDelegate.tabBarController.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0];
	if (accountVC) {
		[accountVC getUserCreditInfo];
	}		
}

-(void)keepCreditsPurchaseRecord:(SKPaymentTransaction *)transaction{
    NSInteger payment_gross, credit_quantity;
    payment_gross = 0;
    credit_quantity = 0;
    
    if ([transaction.payment.productIdentifier isEqualToString:KBCAFullPackage]) {
        payment_gross = KBCAFullPackage_price;
        credit_quantity = KBCAFullPackage_credits;
    }
    else if ([transaction.payment.productIdentifier isEqualToString:KBCAStandardPackage]) {
        payment_gross = KBCAStandardPackage_price;
        credit_quantity = KBCAStandardPackage_credits;
    }
    else if ([transaction.payment.productIdentifier isEqualToString:KBCAExtendedPackage]) {
        payment_gross = KBCAExtendedPackage_price;
        credit_quantity = KBCAExtendedPackage_credits;
    }
    else if ([transaction.payment.productIdentifier isEqualToString:KBCABasicPackage]) {
        payment_gross = KBCABasicPackage_price;
        credit_quantity = KBCABasicPackage_credits;
    }
    
    NSString *purchaseInfo = [NSString stringWithFormat:@"source=iphone&user_id=%@&quantity=%d&txn_id=%@&payment_status=%@&payment_gross=%d",[[SharedStore store].userDictionary valueForKey:@"id"], credit_quantity, transaction.transactionIdentifier, @"Completed", payment_gross];

    NSMutableDictionary *purchaseInfoDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    [purchaseInfoDictionary setDictionary:(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"purchaseInfoDictionary"]];
    [purchaseInfoDictionary setObject:purchaseInfo forKey:(NSString *)transaction.transactionIdentifier];
    [creditPurchaseInfoQueue addObject:(NSString *)transaction.transactionIdentifier];
    
	[[NSUserDefaults standardUserDefaults] setObject:purchaseInfoDictionary forKey:@"purchaseInfoDictionary"];
	[[NSUserDefaults standardUserDefaults] setObject:creditPurchaseInfoQueue forKey:@"creditPurchaseInfoQueue"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	if ([SharedStore store].hostActive && ![SharedStore store].informingWebServerAboutPurchase) {
		[self notifyServerAboutCreditsPurchase:transaction.transactionIdentifier];
	}	
}

-(void)createNewCard:(NSDictionary *)cardDictionary{
	if ([self cardIsPresentWithID:[[cardDictionary valueForKey:@"id"] intValue]]) {
		return;
	}
	Card *card = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.managedObjectContext];

	if ([[cardDictionary  objectForKey:@"id"] isKindOfClass:[NSDecimalNumber class]]){
		NSNumber *card_id = [[[NSNumber alloc] initWithInt: [[cardDictionary valueForKey:@"id"] intValue]] autorelease];
		card.card_id = card_id;
	}
	if ([[cardDictionary  objectForKey:@"user_id"] isKindOfClass:[NSDecimalNumber class]]){
		NSNumber *user_id = [[[NSNumber alloc] initWithInt: [[cardDictionary valueForKey:@"user_id"] intValue]] autorelease];
		card.user_id = user_id;
	}
	if ([[cardDictionary  objectForKey:@"AddressBookId"] isKindOfClass:[NSNumber class]]){
		card.addressbookID = [cardDictionary  valueForKey:@"AddressBookId"];
	}	
	if ([[cardDictionary  objectForKey:@"first_name"] isKindOfClass:[NSString class]]){
		card.first_name = [cardDictionary valueForKey:@"first_name"];
	}
	if ([[cardDictionary  objectForKey:@"middle_name"] isKindOfClass:[NSString class]]){
		card.middle_name = [cardDictionary valueForKey:@"middle_name"];
	}
	if ([[cardDictionary  objectForKey:@"last_name"] isKindOfClass:[NSString class]]){
		card.last_name = [cardDictionary valueForKey:@"last_name"];
	}	
	if ([[cardDictionary  objectForKey:@"company"] isKindOfClass:[NSString class]]){
		card.company = [cardDictionary valueForKey:@"company"];
	}
	if ([[cardDictionary  objectForKey:@"job_title"] isKindOfClass:[NSString class]]){
		card.job_title = [cardDictionary valueForKey:@"job_title"];
	}
	if ([[cardDictionary  objectForKey:@"email"] isKindOfClass:[NSString class]]){
		card.email = [cardDictionary valueForKey:@"email"];
	}
	if ([[cardDictionary  objectForKey:@"phone"] isKindOfClass:[NSString class]]){
		card.phone = [cardDictionary valueForKey:@"phone"];
	}
	if ([[cardDictionary  objectForKey:@"mobile"] isKindOfClass:[NSString class]]){
		card.mobile = [cardDictionary valueForKey:@"mobile"];
	}
	if ([[cardDictionary  objectForKey:@"fax"] isKindOfClass:[NSString class]]){
		card.fax = [cardDictionary valueForKey:@"fax"];
	}
	if ([[cardDictionary  objectForKey:@"website"] isKindOfClass:[NSString class]]){
		card.website = [cardDictionary valueForKey:@"website"];
	}
	if ([[cardDictionary  objectForKey:@"country"] isKindOfClass:[NSString class]]){
		card.country = [cardDictionary valueForKey:@"country"];
	}
	if ([[cardDictionary  objectForKey:@"state"] isKindOfClass:[NSString class]]){
		card.state = [cardDictionary valueForKey:@"state"];
	}
	if ([[cardDictionary  objectForKey:@"city"] isKindOfClass:[NSString class]]){
		card.city = [cardDictionary valueForKey:@"city"];
	}
	if ([[cardDictionary  objectForKey:@"address1"] isKindOfClass:[NSString class]]){
		card.address1 = [cardDictionary valueForKey:@"address1"];
	}
	if ([[cardDictionary  objectForKey:@"address2"] isKindOfClass:[NSString class]]){
		card.address2 = [cardDictionary valueForKey:@"address2"];
	}
	if ([[cardDictionary  objectForKey:@"zip"] isKindOfClass:[NSString class]]){
		card.zip = [cardDictionary valueForKey:@"zip"];
	}
	if ([[cardDictionary  objectForKey:@"card_status"] isKindOfClass:[NSString class]]){
		card.status = [cardDictionary valueForKey:@"card_status"];
	}
	if ([[cardDictionary  objectForKey:@"dispute_status"] isKindOfClass:[NSString class]]){
		card.dispute_status = [cardDictionary valueForKey:@"dispute_status"];
	}	
	if ([[cardDictionary  objectForKey:@"created_at"] isKindOfClass:[NSString class]]){
		card.created_at = [[SharedStore store] dateFromString:[cardDictionary  objectForKey:@"created_at"]];
	}
	if ([[cardDictionary  objectForKey:@"updated_at"] isKindOfClass:[NSString class]]){
		card.updated_at = [[SharedStore store] dateFromString:[cardDictionary  objectForKey:@"updated_at"]];
	}
	if ([[cardDictionary  objectForKey:@"image_url_original"] isKindOfClass:[NSString class]]){
		card.image_url_original = [cardDictionary valueForKey:@"image_url_original"];
	}
	if ([[cardDictionary  objectForKey:@"image_url_medium"] isKindOfClass:[NSString class]]){
		card.image_url_medium = [cardDictionary valueForKey:@"image_url_medium"];
	}
	if ([[cardDictionary  objectForKey:@"image_url_thumb"] isKindOfClass:[NSString class]]){
		card.image_url_thumb = [cardDictionary valueForKey:@"image_url_thumb"];
	}		
	
	
	[self updateDB];
	
	if ([[cardDictionary objectForKey:@"photo_file_name"] isKindOfClass:[NSString class]]) {
		NSString *filename = [cardDictionary valueForKey:@"photo_file_name"];
		[[SharedStore store] removeImageFromQueueWithFilename:filename];		
	}	

	BizCardArmyAppDelegate *appDelegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
	AccountViewController *accountVC = (AccountViewController *)[[[appDelegate.tabBarController.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0];
	if (accountVC) {
		[accountVC refreshUserInfo];
	}			
	
}

-(void)deleteCard:(Card *)card{
	if (!card) {
		return;
	}
	if (!([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"])) {
		return;
	}
	
	[deleteCardsQueue addObject:card.card_id];
	NSString *filename = [[SharedStore store].cardsImageDictionary valueForKey:[NSString stringWithFormat:@"%d",[card.card_id intValue]]];
	[[SharedStore store] deleteImageWithFilename:filename];
	[[SharedStore store].cardsImageDictionary removeObjectForKey:[NSString stringWithFormat:@"%d",[card.card_id intValue]]];
	[[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].cardsImageDictionary forKey:@"cardsImageDictionary"];
	[[NSUserDefaults standardUserDefaults] setObject:deleteCardsQueue forKey:@"deleteCardsQueue"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self cancelIconDownloadForCard:card];
	
	if ([SharedStore store].hostActive && [deleteCardsQueue count] == 1) {
		[self deleteCardFromWebServer:[card.card_id intValue]];		
	}	

	[self.managedObjectContext deleteObject:card ];	
	[self updateDB];
}

-(void)updateDB{
	NSError *error = nil;
	if ([self.managedObjectContext save:&error]) {
		[self refreshVisibleRows];
	}
}

-(void)saveContactInAB:(Card *)card{
	if ([card.addressbookID isEqualToNumber:[NSNumber numberWithInt:0]] && ([card.status isEqualToString:@"completed"] || [card.status isEqualToString:@"sample"])) {
		NSNumber *addressBookID = [[[NSNumber alloc] initWithInt:0] autorelease];
		
		ABManager *abManager = [[[ABManager alloc] init] autorelease];
		if ([card hasInfo]) {
			addressBookID = [NSNumber numberWithInt:[abManager checkIfDuplicateContact:[self dictionaryForCard:card]]];
		}
		if ([addressBookID isEqualToNumber:[NSNumber numberWithInt:0]]) {
			addressBookID = [NSNumber numberWithInt:[abManager createPerson:[self dictionaryForCard:card]]];
		}
		
		Card *copyCard = [self cardWithId:[card.card_id intValue]];
		if (copyCard && addressBookID) {
			copyCard.addressbookID = addressBookID;
			[self updateDB];
		}				
	}		
}


-(void)refreshVisibleRows{
	NSArray *indexPaths = [self.cardsTable indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in indexPaths) {
		CardsTableCustomCell *cell = (CardsTableCustomCell *)[self.cardsTable cellForRowAtIndexPath:indexPath];
		[self configureCell:cell atIndexPath:indexPath];
	}
}

-(void)updateUserCredits:(NSObject *)user_credits{
    [[SharedStore store].userDictionary setValue:user_credits forKey:@"credit"];            
    [[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].userDictionary forKey:[SharedStore store].currentUser];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Show change of credits in NewCardControlla
    UITabBarController *tabBarController = (UITabBarController *)[[self navigationController] tabBarController];
    NewCardViewController *newcardController =  (NewCardViewController *)[[(UINavigationController *)[tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0];
    if (newcardController) {
        [newcardController showCreditsInfo];            
    }
    
    //Show change of credits in AccountControlla
    BizCardArmyAppDelegate *appDelegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
    AccountViewController *accountVC = (AccountViewController *)[[[appDelegate.tabBarController.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0];
    if (accountVC) {
        [accountVC refreshUserInfo];
    }
}

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.fetchedResultsController = nil;

    [super viewDidUnload];
}

- (void)dealloc {
	for (id key in imageDownloadsInProgress) {
		IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:key];
		if (iconDownloader != nil) {
			if (iconDownloader.connectionImage != nil) {
				[iconDownloader cancelDownload];
				iconDownloader = nil;				
			}
		}
	}
	[imageDownloadsInProgress release];
	
	[cardsTable release];
	[searchBar release];
	[cardsImage release];
	[overlayView release];
	[deleteCardAlertView release];
	[gotoLoginAlertView release];
	[fetchedResultsController release];
	[managedObjectContext release];
	[searchPredicate release];
	[deleteCard release];
	[deleteCardsQueue release];
    [creditPurchaseInfoQueue release];
	[iphoneDB_card_ids release];
	[responseDataSyncCards release];
	[responseDataDeleteCard release];
    [responseDataPurchaseInfo release];
    [super dealloc];
}


@end
