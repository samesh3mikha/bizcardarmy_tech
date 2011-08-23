//
//  SortingOtionsViewController.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SortingOtionsViewController.h"


@implementation SortingOtionsViewController

@synthesize sortOptionsTable;
@synthesize sortingOptions;
@synthesize currentSortingOptionIndexPath;
@synthesize currentSortingOrderIndexPath;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [SharedStore store].backColorForViews;
	sortOptionsTable.separatorColor = [SharedStore store].colorForTableSeperators;
	sortOptionsTable.backgroundColor = [UIColor clearColor];
	
	self.sortingOptions = [NSArray arrayWithObjects:@"First Name", @"Last Name", @"Company", @"Status", @"City", @"Date Created", nil];
}

-(void)viewWillDisappear:(BOOL)animated{
	[[NSUserDefaults standardUserDefaults] setInteger:[SharedStore store].currentSortingOption forKey:@"currentSortingOption"];
	[[NSUserDefaults standardUserDefaults] setBool:[SharedStore store].currentSortingOrderAsc forKey:@"currentSortingOrderAsc"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark ---------- UITABLEVIEW DEFAULT METHODS ----------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger numRows;
	if (section == 0) {
		numRows = [sortingOptions count];
	}	
	else if (section == 1){
		numRows = 2;
	}

	return numRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell...
	[cell.textLabel setFont:[UIFont systemFontOfSize:16]];
	cell.textLabel.textColor = [UIColor darkGrayColor];

	if (indexPath.section == 0) {
		cell.textLabel.text = [sortingOptions objectAtIndex:indexPath.row]; 
		if (indexPath.row == [SharedStore store].currentSortingOption) {
			self.currentSortingOptionIndexPath = indexPath;
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		}		
	}
	else if(indexPath.section == 1){
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Ascending";
		}
		else if (indexPath.row == 1) {
			cell.textLabel.text = @"Descending";
		}
		NSInteger order = [SharedStore store].currentSortingOrderAsc ? 0 : 1;
		if (indexPath.row == order) {
			self.currentSortingOrderIndexPath = indexPath;
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];	
		}
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row != [SharedStore store].currentSortingOption) {
			[[tableView cellForRowAtIndexPath:currentSortingOptionIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
			
			[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
			self.currentSortingOptionIndexPath = indexPath;
			[SharedStore store].currentSortingOption = indexPath.row;		
		}
	}
	else if (indexPath.section == 1) {
		NSInteger order = [SharedStore store].currentSortingOrderAsc ? 0:1;
		if (indexPath.row != order ) {
			[[tableView cellForRowAtIndexPath:currentSortingOrderIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
			
			[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
			self.currentSortingOrderIndexPath = indexPath;
			[SharedStore store].currentSortingOrderAsc = indexPath.row == 0 ? YES : NO;
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];				
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40.0;
}


#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[sortOptionsTable release];
	[sortingOptions release];
	[currentSortingOptionIndexPath release];
	[currentSortingOrderIndexPath release];

    [super dealloc];
}


@end
