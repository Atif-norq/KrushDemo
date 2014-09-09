//
//  NSString+Addition.m
//  Shopex
//
//  Created by Atif Khan on 2/3/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NSString+Addition.h"

@implementation NSString (Addition)


- (NSString*)stringByReplacingHTMLEncoding{
    NSString * htmlString = self;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&amp"  withString:@"&"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&lt"  withString:@"<"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&gt"  withString:@">"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot" withString:@"\""];    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&#039"  withString:@"'"];
   // htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&nbsp" withString:@" "];

    return htmlString;
}


-(NSString*)encodeByAddingPercentEncode
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self, NULL, CFSTR("!$&'()*+,-./:;=?@_~"), kCFStringEncodingUTF8));
}

-(NSString *)parameterValueForKey:(NSString *)key{
    NSRange startRange = [self rangeOfString:[NSString stringWithFormat:@"%@=",key] options:NSCaseInsensitiveSearch];
    
    if (startRange.location !=NSNotFound) {
        
        NSString * idString = [self substringFromIndex:(startRange.location+startRange.length)];
        if (idString.length>0) {
            NSRange endRange = [idString rangeOfString:@"&"];
            if (endRange.location!=NSNotFound) {
                int index = (int)endRange.location+(int)endRange.length -1;
                if (index<0) {
                    index = 0;
                }
                idString = [idString substringToIndex:index];
            }
        }
        return idString;
    }
    return nil;
}

-(NSLocaleLanguageDirection)determineDirection
{
    NSString * txtToExamine = self;
    NSString *isoLangCode = ( NSString*)CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage(( CFStringRef)txtToExamine, CFRangeMake(0, txtToExamine.length)));
    NSLocaleLanguageDirection direction = [NSLocale characterDirectionForLanguage:isoLangCode];
    
    return direction;
}

-(NSLocaleLanguageDirection)determineDirectionWithMaxLength:(int)maxLen
{
    NSString * txtToExamine = self;
    int length = (int)txtToExamine.length;
    if (length>0) {
        if (length>10) {
            length = 10;
            txtToExamine = [txtToExamine substringToIndex:length-1];
        }
        return [txtToExamine determineDirection];

    }
    return (NSLocaleLanguageDirection)kCFLocaleLanguageDirectionLeftToRight;
}

-(BOOL)isAValidEmailID
{
    NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:Nil];
    NSRange matchRange = [regex rangeOfFirstMatchInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    if (matchRange.location == NSNotFound) {
        return NO;
    }
    return YES;
}

-(BOOL)isAvalidPasswordForMobileUser
{
    return self.length>=6;
}

-(BOOL)isAValidName{
    if (self.length == 0) {
        return NO;
    }
    NSString *pattern = @"[a-z A-Z]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:Nil];
    int numberOfOccurence = (int)[regex numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    if (numberOfOccurence != self.length) {
        return NO;
    }
    
    return YES;
}


@end
