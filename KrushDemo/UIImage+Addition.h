//
//  UIImage+Addition.h
//  Airbnb
//
//  Created by Atif Khan on 4/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Addition)

-(float)aspectFitHeightForWidth:(float)width;

-(UIImage *)scaleDownImageMaintaingAspectRatioWithSize:(CGSize) size;

@end
