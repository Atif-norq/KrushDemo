//
//  NSMutableURLRequest+RequestHeaderTypeAddition.h
//  KrushDemo
//
//  Created by Atif Khan on 9/2/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RequestContentType_UrlEncode,
    RequestContentType_FormData,
    //  RequestContentType_Raw (in future if required)
}RequestContentType;

@interface NSMutableURLRequest (RequestHeaderTypeAddition)

-(void )setUpContentType:(RequestContentType )type;

/// This method along with setting parameters also set content type;
-(void )setUpURLEncodeRequestTypeParamters:(NSDictionary *)parameters;

/// This method along with setting parameters also set content type;
-(void )setUpFormDataRequestTypeParamters:(NSDictionary *)parameters;


@end
