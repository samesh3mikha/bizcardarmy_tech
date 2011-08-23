//
//  AccountViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountViewController.h"
#import "Toast.h"
#import "BizCardArmyAppDelegate.h"

@implementation AccountViewController

@synthesize accountOptionsTable;
@synthesize userInfoLabel;
@synthesize userInfoValue;
@synthesize managedObjectContext;
@synthesize connectionGetUserIfo;
@synthesize delegate;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization        
        responseDataGetUserIfo = [[NSMutableData alloc] init];

		self.userInfoLabel = [[[NSMutableArray alloc] init] autorelease];
		self.userInfoValue = [[[NSMutableArray alloc] init] autorelease];	
		
		[userInfoLabel addObject:[NSArray arrayWithObjects:@"User",nil]];
		[userInfoLabel addObject:[NSArray arrayWithObjects:@"Credits (Need More?)",@"Pending Cards",@"Unpaid Cards",nil]];
		[userInfoLabel addObject:[NSArray arrayWithObjects:@"Help",@"About",nil]];		
	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	UIBarButtonItem *logOut = [[[UIBarButtonItem alloc] initWithTitle:@"Sign out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutOfSystem:)] autorelease];
	self.navigationItem.rightBarButtonItem = logOut;
	self.view.backgroundColor = [SharedStore store].backColorForViews;
	accountOptionsTable.separatorColor = [SharedStore store].colorForTableSeperators;
	accountOptionsTable.backgroundColor = [UIColor clearColor];
			
	[self refreshUserInfo];
}

#pragma mark -
#pragma mark ---------- UITABLEVIEW DELEGATE METHODS ----------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [userInfoLabel count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [[userInfoLabel objectAtIndex:section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell...
	[cell.textLabel setFont:[UIFont systemFontOfSize:16]];
	cell.textLabel.textColor = [UIColor darkGrayColor];
	cell.textLabel.text = [[userInfoLabel objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]; 
	if (indexPath.section < 2) {
		cell.detailTextLabel.text = [[userInfoValue objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	}
	else if (indexPath.section == 2) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	if (!((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2))) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if (indexPath.section == 1 && indexPath.row == 0) {
		//[self showPaypalWebView];
        //[self askUserToBuyCreditThroughWeb];
        [self showBuyCreditsView];
	}
	else if	(indexPath.section == 2 && indexPath.row == 0) {
		StaticPageController *help = [[[StaticPageController alloc] initWithNibName:@"Help" bundle:nil] autorelease];
		help.title = @"Help";
		[self.navigationController pushViewController:help animated:YES];
		NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
		[help.webView loadHTMLString:content baseURL:nil];
	}
	else if	(indexPath.section == 2 && indexPath.row == 1) {
		StaticPageController *about = [[[StaticPageController alloc] initWithNibName:@"About" bundle:nil] autorelease];
		about.title = @"About Us";
		[self.navigationController pushViewController:about animated:YES];			
	}
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)logOutOfSystem:(id)sender{
	UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
	[alert setTitle:@"Sign out"];
	[alert setMessage:@"Are you sure you want to sign out?"];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setDelegate:self];
    [alert setTag:2];
	[alert show];
}

#pragma mark -
#pragma mark ---------- UIALERTVIEW DELEGATE METHODS ----------

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/sign_in?mobile=true",SERVER_STRING]]];
        }
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            NSArray *cookies = [cookieStore cookiesForURL:[NSURL URLWithString:SERVER_STRING]];
            
            for (NSHTTPCookie * cookie in cookies){
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }			
            
            [SharedStore store].loginConnectionFailed = NO;
            [SharedStore store].dashboardLoaded = NO;
            [SharedStore store].userSignedIn = NO;
            [SharedStore store].userSignedInOffline = NO;
            [SharedStore store].userSignedUp = NO;
            [SharedStore store].currentUser = nil;
            [SharedStore store].userDictionary = nil;	
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"currentUser"];
            [[NSUserDefaults standardUserDefaults] synchronize];	
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [delegate CancelUrlConnections];
            
            BizCardArmyAppDelegate *appDelegate = (BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(gotoLoginPage) withObject:nil afterDelay:0.3];
            
        }
    }
}

#pragma mark -
#pragma mark ---------- PAYPALWEBVIEWCONTROLLER DELEGATE METHODS ----------

-(void)callGetUserCreditInfo{
	[self getUserCreditInfo];
}


