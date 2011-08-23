//
//  SignUpViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SignUpViewController.h"

@implementation SignUpViewController

@synthesize signUpTable;
@synthesize usernameField;
@synthesize passwordField;
@synthesize confirmPasswordField;
@synthesize loadingSpinner;
@synthesize message;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	responseDataSignUp = [[NSMutableData data] retain];	
		
	self.view.backgroundColor = [SharedStore store].backColorForViews;
	signUpTable.separatorColor = [SharedStore store].colorForTableSeperators;
	signUpTable.backgroundColor = [UIColor clearColor];
	
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
    return 3;
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
	[confirmPasswordField resignFirstResponder];
	[loadingSpinner startAnimating];

	[self signUp];
	return YES;
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)signUp{
	NSString *encodedUsername = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)usernameField.text,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedPassword = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)passwordField.text,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedPasswordConfirm = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)confirmPasswordField.text,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString* content = [NSString stringWithFormat: @"user[email]=%@&user[password]=%@&user[password_confirmation]=%@",encodedUsername,encodedPassword, encodedPasswordConfirm];
	[encodedUsername release];
	[encodedPassword release];
	[encodedPasswordConfirm release];
	
	NSString *connectionString = [NSString stringWithFormat:@"%@/users.json", SERVER_STRING];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
	NSURLConnection *connectionSignUp = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionSignUp) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}		
}

#pragma mark -
#pragma mark  ---------- NSURLCONNECTION DELEGATE METHODS ----------

//Connection #1 (www/users.json)[POST] for SignUp

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	[responseDataSignUp setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseDataSignUp appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {	
	[loadingSpinner stopAnimating];
	message.textAlignment = UITextAlignmentCenter;
	message.text = @"Could not connect to the server";	

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	[loadingSpinner stopAnimating];
	
	//Response --> {"user":{id:1,,,,,}} OR -->{"email":"email invalid"} OR -->{"password":"password invalid"}
	NSString *responseString = [[[NSString alloc] initWithData:responseDataSignUp encoding:NSUTF8StringEncoding] autorelease];
	
	if ([responseString characterAtIndex:0]  == '{') {
		NSDictionary *responseDictionary = [responseString JSONValue];
		
		if ([responseDictionary objectForKey:@"email"] != nil) {
			message.textAlignment = UITextAlignmentCenter;
			message.text = [NSString stringWithFormat:@"email %@", [responseDictionary objectForKey:@"email"]];
		}
		else if ([responseDictionary objectForKey:@"password"] != nil) {
			message.textAlignment = UITextAlignmentCenter;
			message.text = [NSString stringWithFormat:@" password %@", [responseDictionary objectForKey:@"password"]];
		}
		else if ([responseDictionary objectForKey:@"user"] != nil) {
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
			[tempUserDictionary setValue:passwordField.text forKey:@"password"];
			[[SharedStore store].allUsersDictionary setObject:tempUserDictionary forKey:[[tempUserDictionary valueForKey:@"email"] lowercaseString]];
			[SharedStore store].currentUser =  [(NSString *)usernameField.text lowercaseString];
			[[SharedStore store] initUserDictionary:tempUserDictionary];
			[SharedStore store].userSignedIn = YES;
			[[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].allUsersDictionary forKey:@"allUsersDictionary"];
			[[NSUserDefaults standardUserDefaults] setObject:[tempUserDictionary valueForKey:@"email"] forKey:@"currentUser"];
			[[NSUserDefaults standardUserDefaults] synchronize];					
			
			// Load/Continue With DashBoard
			[SharedStore store].userSignedUp = YES;
			[(BizCardArmyAppDelegate *)[[UIApplication sharedApplication] delegate] useDashboard];
		}		
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[connection release];
}

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[signUpTable release];
	[usernameField release];
	[passwordField release];
	[confirmPasswordField release];
	[loadingSpinner release];
	[message release];
	[responseDataSignUp release];
    [super dealloc];
}


@end
