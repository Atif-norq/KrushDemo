//
//  Downloader.m
//  InfiniteGalleryScroller
//
//  Created by Atif Khan on 4/21/13.
//  Copyright (c) 2013 Norq Solutions. All rights reserved.
//

#import "Downloader.h"
#import "UIImage+Addition.h"
//#import "WebServiceDataHandler.h"
//#import "ShopexAppDelegate_iPhone.h"

#define NetworkTimeOutInSeconds 10.f

@interface Downloader(){
    long long expectedlen;
    BOOL downloadStarted;
    NSURLResponse *downloadResponse;
    NSMutableData *mData;
    NSMutableURLRequest *request_;
}
@end

@implementation Downloader
@synthesize downloadFailed;
@synthesize linkDownloading;
@synthesize itemIndex;
@synthesize isDownloadDone;
@synthesize percentDone;
@synthesize foundCacheData;
@synthesize connection;
@synthesize downloadDelegate = _downloadDelegate;
@synthesize tagObject = _tagObject;

+(NSOperationQueue *)downloaderDelegateQueue
{
    static NSOperationQueue *queue = nil;
    if (!queue) {
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
    }
    return queue;
}

-(NSMutableURLRequest *)request
{
    return request_;
}

-(NSData *)cachedDataIfAvailable
{
    NSCachedURLResponse *cResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request_];
    if (cResponse)
    {
        __block NSData *data = cResponse.data;
        if (data.length>0) {
            return [NSMutableData dataWithData:data];
        }
    }
    
    return nil;
}

-(UIImage *)cachedImageIfAvailable
{
    NSData *data = [self cachedDataIfAvailable];
    if (data.length>0) {
        return [UIImage imageWithData:data];
    }
    return nil;
}

-(UIImage *)cachedAspectFitImageIfAvailableWithSize:(CGSize)maxSize
{
    UIImage *image = [self cachedImageIfAvailable];
    UIImage *newImage = [image scaleDownImageMaintaingAspectRatioWithSize:maxSize];
    return newImage;
}

-(void)cancel{
    self.downloadDelegate =nil;
    downloadFailed = YES;
    [connection cancel];
    mData = nil;
    connection = nil;
}

-(id)init
{
    self = [super init];
    if (self) {
        expectedlen = 0;
        autoStartEnabled = NO;
        downloadFailed = NO;
        linkDownloading = nil;
        self.downloadDelegate = nil;
        foundCacheData = NO;
    }
    return self;
}

-(instancetype)initWithRequest:(NSMutableURLRequest*)mRequest cachePolicy:(NSURLRequestCachePolicy)policy delegate:(id<DownloaderResponseDelegate>)delegate autoStartEnabled:(BOOL)isAutoStartAllowed{
    return [self initWithURLLink:nil cachePolicy:policy request:mRequest delegate:delegate autoStartEnabled:isAutoStartAllowed];
}


-(id)initWithURLLink:(NSURL*)link cachePolicy:(NSURLRequestCachePolicy)policy  request:(NSMutableURLRequest*)mRequest delegate:(id<DownloaderResponseDelegate>)delegate autoStartEnabled:(BOOL)isAutoStartAllowed{
    if (self = [super init]) {
        expectedlen = 0;
        autoStartEnabled = isAutoStartAllowed;
        downloadFailed = NO;
        linkDownloading = link;
        self.downloadDelegate = delegate;
        foundCacheData = NO;
        NSMutableURLRequest *request = mRequest;
        
        if (!request) {
            
            request = [NSMutableURLRequest requestWithURL:linkDownloading cachePolicy:policy timeoutInterval:NetworkTimeOutInSeconds];
            //[ShopexAppDelegate_iPhone addCustomUserAgentInMRequest:request];

        }
        
        if (policy == NSURLRequestReturnCacheDataElseLoad || policy == NSURLRequestReturnCacheDataDontLoad) {
            NSCachedURLResponse *cResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
            if (cResponse)
            {
                __block NSData *data = cResponse.data;
                if (data.length>0) {
                    isDownloadDone = YES;
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        mData = [NSMutableData dataWithData:data];
                        data = nil;
                        [_downloadDelegate downloader:self dataDownloadedDownloadedForLink:linkDownloading];
                    }];
                    foundCacheData = YES;
                    
                }
            }
        }
        if (!foundCacheData) {
            request_ = request;
            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [connection setDelegateQueue:[Downloader downloaderDelegateQueue]];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if ([_downloadDelegate respondsToSelector:@selector(downloader:beginToDownloadLink:)])
                    {
                        [_downloadDelegate downloader:self beginToDownloadLink:link];
                    }
                    if (autoStartEnabled) {
                        mData = [NSMutableData data];
                        downloadStarted = YES;
                        [connection start];
                    }
                }];
                
           
           
        }
        autoStartEnabled = isAutoStartAllowed;
        
    }
    return self;
}

