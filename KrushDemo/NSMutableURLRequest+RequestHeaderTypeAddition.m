//
//  NSMutableURLRequest+RequestHeaderTypeAddition.m
//  KrushDemo
//
//  Created by Atif Khan on 9/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

static NSString *POSTBoundary = @"IOSPOSTv7yvqNfz5RcHkdx9";


#import "NSMutableURLRequest+RequestHeaderTypeAddition.h"

@implementation NSMutableURLRequest (RequestHeaderTypeAddition)



-(void )setUpContentType:(RequestContentType )type{
    switch (type) {
        case RequestContentType_FormData:
            [self addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", POSTBoundary] forHTTPHeaderField:@"Content-Type"];
            break;
        
        case RequestContentType_UrlEncode:
        default:
            [self addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

            break;
    }
}

-(void )setUpURLEncodeRequestTypeParamters:(NSDictionary *)parameters{
    [self setUpContentType:RequestContentType_UrlEncode];
    __block NSString *params = @"";
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        NSString *keyStr = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *valueStr = nil;

        
        if ([obj isKindOfClass:[NSString class]]) {
            valueStr = [(NSString *)obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            //[self addValue:valueStr forHTTPHeaderField:keyStr];
        }else if([obj isKindOfClass:[NSNumber class]]){
            valueStr = [obj stringValue];
            //[self addValue:[[obj stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forHTTPHeaderField:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if (!valueStr) {
            valueStr = @"";
        }
        
        if (params.length == 0) {
            params = [params stringByAppendingFormat:@"%@=%@",keyStr,valueStr];
        }else{
            params = [params stringByAppendingFormat:@"&%@=%@",keyStr,valueStr];
        }
    }];
    
    NSData *postData = [params dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[params length]];
    [self setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:postData];
    [self setHTTPMethod:@"POST"];

}

-(void )setUpFormDataRequestTypeParamters:(NSDictionary *)parameters
{
    [self setUpContentType:RequestContentType_FormData];
    NSMutableData * POSTBody = [NSMutableData data];

    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *valueString = nil;
        
        if ([obj isKindOfClass:[NSString class]]) {
            valueString = obj;
        }else if([obj isKindOfClass:[NSNumber class]]){
            valueString = [obj stringValue];
        }
        
        [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [POSTBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [POSTBody appendData:[valueString dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self setHTTPBody:POSTBody];
}





@end
