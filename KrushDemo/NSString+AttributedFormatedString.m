//
//  NSString+AttributedFormatedString.m
//  Shopex2
//
//  Created by Atif Khan on 4/30/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "NSString+AttributedFormatedString.h"

@implementation NSString (AttributedFormatedString)

-(NSMutableAttributedString *)featuredLabelFormattedText{
    return nil;
}

-(NSMutableAttributedString *)centeredAttributedTextWithFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSRange range = NSMakeRange(0, [self length]);
    
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:self];
    [mAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    [mAttr addAttribute:NSFontAttributeName value:font range:range];
    
    return mAttr;
}


-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font spacing:(float)spacing lineSpacing:(float )lineSpacing alignment:(NSTextAlignment )alignment leadingSpace:(float )leadingSpace trailingSpace:(float )trailingSpace
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    if (lineSpacing>=0) {
        paragraphStyle.lineSpacing = lineSpacing;
    }
    if (leadingSpace>0) {
        paragraphStyle.firstLineHeadIndent = leadingSpace;
        paragraphStyle.headIndent = leadingSpace;
    }
    if (trailingSpace > 0) {
        paragraphStyle.tailIndent = trailingSpace;
    }
    
    if (alignment >= 0) {
        paragraphStyle.alignment = alignment;
    }
    NSRange range = NSMakeRange(0, [self length]);
    
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:self];
    [mAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    [mAttr addAttribute:NSFontAttributeName value:font range:range];
    if (spacing>=0) {
        [mAttr addAttribute:NSKernAttributeName
                      value:@(spacing) range:range];
    }
    return mAttr;
}

-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font spacing:(float)spacing lineSpacing:(float )lineSpacing alignment:(NSTextAlignment )alignment
{
    return [self attrMStringWithFont:font spacing:spacing lineSpacing:lineSpacing alignment:alignment leadingSpace:0 trailingSpace:0];
}

-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font alignment:(NSTextAlignment )alignment color:(UIColor *)color{
    NSRange range = NSMakeRange(0, [self length]);

    NSMutableAttributedString *attr = [self attrMStringWithFont:font spacing:-1 lineSpacing:-1 alignment:alignment leadingSpace:0 trailingSpace:0];
    [attr addAttribute:NSForegroundColorAttributeName value:color range:range];
    return attr;
}

-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font spacing:(float)spacing lineSpacing:(float )lineSpacing
{
    return [self attrMStringWithFont:font spacing:spacing lineSpacing:lineSpacing alignment:-1];
}



-(NSMutableAttributedString *)attrMStringWithFont:(UIFont *)font spacing:(float)spacing
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    NSRange range = NSMakeRange(0, [self length]);
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing) range:range];
    [attributedString addAttribute:NSFontAttributeName value:font range:range];
    return attributedString;
}


@end
