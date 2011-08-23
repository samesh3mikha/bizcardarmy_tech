//
//  SortingOtionsViewController.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedStore.h"


@interface SortingOtionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *sortOptionsTable;
	
	NSArray *sortingOptions;
	NSIndexPath *currentSortingOptionIndexPath;
	NSIndexPath *currentSortingOrderIndexPath;
}

//---------  PROPERTIES --------- 
@property(nonatomic, retain) IBOutlet UITableView *sortOptionsTable;
@property(nonatomic, retain) NSArray *sortingOptions;
@property(nonatomic, retain) NSIndexPath *currentSortingOptionIndexPath;
@property(nonatomic, retain) NSIndexPath *currentSortingOrderIndexPath;

@end
