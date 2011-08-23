//
//  BizCardArmyAppDelegate.h
//  BizCardArmy
//
//  Created by Bala Bhadra Maharjan on 11/9/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedStore.h"
#import "InternetStatus.h"

@class LoginViewController;

@interface BizCardArmyAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	InternetStatus *internetStatus;
	UINavigationController *loginNavigationController;
	LoginViewController *loginViewController;
	UITabBarController *tabBarController;
	
	NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;	
}
//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) InternetStatus *internetStatus;
@property (nonatomic, retain) UINavigationController *loginNavigationController;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;


//---------  CUSTOM METHODS ---------
-(void)gotoLoginPage;
-(void)loadLoginView;
-(void)useDashboard;

@end

