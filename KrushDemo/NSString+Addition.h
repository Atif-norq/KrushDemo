//
//  NSString+Addition.h
//  Shopex
//
//  Created by Atif Khan on 2/3/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Addition)

- (NSString*)stringByReplacingHTMLEncoding;

-(NSString*)encodeByAddingPercentEncode;
-(NSString*)parameterValueForKey:(NSString*)key;


-(NSLocaleLanguageDirection)determineDirection;
-(NSLocaleLanguageDirection)determineDirectionWithMaxLength:(int)maxLen;

-(BOOL)isAValidEmailID;
-(BOOL)isAvalidPasswordForMobileUser;// General login
-(BOOL )isAValidName;


@end
