//
//  ZZDataTable.h
//  Demo
//
//  Created by 刘威振 on 6/15/16.
//  Copyright © 2016 LiuWeiZhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZZDataRow;

// --------------------------------------------------

@interface NSMutableArray (ZZRowSortByIndexPath)

- (void)zz_sortByInexPath;
- (ZZDataRow *)zz_containsCell:(UITableViewCell *)cell;
@end

// --------------------------------------------------

@interface ZZDataRow : NSObject

@property (nonatomic) BOOL hidden;
@property (nonatomic, weak) UITableViewCell *cell;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic, weak) ZZDataRow *previous;
// @property (nonatomic, weak) ZZDataRow *next;
@property (nonatomic) CGFloat height;
- (void)resetIndexPath;
@end

// --------------------------------------------------

@interface ZZDataSection : NSObject

@property (nonatomic) NSMutableArray<ZZDataRow *> *rows;
@property (nonatomic) NSMutableArray<ZZDataRow *> *deleteRows;
@property (nonatomic) NSMutableArray<ZZDataRow *> *insertRows;

- (void)makeLink; // 使用双向链表结构记录每个ZZDataRow对象的前一个和后一个对象
- (void)zz_deleteRows;
- (void)zz_insertRows;
- (NSArray *)allCells;
@end

// --------------------------------------------------

@interface ZZDataTable : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView;

@property (nonatomic) NSMutableArray<ZZDataSection *> *sections;
@property (nonatomic) NSMutableArray<ZZDataRow *> *deleteRows;
@property (nonatomic) NSMutableArray<ZZDataRow *> *didDeleteRows;
@property (nonatomic) NSMutableArray<ZZDataRow *> *insertRows;

- (void)deleteCells:(NSArray *)cells;
- (void)insertCells:(NSArray *)cells;
- (NSArray<NSIndexPath *> *)deleteIndexPaths;
- (NSArray<NSIndexPath *> *)insertIndexPaths;

@end
