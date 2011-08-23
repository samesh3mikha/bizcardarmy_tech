//
//  Toast.h
//  SchoolCalendar
//
//  Created by Bala Bhadra Maharjan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/**
 *	A toast is a way of notifiying users about some event in an unintrusive way.
 *	Alerts are more intrusive and stops the flow of the user's interaction with the app.
 *	This class provides similar function to that of android Toast widget hence the name Toast. 
 */

#import <Foundation/Foundation.h>

typedef enum ToastVisibilityDuration{
	TOAST_VISIBILITY_DURATION_SHORT = 1 ,				//Shows the toast for 1 sec
	TOAST_VISIBILITY_DURATION_LONG = 3,					//Shows the toast for 3 sec
	TOAST_VISIBILITY_DURATION_INFINITE = 99999999		//Shows the toast for infinite time
}ToastVisibilityDuration;

@interface Toast : UIView {
@private
	UILabel *messageLabel;
	ToastVisibilityDuration toastVisibilityDuration;
	UIColor *tint;
	CGSize borderOffset;
}

/**
 *	The label to show the message of the toast. This is readonly but
 *	users will be able to change the text
 */
@property (nonatomic, readonly) UILabel *messageLabel;

/**
 *	The duration for the toast to show. If the duration is selected to be
 *	TOAST_VISIBILITY_DURATION_SHORT or TOAST_VISIBILITY_DURATION_LONG, the 
 *	toast will disappear itself after a certain duration but if it is 
 *	TOAST_VISIBILITY_DURATION_INFINITE, it won't disappear itself but hide method
 *	should be used to remove it.
 */
@property (nonatomic, assign) ToastVisibilityDuration toastVisibilityDuration;

/**
 *	The tint of the toast widget.
 */
@property (nonatomic, retain) UIColor *tint;

/**
 *	The border size of the toast widget.
 */
@property (nonatomic, assign) CGSize borderOffset;

/**
 *	Initialize toast with a message string.
 */
-(id)initWithMessage:(NSString *)message;

/**
 *	Initialize toast with a message string and frame.
 */
-(id)initWithMessage:(NSString *)message frame:(CGRect)frame;


/**
 *	Displays the toast in the given view.
 */
-(void)showInView:(UIView *)parentView;

/**
 *	Hides the toast. Use it only if the duration type is TOAST_VISIBILITY_DURATION_INFINITE.
 */
-(void)hide;

/**
 *	Restores the tint of the toast to the default tint color.
 */
-(void)restoreDefaultTint;
@end
