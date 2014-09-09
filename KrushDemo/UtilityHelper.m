//
//  UtilityHelper.m
//  KrushDemo
//
//  Created by Atif Khan on 9/9/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "UtilityHelper.h"

@implementation UtilityHelper

+(NSOperationQueue *)sharedOperationQueue{
    static NSOperationQueue *sharedOpQueue = nil;
    if (!sharedOpQueue) {
        sharedOpQueue = [[NSOperationQueue alloc] init];
        sharedOpQueue.maxConcurrentOperationCount = 3;
    }
    
    return sharedOpQueue;
}

+(NSURLSession *)backgroundDownloadSession{
    @synchronized(self){
        NSURLSession *session = nil;
        if (!session) {
            session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:@"com.norq.download.background"]];
        }
        return session;
    }
}

+(NSURLSession *)defaultDownloadSession{
    @synchronized(self){
        NSURLSession *session = nil;
        if (!session) {
            session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        }
        return session;
    }
}


@end
