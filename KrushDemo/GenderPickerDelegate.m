//
//  GenderPickerDelegate.m
//  KrushDemo
//
//  Created by Atif Khan on 9/8/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import "GenderPickerDelegate.h"
#import "NSString+AttributedFormatedString.h"

@implementation GenderPickerDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return component == 0?3:0;
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (row == 0) {
        return [@"Gender" attrMStringWithFont:[FontHelper fontProximaRegularSize:17] alignment:NSTextAlignmentLeft color:[UIColor purpleColor]];
    }else{
        if (row == 1) {
            return [@"Male" attrMStringWithFont:[FontHelper fontProximaRegularSize:17] alignment:NSTextAlignmentLeft color:[UIColor blackColor]];
        } else if (row == 2){
            return [@"Female" attrMStringWithFont:[FontHelper fontProximaRegularSize:17] alignment:NSTextAlignmentLeft color:[UIColor blackColor]];
        }
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(row !=0){
        if (row == 1) {
            [_delegate pickerDataSource:self selectedGender:Gender_Male];
        }else if (row ==2){
            [_delegate pickerDataSource:self selectedGender:Gender_Female];
        }
    }
}

-(void )reloadPicker:(UIPickerView *)picker withSelectedGender:(Gender)gender{
    
    picker.delegate     = self;
    picker.dataSource   = self;
    [picker reloadAllComponents];
    if (gender == Gender_DontMention) {
        [picker selectRow:0 inComponent:0 animated:NO];
    }else if(gender == Gender_Male){
        [picker selectRow:1 inComponent:0 animated:NO];
    }else if(gender == Gender_Female){
        [picker selectRow:2 inComponent:0 animated:NO];
    }
}

+(NSString *)genderDisplayStringForCode:(Gender )gender{

    if (gender == Gender_Male) {
        return @"Male";
    }else if (gender == Gender_Female) {
        return @"Female";
    }
    
    return nil;
}
@end
