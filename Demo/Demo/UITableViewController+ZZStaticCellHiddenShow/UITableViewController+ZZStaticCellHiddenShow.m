//
//  UITableViewController+ZZStaticCellHiddenShow.m
//  Demo
//
//  Created by 刘威振 on 6/15/16.
//  Copyright © 2016 LiuWeiZhen. All rights reserved.
//

#import "UITableViewController+ZZStaticCellHiddenShow.h"
#import <objc/runtime.h>

@interface UITableViewController ()

@property (nonatomic) ZZDataTable *dataTable;
@end

@implementation UITableViewController (ZZStaticCellHiddenShow)

- (void)zz_setCellsHidden:(NSArray *)cellArray animated:(BOOL)animated {
    if (cellArray.count <= 0) return;
    [self.dataTable deleteCells:cellArray]; // 数据的删除
    if (animated) {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[self.dataTable deleteIndexPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
    
    if (self.dataTable.deleteRows.count > 0) {
        [self.dataTable.didDeleteRows addObjectsFromArray:self.dataTable.deleteRows];
        [self.dataTable.didDeleteRows zz_sortByInexPath];
        [self.dataTable.deleteRows removeAllObjects];
    }
}

- (void)zz_setCellsShow:(NSArray *)cellArray animated:(BOOL)animated {
    if (cellArray.count <= 0) return;
    [self.dataTable insertCells:cellArray]; // 数据的添加
    if (animated) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[self.dataTable insertIndexPaths] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
    [self.dataTable.didDeleteRows removeObjectsInArray:self.dataTable.insertRows];
    [self.dataTable.insertRows removeAllObjects];
}

- (void)zz_setSectionsHidden:(NSArray<NSNumber *> *)sectionArray animated:(BOOL)animated {
    NSMutableArray *array = [self resetSectionArray:sectionArray]; // 剔除不合法输入
    NSMutableArray *cellArray = [NSMutableArray array];
    for (NSNumber *number in array) {
        NSInteger index = number.integerValue;
        ZZDataSection *section = self.dataTable.sections[index];
        [cellArray addObjectsFromArray:[section allCells]];
    }
    [self zz_setCellsHidden:cellArray animated:animated];
}

- (void)zz_setSectionsShow:(NSArray<NSNumber *> *)sectionArray animated:(BOOL)animated {
    NSMutableArray *array = [self resetSectionArray:sectionArray]; // 剔除不合法输入
    NSMutableArray *cellArray = [NSMutableArray array];
    [self.dataTable.didDeleteRows zz_sortByInexPath];
    
    for (NSNumber *number in array) {
        for (ZZDataRow *row in self.dataTable.didDeleteRows) {
            if (row.indexPath.section == number.integerValue) {
                UITableViewCell *cell = row.cell;
                if ([cellArray containsObject:cell] == NO) {
                    [cellArray addObject:row.cell];
                }
            }
        }
    }
    [self zz_setCellsShow:cellArray animated:animated];
}

- (NSMutableArray<NSNumber *> *)resetSectionArray:(NSArray<NSNumber *> *)sectionArray {
    // 剔除不合法输入
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:sectionArray.count];
    for (NSInteger i = 0; i < sectionArray.count; i++) {
        id obj = sectionArray[i];
        NSAssert([obj isKindOfClass:[NSNumber class]], @"非法的sectionArray");
        NSNumber *number = (NSNumber *)obj;
        if (number.integerValue < 0 || number.integerValue > self.dataTable.sections.count - 1 || [array containsObject:number]) continue;
        [array addObject:number];
    }
    return array;
}

- (void)commonInit {
    self.dataTable = [[ZZDataTable alloc] initWithTableView:self.tableView];
    if (self.zz_autoHiddenShow == YES) {
        [[self class] exchangeInstanceMethod1:@selector(tableView:numberOfRowsInSection:) method2:@selector(zz_tableView:numberOfRowsInSection:)];
        [[self class] exchangeInstanceMethod1:@selector(tableView:cellForRowAtIndexPath:) method2:@selector(zz_tableView:cellForRowAtIndexPath:)];
        [[self class] exchangeInstanceMethod1:@selector(tableView:heightForRowAtIndexPath:) method2:@selector(zz_tableView:heightForRowAtIndexPath:)];
    }
}

+ (void)exchangeInstanceMethod1:(SEL)method_1 method2:(SEL)method_2 {
    method_exchangeImplementations(class_getInstanceMethod(self, method_1), class_getInstanceMethod(self, method_2));
}

#pragma mark - Change methods
- (NSInteger)zz_tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.zz_autoHiddenShow) {
        return self.dataTable.sections[section].rows.count;
    } else {
        return [self zz_tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)zz_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.zz_autoHiddenShow) {
        if (self.dataTable.sections.count <= 0) {
            return [self zz_tableView:tableView cellForRowAtIndexPath:indexPath];
        }
        ZZDataRow *row = self.dataTable.sections[indexPath.section].rows[indexPath.row];
        NSAssert(row.cell != nil, @"oh, no, cell can not be nil!");
        return row.cell;
    } else {
        return [self zz_tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)zz_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.zz_autoHiddenShow) {
        ZZDataRow *row = self.dataTable.sections[indexPath.section].rows[indexPath.row];
        return row.height;
    } else {
        return [self zz_tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Properties

- (void)setZz_autoHiddenShow:(BOOL)autoHiddenShow {
    if (autoHiddenShow) {
        objc_setAssociatedObject(self, @selector(zz_autoHiddenShow), @(autoHiddenShow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self commonInit];
    } else {
    }
}

- (BOOL)zz_autoHiddenShow {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDataTable:(ZZDataTable *)dataTable {
    objc_setAssociatedObject(self, @selector(dataTable), dataTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZZDataTable *)dataTable {
    return objc_getAssociatedObject(self, _cmd);
}

@end
