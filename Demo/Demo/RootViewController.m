//
//  RootViewController.m
//  Demo
//
//  Created by 刘威振 on 6/15/16.
//  Copyright © 2016 LiuWeiZhen. All rights reserved.
//

#import "RootViewController.h"
#import "UITableViewController+ZZStaticCellHiddenShow.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *cell_0_0;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell_0_1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell_0_2;

@property (weak, nonatomic) IBOutlet UITableViewCell *cell_1_0;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell_1_1;


@property (weak, nonatomic) IBOutlet UITableViewCell *cell_2_0;

@property (weak, nonatomic) IBOutlet UITableViewCell *cell_3_0;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell_3_1;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell_3_2;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell_3_3;

@property (weak, nonatomic) IBOutlet UITableViewCell *cell_4_0;
@property (weak, nonatomic) IBOutlet UITableViewCell *cell_4_1;

@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.zz_autoHiddenShow = YES;
}

- (IBAction)manageSingleCell:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self zz_setCellsHidden:@[_cell_0_0] animated:self.switchButton.isOn];
    } else {
        [self zz_setCellsShow:@[_cell_0_0] animated:self.switchButton.isOn];
    }
}

- (IBAction)manageMultiCell:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self zz_setCellsHidden:@[_cell_0_1, _cell_3_0, _cell_3_1] animated:self.switchButton.isOn];
    } else {
        [self zz_setCellsShow:@[_cell_0_1, _cell_3_0, _cell_3_1] animated:self.switchButton.isOn];
    }
}

- (IBAction)manageSingleSection:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self zz_setSectionsHidden:@[@1] animated:self.switchButton.isOn];
    } else {
        [self zz_setSectionsShow:@[@1] animated:self.switchButton.isOn];
    }
}

- (IBAction)manageMultiSection:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self zz_setSectionsHidden:@[@0, @1, @3] animated:self.switchButton.isOn];
    } else {
        [self zz_setSectionsShow:@[@0, @1, @3] animated:self.switchButton.isOn];
    }
}

@end