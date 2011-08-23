//
//  EditFieldCell.m
//  TableEdit
//
//  Created by IphoneMac on 1/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditFieldCell.h"


@implementation EditFieldCell

@synthesize textField;
@synthesize fieldLabel;
@synthesize delegate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark ---------- UITEXTFIELD DELEGATE METHODS ----------

- (void)textFieldDidBeginEditing:(UITextField *)tf {
	[delegate relocateScrollView:self.frame];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField {		
	[self.textField resignFirstResponder];
	[delegate shrinkScrollContent];
	return YES;
}



- (void)dealloc {  
    [fieldLabel, textField release];
    [super dealloc];  
}  


@end
