//
//  CardsTableCustomCell.h
//  BizCardArmy
//
//  Created by IphoneMac on 11/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardsTableCustomCell : UITableViewCell {
	IBOutlet UIImageView *cardImageView;	
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *detailLabel;
	IBOutlet UIImageView *statusImage;	
}

//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UIImageView *cardImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailLabel;
@property (nonatomic, retain) IBOutlet UIImageView *statusImage;

@end
