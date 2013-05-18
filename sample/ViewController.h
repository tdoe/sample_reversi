//
//  ViewController.h
//  sample
//
//  Created by tdoe on 2013/05/11.
//  Copyright (c) 2013年 tdoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *blacCount;
@property (weak, nonatomic) IBOutlet UILabel *whiteCount;
@property (weak, nonatomic) IBOutlet UILabel *bothSideLabel;

- (IBAction)resetButton:(id)sender;
- (IBAction)undoButton:(id)sender;
- (IBAction)redoButton:(id)sender;
- (IBAction)passButton:(id)sender;

@end