-(instancetype)initWithURL:(NSURL *)link cachePolicy:(NSURLRequestCachePolicy)policy delegate:(id<DownloaderResponseDelegate>)delegate timeInterval:(NSTimeInterval)timeInterval
{
    self = [super init];
    
    if (self) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:link cachePolicy:policy timeoutInterval:timeInterval];
        request_ = request;
        autoStartEnabled = NO;
        self.downloadDelegate = delegate;
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if ([_downloadDelegate respondsToSelector:@selector(downloader:beginToDownloadLink:)])
            {
                [_downloadDelegate downloader:self beginToDownloadLink:link];
                
            }
           
        }];
    }
    
    return self;
}

/// This method doesn't auto start download. It provide a cache block which will be called snychronously. It can be nil
-(instancetype )initWithURL:(NSURL *)link cachePolicy:(NSURLRequestCachePolicy )policy delegate:(id <DownloaderResponseDelegate>)delegate timeInterval:(NSTimeInterval )timeInterval cacheData:(void (^)(NSData *cachedData))completion
{
    self = [self initWithURL:link cachePolicy:policy delegate:delegate timeInterval:timeInterval];
    
    if (self) {
        if (completion != NULL) {
            NSData *cachedData = [self cachedDataIfAvailable];
            completion(cachedData);
        }
    }
    
    return self;
}

/// This method doesn't auto start download. It provide a cache block which will be called snychronously. It can be nil
-(instancetype )initWithURL:(NSURL *)link cachePolicy:(NSURLRequestCachePolicy )policy delegate:(id <DownloaderResponseDelegate>)delegate timeInterval:(NSTimeInterval )timeInterval cacheImage:(void (^)(UIImage *cachedImage))completion
{
    self = [self initWithURL:link cachePolicy:policy delegate:delegate timeInterval:timeInterval];

    if (self) {
        if (completion != NULL) {
            UIImage *image = [self cachedImageIfAvailable];
            completion(image);
        }
    }
    
    return self;
}

/// This method doesn't auto start download. It provide a cache block which will be called snychronously. It can be nil
-(instancetype )initWithURL:(NSURL *)link cachePolicy:(NSURLRequestCachePolicy )policy delegate:(id <DownloaderResponseDelegate>)delegate timeInterval:(NSTimeInterval )timeInterval cacheAspectFitImage:(void (^)(UIImage *cachedImage))completion withMaxSize:(CGSize )maxSize
{
    self = [self initWithURL:link cachePolicy:policy delegate:delegate timeInterval:timeInterval];
    
    if (self) {
        if (completion != NULL) {
            UIImage *image = [self cachedAspectFitImageIfAvailableWithSize:maxSize];
            completion(image);
        }
    }
    
    return self;
}



-(id)initWithURLLink:(NSURL*)link cahcePolicy:(NSURLRequestCachePolicy)policy delegate:(id<DownloaderResponseDelegate>)delegate{
    return [self initWithURLLink:link cachePolicy:policy request:nil delegate:delegate autoStartEnabled:YES];
}

-(id)initWithURLLink:(NSURL*)link cahcePolicy:(NSURLRequestCachePolicy)policy delegate:(id<DownloaderResponseDelegate>)delegate autoStartEnabled:(BOOL)isAutoStartAllowed{
    return [self initWithURLLink:link cachePolicy:policy request:nil delegate:delegate autoStartEnabled:isAutoStartAllowed];

}

