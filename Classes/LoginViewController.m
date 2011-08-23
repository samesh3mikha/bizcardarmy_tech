//
//  LoginViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"


@implementation LoginViewController

@synthesize loginTable;
@synthesize usernameField;
@synthesize passwordField;
@synthesize loadingSpinner;
@synthesize message;
@synthesize username, password;
@synthesize connectionSignIn;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		responseDataLogin = [[NSMutableData data] retain];	
 	}
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [SharedStore store].backColorForViews;
	loginTable.separatorColor = [SharedStore store].colorForTableSeperators;
	loginTable.backgroundColor = [UIColor clearColor];
	
	UIBarButtonItem *signUp = [[[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStylePlain target:self action:@selector(signUp:)] autorelease];
	self.navigationItem.rightBarButtonItem = signUp;
	self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
	
	[usernameField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	message.textAlignment = UITextAlignmentLeft;
	message.text = @"1) Take photos of your bizcards\n2) Send to our global army of transcribers\n3) Perfectly digitized cards within 24 hours";
}

#pragma mark -
#pragma mark ---------- UITABLEVIEW DELEGATE METHODS ----------

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
	return cell;
}
	
#pragma mark -
#pragma mark ---------- UITEXTFIELD DELEGATE METHODS ----------

-(BOOL)textFieldShouldReturn:(UITextField *)textField {	
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
	[loadingSpinner startAnimating];
	message.textAlignment = UITextAlignmentLeft;
	message.text = @"1) Take photos of your bizcards\n2) Send to our global army of transcribers\n3) Perfectly digitized cards within 24 hours";

	self.username = usernameField.text;
	self.password = passwordField.text;
	if ([SharedStore store].hostActive && ![SharedStore store].userSignedIn) {
		[self signIn];		
	}
	else {
		[self signInOffline];
	}

	return YES;
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(void) signUp:(id)sender {
	SignUpViewController *signUpViewController = [[[SignUpViewController alloc] init] autorelease];
	signUpViewController.title = @"Sign Up";
	[self.navigationController pushViewController:signUpViewController animated:YES];
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)signIn{
	if ([SharedStore store].userSignedIn) {
		return;
	}
	
	NSString *encodedUsername = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)username, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)password, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *content = [NSString stringWithFormat: @"user[email]=%@&user[password]=%@",encodedUsername,encodedPassword];
	[encodedUsername release];
	[encodedPassword release];
	
	NSString *connectionString = [NSString stringWithFormat:@"%@/users/sign_in.json", SERVER_STRING];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
	self.connectionSignIn = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
	if (connectionSignIn) {
		[SharedStore store].signingUser = YES;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

#pragma mark -
#pragma mark ---------- NSURLCONNECTION DELEGATE METHODS ----------

//Connection #1 (www/users/sign_in.json) for Login

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	[responseDataLogin setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseDataLogin appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	[loadingSpinner stopAnimating];
	message.textAlignment = UITextAlignmentCenter;
	message.text = @"Could not connect to the server";	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.connectionSignIn = nil;
	
	[SharedStore store].signingUser = NO;
	[SharedStore store].loginConnectionFailed = YES;
	if ([SharedStore store].dashboardLoaded == YES) {
		[(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] useDashboard];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[loadingSpinner stopAnimating];
	[SharedStore store].signingUser = NO;
	[SharedStore store].loginConnectionFailed = NO;

	//Response --> {"user":{id:1,,,,,}} OR -->{"error":"..."}
	NSString *responseString = [[[NSString alloc] initWithData:responseDataLogin encoding:NSUTF8StringEncoding] autorelease];
	
	if ([responseString characterAtIndex:0]  == '{') {
		NSDictionary *responseDictionary = [responseString JSONValue];
		
		if ([responseDictionary objectForKey:@"error"] != nil) {
		//Couldn't Login
			passwordField.text = @"";
			message.textAlignment = UITextAlignmentCenter;
			message.text = [responseDictionary objectForKey:@"error"];
			
			if ([SharedStore store].dashboardLoaded == YES) {
				[(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] useDashboard];
			}
		}		
		else if ([responseDictionary objectForKey:@"user"] != nil) {			
		//Logged In successfully
			NSDictionary *userResponseDictionary = [responseDictionary objectForKey:@"user"];
			NSMutableDictionary *tempUserDictionary = [[[NSMutableDictionary alloc] init] autorelease];
			
			for (id key in userResponseDictionary) {
				NSObject *value= [[userResponseDictionary objectForKey:key] description];      // We use the (unique) key to access the (possibly non-unique) object.
				
				if ([key isEqualToString:@"email"]) {
					[tempUserDictionary  setValue:[[NSString stringWithFormat:@"%@", value] lowercaseString] forKey:@"email"];
				}
				else if ([key isEqualToString:@"id"]) {
					[tempUserDictionary  setValue:value forKey:@"id"];
				}
				else if ([key isEqualToString:@"credit"]) {
					[tempUserDictionary  setValue:value forKey:@"credit"];
				}
				else if ([key isEqualToString:@"auth_token"]) {
					[tempUserDictionary  setValue:value forKey:@"auth_token"];
				}
			}
			[tempUserDictionary setValue:password forKey:@"password"];
			[[SharedStore store].allUsersDictionary setObject:tempUserDictionary forKey:[[tempUserDictionary valueForKey:@"email"] lowercaseString]];
			[SharedStore store].currentUser = [username lowercaseString];
			[[SharedStore store] initUserDictionary:tempUserDictionary];
			[SharedStore store].userSignedIn = YES;
			[[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].allUsersDictionary forKey:@"allUsersDictionary"];
			[[NSUserDefaults standardUserDefaults] setObject:[tempUserDictionary valueForKey:@"email"] forKey:@"currentUser"];
			[[NSUserDefaults standardUserDefaults] synchronize];					
			
			// Load/Continue With DashBoard
			[(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] useDashboard];
		}
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	self.connectionSignIn = nil;
}

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)signInOffline{
	BOOL signing = NO;
	NSMutableDictionary *tempDictionary = [[[NSMutableDictionary alloc] init] autorelease];
	tempDictionary = [[SharedStore store].allUsersDictionary valueForKey:[username lowercaseString]];
	if (tempDictionary) {
		if ([[tempDictionary valueForKey:@"password"] isEqualToString:password]) {
			[SharedStore store].currentUser = [username lowercaseString];
			[[SharedStore store] initUserDictionary:tempDictionary];
			[SharedStore store].userSignedInOffline = YES;
			[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"currentUser"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			signing = YES;
			[(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] useDashboard];
		}
	}
	
	if (!signing) {
		passwordField.text = @"";
		[SharedStore store].currentUser = @"";
		[SharedStore store].userDictionary = nil;
		[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"currentUser"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[loadingSpinner stopAnimating];
		message.textAlignment = UITextAlignmentCenter;
		message.text = @"Could not connect to the server";			
	}
}

-(void)signInAfterDashboard{
	self.username = [SharedStore store].currentUser;
	self.password = [[SharedStore store].userDictionary valueForKey:@"password"];
	[self signIn];
}

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[loginTable release];
	[usernameField release];
	[passwordField release];
	[loadingSpinner release];
	[message release];
	[username release];
    [password release];
	[responseDataLogin release];
    [super dealloc];
}

@end
