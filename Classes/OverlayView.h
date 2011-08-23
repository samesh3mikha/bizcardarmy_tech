//
//  OverlayView.h
//  SchoolCalendar
//
//  Created by Bala Bhadra Maharjan on 7/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/**
 *	Used to show a dark overlay over a view.
 */

#import <Foundation/Foundation.h>

@interface OverlayView : UIView {
	BOOL isActive;
	CGFloat opacity, animDuration;
	UIColor *color;
}

//---------  PROPERTIES --------- 
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) CGFloat animDuration;
@property (nonatomic, retain) UIColor *color;

-(id)initWithFrame:(CGRect)frame opacity:(CGFloat)anOpacity color:(UIColor *)color animDuration:(CGFloat)duration;
-(void)showInView:(UIView *)parentView withActivityIndicator:(BOOL)indicator;
-(void)hide;
@end
