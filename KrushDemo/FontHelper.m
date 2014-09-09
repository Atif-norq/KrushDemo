//
//  FontHelper.m
//  Demo3
//
//  Created by Atif Khan on 4/18/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "FontHelper.h"

@implementation FontHelper

+(UIFont *)fontProximaLightSize:(float) size
{
    return [UIFont fontWithName:@"ProximaNova-Light" size:size];
}

+(UIFont *)fontProximaRegularSize:(float) size
{
    return [UIFont fontWithName:@"ProximaNova-Regular" size:size];
}

+(UIFont *)fontProximaBoldSize:(float) size
{
    return [UIFont fontWithName:@"ProximaNova-Bold" size:size];
}

+(void )printAllFontsAvailable
{
    // Below code reveal all font family availbale to app
    
     NSArray *famillyNames = [UIFont familyNames];
     for (NSString *family in famillyNames) {
     NSArray *fontsName =  [UIFont fontNamesForFamilyName:family];
     NSLog(@"Font names: %@\n%@",family,fontsName);
     }
}
@end
