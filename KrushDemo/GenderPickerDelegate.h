//
//  GenderPickerDelegate.h
//  KrushDemo
//
//  Created by Atif Khan on 9/8/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    Gender_DontMention,
    Gender_Male,
    Gender_Female
} Gender;

@class GenderPickerDelegate;

@protocol GenderPickerSelectionProtocol<NSObject>

-(void )pickerDataSource:(GenderPickerDelegate *)dataSource selectedGender:(Gender )gender;

@end

@interface GenderPickerDelegate : NSObject<UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) id<GenderPickerSelectionProtocol> delegate;

-(void )reloadPicker:(UIPickerView *)picker withSelectedGender:(Gender)gender;

+(NSString *)genderDisplayStringForCode:(Gender )gender;

@end
