//
//  NSString+AttributedFormatedString.h
//  Shopex2
//
//  Created by Atif Khan on 4/30/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AttributedFormatedString)

-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font spacing:(float)spacing;
-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font spacing:(float)spacing lineSpacing:(float )lineSpacing;
-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font spacing:(float)spacing lineSpacing:(float )lineSpacing alignment:(NSTextAlignment )alignment;

-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font alignment:(NSTextAlignment )alignment color:(UIColor *)color;
// Featured Label formatting for text
-(NSMutableAttributedString *)featuredLabelFormattedText;

-(NSMutableAttributedString *)centeredAttributedTextWithFont:(UIFont *)font;

//[NSLocalizedStringFromTable(@"FEATURED", @"Localization_Shared", @"Used In Product Cover Cell") attrMStringWithFont:[FontTheme featuredProductFeaturedFont] spacing:5 lineSpacing:0 alignment:NSTextAlignmentCenter]

@end
