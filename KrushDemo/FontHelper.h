//
//  FontHelper.h
//  Demo3
//
//  Created by Atif Khan on 4/18/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "ChalkboardSE-Light",
 "ChalkboardSE-Regular",
 "ChalkboardSE-Bold"
 
 Streetwear
 */

@interface FontHelper : NSObject

+(UIFont *)fontProximaLightSize:(float) size;
+(UIFont *)fontProximaRegularSize:(float) size;
+(UIFont *)fontProximaBoldSize:(float) size;

+(void )printAllFontsAvailable;

@end
