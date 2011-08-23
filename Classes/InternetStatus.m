//
//  InternetStatus.m
//  BizCardArmy
//
//  Created by IphoneMac on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InternetStatus.h"


@implementation InternetStatus

@synthesize delegate;

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)checkInternetConnection{
	// check for internet connection
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];

	// check if a pathway to a random host exists
	hostReachable = [[Reachability reachabilityWithHostName: @"www.bizcardarmy.com"] retain];
	[hostReachable startNotifier];		

	// now patiently wait for the notification	
}

- (void) checkNetworkStatus:(NSNotification *)notice{
	// called after network status changes
	

	NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
	switch (hostStatus)
	{
		case NotReachable:
		{
			[SharedStore store].hostActive = NO;
			break;
		}
		case ReachableViaWiFi:
		{
			[SharedStore store].hostActive = YES;
			break;
		}
		case ReachableViaWWAN:
		{
			[SharedStore store].hostActive = YES;
			break;
		}
		default:
		{
			[SharedStore store].hostActive = NO;
			break;
		}
	}
	
	if ([SharedStore store].dashboardLoaded) {
		[delegate updateInternetStatus];		
	}
}

@end
