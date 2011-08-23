//
//  InternetStatus.h
//  BizCardArmy
//
//  Created by IphoneMac on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "SharedStore.h"

@class InternetStatus;

@protocol InternetStatusDelegate <NSObject>
	-(void) updateInternetStatus;
@end

	

@interface InternetStatus : NSObject {
	Reachability *hostReachable, *internetReachable;
	
	id <InternetStatusDelegate> delegate;
}
//---------  PROPERTIES --------- 
@property(nonatomic, assign) id <InternetStatusDelegate> delegate;

//---------  CUSTOM METHODS ---------
-(void)checkInternetConnection;
-(void)checkNetworkStatus:(NSNotification *)notice;

@end