-(void)CancelUrlConnections{
	[delegate CancelUrlConnections];
	if (connectionGetUserIfo != nil) {
		[connectionGetUserIfo cancel];
		self.connectionGetUserIfo = nil;
	}
	[SharedStore store].uploadingCards = NO;
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)getUserCreditInfo{
	NSString *connectionString = [NSString stringWithFormat:@"%@/show.json", SERVER_STRING];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"GET"];
	connectionGetUserIfo = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionGetUserIfo) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}	
}

#pragma mark -
#pragma mark  ---------- NSURLCONNECTION DELEGATE METHODS ----------

//Connection #1 (www/show.json) for getting Current user info, user-credits to be exact

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	[responseDataGetUserIfo setLength:0];		
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseDataGetUserIfo appendData:data];		
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.connectionGetUserIfo = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	if (![SharedStore store].currentUser || ![SharedStore store].userDictionary) {
		return;
	}
	
	//Response --> {"user":{id:1,,,,,}}
	NSString *responseString = [[[NSString alloc] initWithData:responseDataGetUserIfo encoding:NSUTF8StringEncoding] autorelease];
	NSString *credits;
	
	if ([responseString characterAtIndex:0]  == '{') {
		NSDictionary *responseDictionary = [responseString JSONValue];
		
		if ([responseDictionary objectForKey:@"user"] != nil) {
			NSDictionary *userResponseDictionary = [responseDictionary objectForKey:@"user"];
			credits = [[userResponseDictionary valueForKey:@"credit"] description];
			
			if (![credits isEqualToString:[[SharedStore store].userDictionary valueForKey:@"credit"]]) {
				[[SharedStore store].userDictionary setValue:credits forKey:@"credit"];
				
				[[SharedStore store].allUsersDictionary setObject:[SharedStore store].userDictionary forKey:[[SharedStore store].userDictionary valueForKey:@"email"]];
				[[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].allUsersDictionary forKey:@"allUsersDictionary"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[self refreshUserInfo];
				[delegate refreshUserCredit];
			}
		}		
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.connectionGetUserIfo = nil;
}

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)showPaypalWebView{
	if (![SharedStore store].hostActive) {
		Toast *toast = [[[Toast alloc] initWithMessage:@"Could not connect to the server"] autorelease];
		toast.frame = CGRectMake(20, 300, 280, 50);
		toast.borderOffset = CGSizeMake(2, 2);
		toast.tint = [UIColor orangeColor];
		toast.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;					
		[toast showInView: [(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] window]];
		return;
	}
	
	PaypalWebViewController *paypalWebViewController = [[[PaypalWebViewController alloc] init] autorelease];
	paypalWebViewController.title = @"Buy Credits";
	paypalWebViewController.delegate = self;
	[self presentModalViewController:paypalWebViewController animated:YES];	
}

-(void)askUserToBuyCreditThroughWeb{    
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
	[alert setTitle:@"Need more Credits?"];
	[alert setMessage:@"Credits are only available through your web account at BizcardArmy.com. Want to open Safari and login now?"];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setDelegate:self];
    [alert setTag:1];
	[alert show];
}

-(void)showBuyCreditsView{
    BuyCreditsViewController *buyCreditsViewController = [[[BuyCreditsViewController alloc] init] autorelease];
    buyCreditsViewController.title = @"Buy Credits";
    [self presentModalViewController:buyCreditsViewController animated:YES];
}

//This method acts as both <custom> method N <BuyCreditDelegate> method
-(void)refreshUserInfo{
	//FETCH NUMBER OF PENDING CARDS IN DB
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:managedObjectContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %@ && user_id = %@", @"pending", [[SharedStore store].userDictionary valueForKey:@"id"]];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *cards = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	NSString *numPendingCards =[NSString stringWithFormat:@"%d",[cards count]];
	
	//FETCH NUMBER OF UNPAID CARDS IN DB
	predicate = [NSPredicate predicateWithFormat:@"status = %@ && user_id = %@", @"unpaid", [[SharedStore store].userDictionary valueForKey:@"id"]];
	[fetchRequest setPredicate:predicate];
	error = nil;
	cards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	NSString *numUnpaidCards =[NSString stringWithFormat:@"%d",[cards count]];
	
	[userInfoValue removeAllObjects];
	[userInfoValue addObject:[NSArray arrayWithObjects:[[SharedStore store].userDictionary valueForKey:@"email"],nil]];
	[userInfoValue addObject:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[[SharedStore store].userDictionary valueForKey:@"credit"]], numPendingCards, numUnpaidCards,nil]];
	
	[accountOptionsTable reloadData];
}

#pragma mark -
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[accountOptionsTable release];
	[userInfoLabel release];
	[userInfoValue release];
	[managedObjectContext release];
	[responseDataGetUserIfo release];
    [super dealloc];
}


@end
