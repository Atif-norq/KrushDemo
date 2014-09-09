//
//  UIImage+Addition.m
//  Airbnb
//
//  Created by Atif Khan on 4/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "UIImage+Addition.h"

@implementation UIImage (Addition)

-(float)aspectFitHeightForWidth:(float)width
{
    CGSize imageSize = [self size];
    if (imageSize.height == 0) {
        return 0;
    }
    float aspectWByH = imageSize.width/imageSize.height;
    float relativeHeight = width/aspectWByH;
    if (relativeHeight>imageSize.height) {
        return imageSize.height;
    }
    return relativeHeight;
}

-(UIImage *)scaleDownImageMaintaingAspectRatioWithSize:(CGSize) size
{
    size.width = floorf(size.width);
    size.height = floorf(size.height);
    
    CGSize imageSize = [self size];
    
    if (imageSize.width < size.width && imageSize.height < size.height) {
        return self;
    }
    
    // If blank image return self to prevent exception getting aspect ratio
    if (imageSize.height == 0 || imageSize.width == 0) {
        return self;
    }
    
    float imageAspectWByH = imageSize.width/ imageSize.height;
    float imageNewWidth;
    float imageNewHeight;
    if (size.width>size.height) {
        // Resize in width;
        imageNewHeight = size.height;
        imageNewWidth  = size.height * imageAspectWByH;
    }else{
        imageNewWidth = size.width;
        imageNewHeight = size.width/imageAspectWByH;
    }
    imageNewWidth = floorf(imageNewWidth);
    imageNewHeight = floorf(imageNewHeight);
    
    UIGraphicsBeginImageContext(CGSizeMake(imageNewWidth, imageNewHeight));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [self drawInRect:CGRectMake(0, 0, imageNewWidth, imageNewHeight)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

@end
