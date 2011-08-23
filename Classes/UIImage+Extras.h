//
//  UIImage+Extras.h
//  BizCardArmy
//
//  Created by STS-084 STS on 1/25/11.
//  Copyright 2011 Sprout Technology. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (Extras)
+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledProportionallyToSize:(CGSize)targetSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)imageSize;
@end

