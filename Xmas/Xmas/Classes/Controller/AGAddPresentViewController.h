//
//  AGAddPresentViewController.h
//  Xmas
//
//  Created by Corinne Krych on 11/21/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGAddPresentViewController;

@protocol AGAddPresentViewControllerDelegate <NSObject>

- (void)addPresentViewController:(AGAddPresentViewController *)controller
                   didAddGift:(id)gift;

@end

@interface AGAddPresentViewController : UITableViewController

@property (nonatomic, weak) id <AGAddPresentViewControllerDelegate> delegate;

@end
