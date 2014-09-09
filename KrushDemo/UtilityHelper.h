//
//  UtilityHelper.h
//  KrushDemo
//
//  Created by Atif Khan on 9/9/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilityHelper : NSObject

+(NSOperationQueue *)sharedOperationQueue;

+(NSURLSession *)backgroundDownloadSession;

+(NSURLSession *)defaultDownloadSession;
@end
