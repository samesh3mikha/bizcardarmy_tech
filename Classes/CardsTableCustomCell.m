//
//  CardsTableCustomCell.m
//  BizCardArmy
//
//  Created by IphoneMac on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CardsTableCustomCell.h"


@implementation CardsTableCustomCell

@synthesize cardImageView;
@synthesize nameLabel;
@synthesize detailLabel;
@synthesize statusImage;

#pragma mark -
#pragma mark ---------- SELF METHODS ----------

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

- (void)setHighlighted:(BOOL)isHighlighted {
	
    /* Overridden to do nothing if superview is selected or highlighted */
	
    UITableViewCell* theCell = (UITableViewCell*) self.superview;
	
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        if ([theCell isSelected] || [theCell isHighlighted])
            return;
    }
	
    [super setHighlighted:isHighlighted];
}

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------

- (void)dealloc {
	[cardImageView release];
	[nameLabel release];
	[detailLabel release];
	[statusImage release];
    [super dealloc];
}

@end
