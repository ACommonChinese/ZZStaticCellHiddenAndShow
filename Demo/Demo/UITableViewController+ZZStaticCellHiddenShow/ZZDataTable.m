//
//  ZZDataTable.m
//  Demo
//
//  Created by 刘威振 on 6/15/16.
//  Copyright © 2016 LiuWeiZhen. All rights reserved.
//

#import "ZZDataTable.h"

// 宏，懒加载
#define LAZY_LOAD(ClassName, varName) \
- (ClassName *)varName { \
    if (_##varName == nil) { \
        _##varName = [[ClassName alloc] init]; \
    } \
    return _##varName; \
}

// --------------------------------------------------

@implementation NSMutableArray (ZZRowSortByIndexPath)

- (void)zz_sortByInexPath {
    [self sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}

- (ZZDataRow *)zz_containsCell:(UITableViewCell *)cell {
    for (ZZDataRow *row in self) {
        NSAssert([row isKindOfClass:[ZZDataRow class]], @"oh, no, containsCell, the object in array should be ZZDataRow object");
        if (row.cell == cell) {
            return row;
        }
    }
    return nil;
}

@end

// --------------------------------------------------

#pragma mark - ZZDataRow implementation

@implementation ZZDataRow : NSObject

- (NSComparisonResult)compare:(ZZDataRow *)row {
    return [self.indexPath compare:row.indexPath];
}

// 取上一个没有被隐藏的ZZDataRow对象的indexPath.row+1作为自己的row(行号)
- (void)resetIndexPath {
    self.indexPath = [NSIndexPath indexPathForRow:[self validRowNum] inSection:self.indexPath.section];
}

- (NSInteger)validRowNum {
    ZZDataRow *previousRow = self.previous;
    if (previousRow == nil) {
        return 0;
    }
    if (previousRow.hidden == NO) {
        return previousRow.indexPath.row + 1;
    }
    return [previousRow validRowNum];
}

@end

// --------------------------------------------------

#pragma mark - ZZDataSection implementation

@implementation ZZDataSection : NSObject

LAZY_LOAD(NSMutableArray, deleteRows)
LAZY_LOAD(NSMutableArray, insertRows)

- (void)makeLink {
    for (NSInteger i = 0; i < self.rows.count; i++) {
        ZZDataRow *row = self.rows[i];
        NSInteger previousIndex = i - 1;
        // NSInteger nextIndex     = i + 1;
        if (previousIndex < 0) { // 第一个
            row.previous = nil;
        } else {
            row.previous = self.rows[previousIndex];
        }
        /**
        if (nextIndex > self.rows.count - 1) { // 最后一个
            row.next = nil;
        } else {
            row.next = self.rows[nextIndex];
        }*/
    }
}

// 分区的数据删除
- (void)zz_deleteRows {
    for (ZZDataRow *row in self.deleteRows) {
        row.hidden = YES;
    }
    // 数组中对象按indexPath大小排序
    [self.rows zz_sortByInexPath];
    // 更新数组中每个ZZDataRow对象的indexPath
    for (NSInteger i = 0; i < self.rows.count; i++) {
        ZZDataRow *dataRow = self.rows[i];
        if (dataRow.hidden == NO) {
            [dataRow resetIndexPath];
        }
    }
    [self.rows removeObjectsInArray:self.deleteRows];
}

// 分区的数据插入
- (void)zz_insertRows {
    [self.insertRows zz_sortByInexPath];
    
    for (ZZDataRow *insertRow in self.insertRows) {
        insertRow.hidden = NO;
        [insertRow resetIndexPath];
        for (ZZDataRow *row in self.rows) {
            [row resetIndexPath];
        }
        [self.rows insertObject:insertRow atIndex:insertRow.indexPath.row];
    }
    
    // [self.insertRows makeObjectsPerformSelector:@selector(setHidden:) withObject:@YES];
    // [self.rows insertObjects:(nonnull NSArray *) atIndexes:(nonnull NSIndexSet *)]
}

- (NSArray *)allCells {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.rows.count];
    for (ZZDataRow *row in self.rows) {
        [array addObject:row.cell];
    }
    return array;
}

@end

// --------------------------------------------------

#pragma mark - ZZDataTable implementation

@implementation ZZDataTable

