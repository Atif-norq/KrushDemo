//
//  IGalleryDownloaderDelegate.h
//  InfiniteGalleryScroller
//
//  Created by Atif Khan on 4/21/13.
//  Copyright (c) 2013 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Downloader;
@protocol DownloaderResponseDelegate <NSObject>
-(void)downloader:(Downloader*)downloader errorDownloading:(NSError*)error;
-(void)downloader:(Downloader*)downloader dataDownloadedDownloadedForLink:(NSURL*)link;
@optional
-(void)downloader:(Downloader*)downloader beginToDownloadLink:(NSURL*)link;
-(void)downloader:(Downloader*)downloader dataDownloadProgress:(float)progress forLink:(NSURL*)link;
@end
