//
//  AGAddPresentViewController.m
//  Xmas
//
//  Created by Corinne Krych on 11/21/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGAddPresentViewController.h"

@interface AGAddPresentViewController()
    @property (weak, nonatomic) IBOutlet UITextField *toWhomTextField;
    @property (weak, nonatomic) IBOutlet UITextView *description;
    @property (weak, nonatomic) IBOutlet UITextField *password;
    @property (weak, nonatomic) IBOutlet UISwitch *isSecret;
@end

@implementation AGAddPresentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL) validate {
    if ([self.toWhomTextField.text length] != 0 &&
        [self.description.text length] !=0 &&
        [self.password.text length] != 0) {
        return YES;
    } else {
        self.toWhomTextField.layer.borderColor = [[UIColor redColor]CGColor];
        self.toWhomTextField.layer.borderWidth = 1.0;
        self.description.layer.borderColor = [[UIColor redColor]CGColor];
        self.description.layer.borderWidth = 1.0;
        self.password.layer.borderColor = [[UIColor redColor]CGColor];
        self.password.layer.borderWidth = 1.0;
        return NO;
    }
}

- (IBAction)save:(id)sender {
    if ([self validate]) {
        NSMutableDictionary *gift = [@{@"toWhom": self.toWhomTextField.text,
                                          @"description":self.description.text,
                                          @"password": self.password.text} mutableCopy];
        
        [self.delegate addPresentViewController:self didAddGift:gift];
    }
}

@end
