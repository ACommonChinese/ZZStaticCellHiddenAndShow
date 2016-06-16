//
//  UITableViewController+ZZStaticCellHiddenShow.h
//  Demo
//
//  Created by 刘威振 on 6/15/16.
//  Copyright © 2016 LiuWeiZhen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZDataTable.h"

@interface UITableViewController (ZZStaticCellHiddenShow)

- (void)zz_setCellsHidden:(NSArray<UITableViewCell *> *)cellArray animated:(BOOL)animated;
- (void)zz_setCellsShow:(NSArray<UITableViewCell *> *)cellArray animated:(BOOL)animated;
- (void)zz_setSectionsHidden:(NSArray<NSNumber *> *)sectionArray animated:(BOOL)animated;
- (void)zz_setSectionsShow:(NSArray<NSNumber *> *)sectionArray animated:(BOOL)animated;

@property (nonatomic) BOOL zz_autoHiddenShow;
@end