LAZY_LOAD(NSMutableArray, deleteRows)
LAZY_LOAD(NSMutableArray, didDeleteRows)
LAZY_LOAD(NSMutableArray, insertRows)

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        NSInteger numberOfSections = [tableView numberOfSections];
        self.sections = [NSMutableArray arrayWithCapacity:numberOfSections];
        for (NSInteger i = 0; i < numberOfSections; i++) {
            ZZDataSection *section = [[ZZDataSection alloc] init];
            NSInteger numberOfRows = [tableView numberOfRowsInSection:i];
            section.rows           = [NSMutableArray arrayWithCapacity:numberOfRows];
            for (NSInteger j = 0; j < numberOfRows; j++) {
                ZZDataRow *row = [[ZZDataRow alloc] init];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                CGFloat height = [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
                row.height = height;
                UITableViewCell *cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
                NSAssert(cell   != nil, @"cell can not be nil!");
                row.indexPath   = indexPath;
                row.cell        = cell;
                section.rows[j] = row;
            }
            self.sections[i] = section;
        }
        [self makeLink];
    }
    return self;
}

- (void)makeLink {
    for (NSInteger i = 0; i < self.sections.count; i++) {
        ZZDataSection *section = [self.sections objectAtIndex:i];
        [section makeLink]; // 使每个row联系起来，采用双向链表方式记录上一个、下一个元素
    }
}

- (void)deleteCells:(NSArray *)cells {
    NSInteger sectionCount = self.sections.count;
    for (NSInteger i = 0; i < sectionCount; i++) {
        ZZDataSection *section = [self.sections objectAtIndex:i];
        section.deleteRows = [NSMutableArray array];
    }
    
    for (UITableViewCell *cell in cells) {
        for (NSInteger i = 0; i < sectionCount; i++) {
            ZZDataSection *section = [self.sections objectAtIndex:i];
            for (NSInteger j = 0; j < section.rows.count; j++) {
                ZZDataRow *row = section.rows[j];
                if (row.cell == cell) {
                    if ([section.deleteRows containsObject:row]) {
                        continue;
                    }
                    [section.deleteRows addObject:row];
                }
            }
        }
    }
    
    for (NSInteger i = 0; i < sectionCount; i++) {
        ZZDataSection *section = self.sections[i];
        if (section.deleteRows.count > 0) {
            [section zz_deleteRows]; // 数据的删除
            [self.deleteRows addObjectsFromArray:section.deleteRows];
            [section.deleteRows removeAllObjects];
        }
    }
}

/** 
 * 数据的插入:
 * 准备容存存放
 * 把要插入的cell分别放入不同的section.insertRows中
 * 让每个section执行插入操作（会调整indexPath）
 * dataTable.insertRows依次添加各section插入的Row
 * 在外部根据dataTable.insertRows获取要插入的indexPaths, 执行表格的动画插入
 */
- (void)insertCells:(NSArray *)cells {
    for (ZZDataSection *section in self.sections) {
        [section.insertRows removeAllObjects];
    }
    
    NSInteger sectionCount = self.sections.count;
    for (UITableViewCell *cell in cells) {
        // 把要加入的cell放入对应的section.insertRows中
        ZZDataRow *row = [self.didDeleteRows zz_containsCell:cell];
        if (row) {
            ZZDataSection *section = self.sections[row.indexPath.section];
            if ([section.insertRows containsObject:row] == NO) {
                [section.insertRows addObject:row];
            }
        }
    }
    
    for (NSInteger i = 0; i < sectionCount; i++) {
        ZZDataSection *section = self.sections[i];
        [section zz_insertRows]; // 每个section各自插入
    }
    
    [self.insertRows removeAllObjects];
    for (ZZDataSection *section in self.sections) {
        [self.insertRows addObjectsFromArray:section.insertRows];
        [section.insertRows removeAllObjects];
    }
}

- (NSArray<NSIndexPath *> *)deleteIndexPaths {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.deleteRows.count];
    for (ZZDataRow *row in self.deleteRows) {
        [array addObject:row.indexPath];
    }
    for (NSIndexPath *indexPath in array) {
        NSLog(@"delete: %ld - %ld", indexPath.section, indexPath.row);
    }
    return array;
}

- (NSArray<NSIndexPath *> *)insertIndexPaths {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.insertRows.count];
    for (ZZDataRow *row in self.insertRows) {
        [array addObject:row.indexPath];
    }
    for (NSIndexPath *indexPath in array) {
        NSLog(@"insert: %ld - %ld", indexPath.section, indexPath.row);
    }
    return array;
}

@end
