//
//  Downloader.h
//  InfiniteGalleryScroller
//
//  Created by Atif Khan on 4/21/13.
//  Copyright (c) 2013 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloaderResponseDelegate.h"
#import "UIImage+Addition.h"
#import "NSMutableURLRequest+RequestHeaderTypeAddition.h"

@interface Downloader : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    NSURL *linkDownloading;
    BOOL downloadFailed;
    BOOL autoStartEnabled;
    BOOL isDownloadDone;
    BOOL foundCacheData;
    int itemIndex;
    float percentDone;
    id <DownloaderResponseDelegate>downloadDelegate;
    NSURLConnection *connection;
}
@property (nonatomic, readonly) NSURLConnection *connection;
@property (nonatomic, weak) id <DownloaderResponseDelegate>downloadDelegate;
@property (nonatomic, assign) BOOL foundCacheData;
@property (nonatomic, assign) float percentDone;
@property (nonatomic, assign) BOOL isDownloadDone;
@property (nonatomic, assign)   int itemIndex;
@property (nonatomic, weak) id tagObject;
@property (nonatomic, readonly) BOOL downloadFailed;
@property (nonatomic, readonly) NSURL *linkDownloading;
@property (nonatomic, readonly) NSMutableData *mData;
@property (nonatomic, readonly) NSMutableURLRequest * request;
@property (nonatomic, assign) int networkStatusCode;
-(NSData *)cachedDataIfAvailable;
-(UIImage *)cachedImageIfAvailable;
-(UIImage *)cachedAspectFitImageIfAvailableWithSize:(CGSize)maxSize;

/// This method doesn't auto start download. It provide a cache block which will be called snychronously. It can be nil
-(instancetype )initWithURL:(NSURL *)link cachePolicy:(NSURLRequestCachePolicy )policy delegate:(id <DownloaderResponseDelegate>)delegate timeInterval:(NSTimeInterval )timeInterval cacheData:(void (^)(NSData *cachedData))completion;

/// This method doesn't auto start download. It provide a cache block which will be called snychronously. It can be nil
-(instancetype )initWithURL:(NSURL *)link cachePolicy:(NSURLRequestCachePolicy )policy delegate:(id <DownloaderResponseDelegate>)delegate timeInterval:(NSTimeInterval )timeInterval cacheImage:(void (^)(UIImage *cachedImage))completion;

/// This method doesn't auto start download. It provide a cache block which will be called snychronously. It can be nil
-(instancetype )initWithURL:(NSURL *)link cachePolicy:(NSURLRequestCachePolicy )policy delegate:(id <DownloaderResponseDelegate>)delegate timeInterval:(NSTimeInterval )timeInterval cacheAspectFitImage:(void (^)(UIImage *cachedImage))completion withMaxSize:(CGSize )maxSize;


-(instancetype)initWithURLLink:(NSURL*)link cahcePolicy:(NSURLRequestCachePolicy)policy delegate:(id<DownloaderResponseDelegate>)delegate;
-(instancetype)initWithRequest:(NSMutableURLRequest*)mRequest cachePolicy:(NSURLRequestCachePolicy)policy delegate:(id<DownloaderResponseDelegate>)delegate autoStartEnabled:(BOOL)isAutoStartAllowed;

-(instancetype)initWithURLLink:(NSURL*)link cachePolicy:(NSURLRequestCachePolicy)policy  request:(NSMutableURLRequest*)mRequest delegate:(id<DownloaderResponseDelegate>)delegate autoStartEnabled:(BOOL)isAutoStartAllowed;
-(instancetype)initWithURLLink:(NSURL*)link cahcePolicy:(NSURLRequestCachePolicy)policy delegate:(id<DownloaderResponseDelegate>)delegate autoStartEnabled:(BOOL)isAutoStartAllowed;


-(void)cancel;
-(void)startByAsynchronusMethod;
-(void)start;
-(void)resetData;
-(NSURLResponse*)response;

+(NSData*)cachedDataForURL:(NSURL*)url;
+(UIImage*)cachedImageForURL:(NSURL*)url withPrefferredSize:(CGSize)size;
+(UIImage*)cachedImageForURL:(NSURL*)url;

+(NSOperationQueue *)sharedQueue;

@end
