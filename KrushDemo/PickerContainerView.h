//
//  PickerContainerView.h
//  KrushDemo
//
//  Created by Atif Khan on 9/8/14.
//  Copyright (c) 2014 Norq Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerContainerView : UIView
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarbutton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarButton;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@end