-(void)startByAsynchronusMethod
{
    return;
/*
    [NSURLConnection sendAsynchronousRequest:connection.originalRequest queue:[WebServiceDataHandler sharedOperationQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        mData = (NSMutableData*)data;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (connectionError) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    downloadFailed = NO;
                    isDownloadDone = YES;
                    
                    if ([_downloadDelegate  respondsToSelector:@selector(downloader:errorDownloading:)]) {
                        [_downloadDelegate  downloader:self errorDownloading:connectionError];
                    }
                }];
            }else{
                downloadFailed = NO;
                isDownloadDone = YES;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_downloadDelegate  downloader:self  dataDownloadedDownloadedForLink:linkDownloading];
                }];
            }
        }];
    }];
    */
}

-(void)start{
    if (!downloadStarted) {
        mData = [NSMutableData data];
        
        if(!autoStartEnabled)
        {
          //  expectedlen = 0;
          //  downloadFailed = NO;
          //  isDownloadDone = NO;
            downloadStarted = YES;
            [connection start];
        }
    }
    

}

-(void)resetData
{
    mData = nil;
    downloadStarted = NO;
}

-(NSURLResponse*)response
{
    return downloadResponse;
}

-(NSMutableData *)mData
{
    return mData;
}

-(void)dealloc{
    [self cancel];
    
    request_ = nil;
    linkDownloading = nil;
    self.downloadDelegate = nil;
    mData = nil;
    downloadResponse = nil;
}


#pragma mark - Class Methods

+(NSData*)cachedDataForURL:(NSURL*)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReturnCacheDataDontLoad timeoutInterval:NetworkTimeOutInSeconds];
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    
    return cachedResponse.data;
}

+(UIImage*)cachedImageForURL:(NSURL*)url withPrefferredSize:(CGSize)size{
    NSData *imgData = [Downloader cachedDataForURL:url];
    if (imgData.length>0) {
        if(size.width >0 && size.height>0)
        {
          //  imgData = [UIImage dataAfterResizeWithData:imgData costraintSize:size];
        }
        UIImage *img = [UIImage imageWithData:imgData];
        return img;
    }
    return nil;
}

+(UIImage*)cachedImageForURL:(NSURL*)url
{
    return [UIImage imageWithData:[Downloader cachedDataForURL:url]];
    //[Downloader cachedImageForURL:url withPrefferredSize:CGSizeMake(75, 62)];
}

+(NSOperationQueue *)sharedQueue{
    static NSOperationQueue *opQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:5];
    });
    return opQueue;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    expectedlen = response.expectedContentLength;
    downloadResponse = [response copy];
    NSHTTPURLResponse *httpCode = (NSHTTPURLResponse *)response;
    if ([httpCode respondsToSelector:@selector(statusCode)]) {
        self.networkStatusCode = httpCode.statusCode;
    }
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float percent = totalBytesWritten/(float)totalBytesExpectedToWrite;
    percent = percent *100;
    percentDone = percent;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([_downloadDelegate respondsToSelector:@selector(downloader:dataDownloadProgress:forLink:)])
        {
            [_downloadDelegate  downloader:self  dataDownloadProgress:percent forLink:linkDownloading];
        }
    }];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // [self processResponseData:mData];
    isDownloadDone = YES;
    if ([NSThread isMainThread]) {
        [_downloadDelegate  downloader:self  dataDownloadedDownloadedForLink:linkDownloading];
        mData = nil;
    }else{
        __weak typeof (self)weakSelf = self;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(weakSelf.downloadDelegate){
                [weakSelf.downloadDelegate  downloader:weakSelf  dataDownloadedDownloadedForLink:linkDownloading];
            }
        }];
    }
}

#pragma mark - Download Delegate



- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    if ([NSThread isMainThread]) {
        [mData appendData:data];
        if (expectedlen>0) {
            float percent = mData.length/(float)expectedlen;
            percent = percent *100;
            if (percent<=100) {
                if ([_downloadDelegate respondsToSelector:@selector(downloader:dataDownloadProgress:forLink:)])
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_downloadDelegate  downloader:self  dataDownloadProgress:percent forLink:linkDownloading];
                        
                    });
                }
            }
        }
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self connection:conn didReceiveData:data];
        });
        
    }
    
    
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"\n\n %@ Info:\n%@",error.localizedDescription,error.userInfo);
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadFailed = YES;
        isDownloadDone = YES;
        autoStartEnabled = NO;
        if ([_downloadDelegate  respondsToSelector:@selector(downloader:errorDownloading:)]) {
            [_downloadDelegate  downloader:self errorDownloading:error];
        }
    });
}

@end
