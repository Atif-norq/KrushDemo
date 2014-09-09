//
//  OrderViewController.m
//  KrushDemo
//
//  Created by Atif Khan on 9/4/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "OrderViewController.h"
#import "Downloader.h"
#import "Order.h"
#import "UserSessionManager.h"

@interface OrderViewController ()<DownloaderResponseDelegate>
{
    Downloader *ordersConnection;
}
@property (strong, nonatomic) IBOutlet UITextView *txtView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreh;
@property (nonatomic, strong) NSArray *records;
@end

@implementation OrderViewController

- (IBAction)refreshTapped:(id)sender {
    [self makeRequest];
}

-(void )makeRequest{
    [ordersConnection cancel];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.150/DemoAppAPI/api/orders"]];
    [request setHTTPMethod:@"GET"];
    [request addValue:[[UserSessionManager sharedInstance] autherizationHeader]
   forHTTPHeaderField:autherizationHeaderKey];
    
    ordersConnection = [[Downloader alloc] initWithRequest:request cachePolicy:0 delegate:self autoStartEnabled:YES];
}

-(void)viewDidLoad{
    [super viewDidLoad]; 

    
    [self makeRequest];
}


//*****************************************************
#pragma mark - Download delegate
//*****************************************************

-(void)downloader:(Downloader*)downloader errorDownloading:(NSError*)error{
    _refreh.enabled = YES;

    [[[UIAlertView alloc] initWithTitle:@"Unable to connect to internet" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
}


-(void)downloader:(Downloader*)downloader dataDownloadedDownloadedForLink:(NSURL*)link{
    
    _refreh.enabled = YES;
    NSArray *recordJSONs = [NSJSONSerialization JSONObjectWithData:downloader.mData options:0 error:nil];
    
    if ([recordJSONs isKindOfClass:[NSArray class]]) {
        NSMutableArray *records = [NSMutableArray array];
        for (NSDictionary *orderJSON in recordJSONs) {
            [records addObject:[[Order alloc] initWithDictionary:orderJSON]];
        }
        self.records = records;
    }
    if (!_records) {
        [[[UIAlertView alloc] initWithTitle:@"Something went wrong" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    
#ifdef DEBUG
    NSString *msg = [[NSString alloc] initWithData:downloader.mData encoding:NSUTF8StringEncoding];
    msg = [msg stringByReplacingOccurrencesOfString:@"},{" withString:@"},\n{"];
    _txtView.text = msg;
    NSLog(@"%s, \n%@",__func__, msg);
#endif

}

-(void)downloader:(Downloader*)downloader beginToDownloadLink:(NSURL*)link{
    _txtView.text = nil;
    _refreh.enabled = NO;
}

@end
