//
//  BizCardArmyAppDelegate.m
//  BizCardArmy
//
//  Created by Bala Bhadra Maharjan on 11/9/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "BizCardArmyAppDelegate.h"
#import "LoginViewController.h"
#import "DashboardViewController.h"
#import "NewCardViewController.h"
#import "AccountViewController.h"


@implementation BizCardArmyAppDelegate

@synthesize window;
@synthesize internetStatus;
@synthesize loginNavigationController; 
@synthesize loginViewController;
@synthesize tabBarController;
@synthesize managedObjectContext;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	[SharedStore store];
	[SharedStore store].managedObjectContext = self.managedObjectContext;
	
	//Check Internet Status
	self.internetStatus = [[[InternetStatus alloc] init] autorelease];
	[internetStatus checkInternetConnection];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"allUsersDictionary"] != nil ) {		
		[SharedStore store].allUsersDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"allUsersDictionary"];
	}
	
	if (![SharedStore store].allUsersDictionary || [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"] == nil ) {		
	//Load LoginView if STANDARDUSERDEFAULT doesnt have complete(email/password/userID) User information
		[self loadLoginView];
	}
	else {
	//Load Dashboard if STANDARDUSERDEFAULT has complete(email/password/userID) User information
		[SharedStore store].currentUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];		
		[[SharedStore store] initUserDictionary:[[SharedStore store].allUsersDictionary objectForKey:[SharedStore store].currentUser]];
		[SharedStore store].userSignedInOffline = YES;
		
		//Load DashBoard
		[self useDashboard];
	}
	
    [window makeKeyAndVisible];
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"bca.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark CUSTOM METHODS
-(void)gotoLoginPage{
	[tabBarController.view removeFromSuperview];
	self.tabBarController = nil;
	
	[self loadLoginView];
}

-(void)loadLoginView{
	self.loginViewController = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
	loginViewController.title = @"Login";
	self.loginNavigationController = [[[UINavigationController alloc] initWithRootViewController:loginViewController] autorelease];
	loginNavigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
	[window addSubview:loginNavigationController.view];	
}

-(void)useDashboard{
	if ([SharedStore store].dashboardLoaded == NO) {
	//DASHBOARD not loaded yet
		[loginNavigationController.view removeFromSuperview];
		
		self.tabBarController = [[[UITabBarController alloc] init] autorelease];
		
		DashboardViewController *dashboardViewController = [[[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:nil] autorelease];
		dashboardViewController.title = @"My Cards";
		dashboardViewController.managedObjectContext = self.managedObjectContext;
		UINavigationController *dashboardNavigationController = [[[UINavigationController alloc] initWithRootViewController:dashboardViewController] autorelease];
		dashboardNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"My Cards" image:[UIImage imageNamed:@"dashboard.png"] tag:0] autorelease];
		dashboardNavigationController.navigationBar.tintColor = [SharedStore store].navigationBarColor;
		
		NewCardViewController *newCardViewController = [[[NewCardViewController alloc] initWithNibName:@"NewCardViewController" bundle:nil] autorelease];
		newCardViewController.title = @"New Card";
		newCardViewController.managedObjectContext	= self.managedObjectContext;
		UINavigationController *newCardNavigationController = [[[UINavigationController alloc] initWithRootViewController:newCardViewController] autorelease];
		newCardNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"New Card" image:[UIImage imageNamed:@"newcard.png"] tag:1] autorelease];
		newCardNavigationController.navigationBar.tintColor = [SharedStore store].navigationBarColor;
		
		AccountViewController *accountViewController = [[[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] autorelease];
		accountViewController.title = @"Account";
		accountViewController.managedObjectContext = self.managedObjectContext;
		UINavigationController *accountNavigationController = [[[UINavigationController alloc] initWithRootViewController:accountViewController] autorelease];
		accountNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Account" image:[UIImage imageNamed:@"account.png"] tag:2] autorelease];
		accountNavigationController.navigationBar.tintColor = [SharedStore store].navigationBarColor;
		
		internetStatus.delegate = dashboardViewController;
		accountViewController.delegate = newCardViewController;
		newCardViewController.delegate  = dashboardViewController;
		
		tabBarController.viewControllers = [NSArray arrayWithObjects:dashboardNavigationController, newCardNavigationController, accountNavigationController, nil];
		
		[window addSubview:tabBarController.view];
	}
	else if (([SharedStore store].hostActive && [SharedStore store].userSignedIn) || ([SharedStore store].userSignedInOffline)) {
	//DASHBOARD already loaded
		[(DashboardViewController *)[[(UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0] releaseLoginController];
	}
}	


#pragma mark - 
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    [window release];
	[internetStatus release];
	[loginNavigationController release];
	[loginViewController release];
	[tabBarController release];
	
    [super dealloc];
}


@end
