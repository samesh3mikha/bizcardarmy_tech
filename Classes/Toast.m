//
//  Toast.m
//  SchoolCalendar
//
//  Created by Bala Bhadra Maharjan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Toast.h"
#import <QuartzCore/QuartzCore.h>

@implementation Toast

@synthesize messageLabel, toastVisibilityDuration, tint, borderOffset;

-(id)init{
	return [self initWithMessage:@""];
}

-(id)initWithMessage:(NSString *)message{
	return [self initWithMessage:message frame:CGRectMake(0, 0, 280, 60)];
}

-(id)initWithMessage:(NSString *)message frame:(CGRect)frame{
	if((self = [super initWithFrame:frame])){
		self.opaque = NO;
		[self.layer setMasksToBounds:YES];
		[self.layer setCornerRadius:10.0];
		
		self.tint = [UIColor colorWithRed:0.42 green:0.53 blue:0.64 alpha:1];
		self.borderOffset = CGSizeMake(5, 5);
		self.toastVisibilityDuration = TOAST_VISIBILITY_DURATION_SHORT;
		
		CGRect r = CGRectMake(borderOffset.width + 5, borderOffset.height + 5, frame.size.width - borderOffset.width * 2 - 10, frame.size.height - borderOffset.height * 2 - 10);
		messageLabel = [[UILabel alloc] initWithFrame:r];
		[messageLabel.layer setCornerRadius:6.0];
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		messageLabel.textAlignment = UITextAlignmentCenter;
		messageLabel.text = message;
		messageLabel.textColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1];
		messageLabel.font = [UIFont boldSystemFontOfSize:16];
		messageLabel.shadowColor = [UIColor whiteColor];
		messageLabel.shadowOffset = CGSizeMake(1, 1);
		messageLabel.lineBreakMode = UILineBreakModeWordWrap;
		messageLabel.numberOfLines = 0;
		[self addSubview:messageLabel];
	}
	return self; 
}

- (void)drawRect:(CGRect)rect {	
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGGradientRef glossGradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 2;
	
	int numComponents = CGColorGetNumberOfComponents(tint.CGColor);
	CGFloat r,g,b,a;
	if (numComponents == 4)
	{
		const CGFloat *components = CGColorGetComponents(tint.CGColor);
		r = components[0];
		g = components[1];
		b = components[2];
		a = components[3];
	}
	else {
		r = 0;
		g = 0;
		b = 0;
		a = 1;
	}

	
	CGFloat locations[2] = { 0.1, 1.0 };
	CGFloat components[8] = { r, g, b, a*0.7,  // Start color
		r, g, b, a*0.9}; // End color
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
	CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
	
	CGGradientRelease(glossGradient);
	CGColorSpaceRelease(rgbColorspace); 
	
	rect = CGRectMake(borderOffset.width, borderOffset.height, rect.size.width - borderOffset.width * 2, rect.size.height - borderOffset.height * 2);
	CGFloat radius = 6;
	
	CGContextSetRGBFillColor(currentContext, 1.0, 1.0, 1.0, 0.5);
	
	CGContextMoveToPoint(currentContext, rect.origin.x, rect.origin.y + radius);
	CGContextAddLineToPoint(currentContext, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGContextAddArc(currentContext, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 4, M_PI / 2, 1);
	CGContextAddLineToPoint(currentContext, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
	CGContextAddArc(currentContext, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
	CGContextAddLineToPoint(currentContext, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGContextAddArc(currentContext, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
	CGContextAddLineToPoint(currentContext, rect.origin.x + radius, rect.origin.y);
	CGContextAddArc(currentContext, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
	
	CGContextFillPath(currentContext);
	
}

-(void)showInView:(UIView *)parentView{
	[self retain];
	self.alpha = 0;
	[parentView addSubview:self];
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishedFadeIn:finished:context:)];
	self.alpha = 1;
	[UIView commitAnimations];
}


-(void)finishedFadeIn:(NSString*)animationID finished:(BOOL)finished context:(void*)context{
	if(self.toastVisibilityDuration != TOAST_VISIBILITY_DURATION_INFINITE)
		[self performSelector:@selector(hide) withObject:nil afterDelay:toastVisibilityDuration];
}

-(void)hide{
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(finishedFadeOut:finished:context:)];
    self.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)finishedFadeOut:(NSString*)animationID finished:(BOOL)finished context:(void*)context{
	[self removeFromSuperview];
	[self release];
}

-(void)setBorderOffset:(CGSize)offsetSize{
	borderOffset = offsetSize;
	CGRect r = CGRectMake(borderOffset.width + 5, borderOffset.height + 5, self.frame.size.width - borderOffset.width * 2 - 10, self.frame.size.height - borderOffset.height * 2 - 10);
	messageLabel.frame = r;
	[self setNeedsDisplay];
}

-(void)restoreDefaultTint{
	self.tint = [UIColor colorWithRed:0.42 green:0.53 blue:0.64 alpha:1];
	[self setNeedsDisplay];
}

-(void)setTint:(UIColor *)color{
	[color retain]; 
	[tint release];
	tint = color;
	[self setNeedsDisplay];
}

-(void)setFrame:(CGRect)aFrame{
	CGRect frame = CGRectMake((int)aFrame.origin.x, (int)aFrame.origin.y, (int)aFrame.size.width, (int)aFrame.size.height);
	super.frame = frame;
	CGRect r = CGRectMake(borderOffset.width + 5, borderOffset.height + 5, frame.size.width - borderOffset.width * 2 - 10, frame.size.height - borderOffset.height * 2 - 10);
	messageLabel.frame = r;
	[self setNeedsDisplay];
}

-(void)dealloc{
	[messageLabel release];
	[tint release];
	[super dealloc];
}

@end
