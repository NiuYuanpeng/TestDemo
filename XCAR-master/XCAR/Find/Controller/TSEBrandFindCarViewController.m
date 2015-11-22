//
//  TSEBrandFindCarViewController.m
//  XCAR
//
//  Created by Morris on 10/4/15.
//  Copyright © 2015 Samtse. All rights reserved.
//

#import "TSEBrandFindCarViewController.h"

#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "TSEHttpTool.h"

#import "TSEFindCarSpecialSales.h"
#import "TSEFindCarHeaderView.h"
#import "TSEBrandFindCarViewCell.h"
#import "TSEFindCarSectionView.h"
#import "TSEBrandCar.h"
#import "TSEBrand.h"

#import "Public.h"

@interface TSEBrandFindCarViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) TSEFindCarHeaderView *headerView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSArray *series;
@property (nonatomic, strong) NSArray *specialSales;

@end

@implementation TSEBrandFindCarViewController

static NSString * const CellIdentifier = @"BrandCar";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    
    [self requestSpecialSalesDate];
    [self requestBrandCarDate];
}

- (void)requestSpecialSalesDate {
    [TSEHttpTool get:kGetSpecialSaleURL params:nil success:^(id json) {
//        TSELog(@"%@", json);
        
        // 获取销售新闻
        TSEFindCarSpecialSales *specialSales = [TSEFindCarSpecialSales objectWithKeyValues:json];
        // 设置tableView header
        [self setupTableHeaderViewWithFocusPosts:specialSales];
        
    } failure:^(NSError *error) {
        TSELog(@"failed-------%@", error);
    }];
}

- (void)requestBrandCarDate {
    [TSEHttpTool get:kGetAllXCarBrandsURL params:nil success:^(id json) {
//        TSELog(@"%@", json);
        
        // 获取各车品牌
        self.series = [TSEBrandCar objectArrayWithKeyValuesArray:json[@"letters"]];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        TSELog(@"failed-------%@", error);
    }];
}

#pragma mark - Table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.series count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TSEBrandCar *car = self.series[section];
    return car.brandNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSEBrandFindCarViewCell *cell = [TSEBrandFindCarViewCell cellWithTableView:tableView];
    // 3.设置cell的属性
    TSEBrandCar *car = self.series[indexPath.section];
    TSEBrand *brand = car.brands[indexPath.row];
    
    [cell.brandLabel setText:brand.name];
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell.iconView sd_setImageWithURL:[NSURL URLWithString:brand.icon] placeholderImage:[UIImage imageNamed:@"zhanwei2_1"]];
    return cell;
}

#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TSEBrandCar *car = self.series[section];
    TSEFindCarSectionView *headerView = [[TSEFindCarSectionView alloc] initWithSectionTitles:car.letter];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

/**
 * 设置索引
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *indexTitles = [NSMutableArray array];
    for (TSEBrandCar *car in self.series) {
        [indexTitles addObject:car.letter];
    }
    return indexTitles;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - private method
- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 20.0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    // 设置tableView的额外滚动区域
    [tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, TableViewContentInset, 0.0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = TSEColor(136, 140, 150);
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexMinimumDisplayRowCount = 30;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)setupTableHeaderViewWithFocusPosts:(TSEFindCarSpecialSales *)specialSales {
    TSEFindCarHeaderView *headerView = [[TSEFindCarHeaderView alloc] initHeaderViewWithSeriesImage:specialSales.seriesImage carName:specialSales.carName cheapRange:specialSales.cheapRange dealerName:specialSales.dealerName];
    [headerView setFrame:CGRectMake(0.0, 0.0, ScreenWidth, headerView.cellHeight + 15)];
    self.tableView.tableHeaderView = headerView;
}

@end
