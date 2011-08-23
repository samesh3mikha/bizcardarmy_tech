//
//  EditFieldCell.h
//  TableEdit
//
//  Created by IphoneMac on 1/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"SharedStore.h"


@class EditFieldCell;  

@protocol EditFieldCellDelegate <NSObject>
	// we will make one function mandatory to include
	-(void)relocateScrollView:(CGRect)cellFrame;
	-(void)shrinkScrollContent;

	@optional  
	// and the other one is optional (this function has not been used in this tutorial)  
	//- (void)editStarted:(UITextField *)field;  
@end  


@interface EditFieldCell : UITableViewCell <UITextFieldDelegate> {  
	IBOutlet UILabel *fieldLabel;
    IBOutlet UITextField *textField;
		
    id <EditFieldCellDelegate> delegate;  
}  
@property (nonatomic, retain) IBOutlet UILabel *fieldLabel;
@property (nonatomic, retain) IBOutlet UITextField *textField;  
@property (nonatomic, assign) id <EditFieldCellDelegate> delegate;  

@end
