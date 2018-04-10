//
//  YFCollectionViewLayout.m
//  LayoutTest
//
//  Created by ios_yangfei on 16/11/23.
//  Copyright © 2016年 jianghu3. All rights reserved.
//

#import "YFCollectionViewAutoFlowLayout.h"

@interface YFCollectionViewAutoFlowLayout ()
// 高度数组
@property(nonatomic,strong)NSMutableArray *heightArr;
// 宽度数组
@property(nonatomic,strong)NSMutableArray *widthArr;

// 每个cell的 UICollectionViewLayoutAttributes
@property(nonatomic,strong)NSMutableArray *attributeArray;


@end

@implementation YFCollectionViewAutoFlowLayout


-(void)prepareLayout{
    [super prepareLayout];
    
    //清空数组赋初值
    [self.widthArr removeAllObjects];
    [self.heightArr removeAllObjects];
    [self.attributeArray removeAllObjects];
    
    NSInteger totalSections = [self.collectionView numberOfSections];
    // 纵向滚动(完成处理)
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        
        if (_itemSizeType == ItemSizeEqualAll || _itemSizeType == ItemSizeEqualWidth) {
            //_numberOfLines 无效 和 _numberOfItemsInLine 有效
            for (NSInteger i=0; i<totalSections; i++) {
                NSMutableArray *sectionHeightArr = [NSMutableArray array];
                for (NSInteger i=0; i<_numberOfItemsInLine; i++) {
                    [sectionHeightArr addObject:@(0)];
                }
                [self.heightArr addObject:sectionHeightArr];
            }
            [self caculateItemFrameForScrollVerticalWith:totalSections equalWidth:YES];
        }else{
            //_numberOfLines 和 _numberOfItemsInLine 无效
            // _numberOfItemsInLine 无效 _numberOfLines 无效
            for (NSInteger i=0; i<totalSections; i++) {
                
                NSMutableArray *width_subarr = [NSMutableArray array];
                [width_subarr addObject:@(_interSpace)];
                [self.widthArr addObject:width_subarr];
                
            }
            [self caculateItemFrameForScrollVerticalWith:totalSections equalWidth:NO];
        }
        
    }else{
        
        if (_itemSizeType == ItemSizeEqualAll) {
            //_numberOfLines 和 _numberOfItemsInLine 有效
            
        }else{
            //_numberOfLines 和 _numberOfItemsInLine 无效
            // _numberOfItemsInLine 无效 _numberOfLines = 1
            for (NSInteger i=0; i<totalSections; i++) {
                [self.widthArr addObject:@(0)];
                NSMutableArray *arr = [NSMutableArray array];
                [arr addObject:@(0)];
                [self.heightArr addObject:arr];
            }
            [self caculateItemFrameForScrollHorizontalWith:totalSections];
            
        }
     
        
    }

}

/*
 
 //清空数组赋初值
 [self.widthArr removeAllObjects];
 [self.attributeArray removeAllObjects];
 [self.heightArr removeAllObjects];
 
 NSInteger totalSections = [self.collectionView numberOfSections];
 
 if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
 for (NSInteger i=0; i<totalSections; i++) {
 NSMutableArray *arr = [NSMutableArray array];
 [arr addObject:@(_interSpace)];
 [self.widthArr addObject:arr];
 }
 [self caculateItemFrameForScrollVerticalWith:totalSections];
 }else{
 if (self.pageEnable) {// 横向分页
 
 }else{
 for (NSInteger i=0; i<totalSections; i++) {
 [self.widthArr addObject:@(0)];
 NSMutableArray *arr = [NSMutableArray array];
 [arr addObject:@(_interSpace)];
 [self.heightArr addObject:arr];
 }
 [self caculateItemFrameForScrollHorizontalWith:totalSections];
 }
 
 }
 
 */

#pragma mark ====== 计算纵向滚动时的itemFrame =======
-(void)caculateItemFrameForScrollVerticalWith:(NSInteger)totalSections equalWidth:(BOOL)equalWidth{
    
    for (NSInteger i=0; i<totalSections; i++) {
        
        // 每个分区section的y值
        CGFloat sectionY = [self getSectionY:i];
        
        // 每个分区section的高度
        CGFloat sectionH = 0;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewSectionHeadSizeForSection:)]) {
            sectionH = [_delegate collectionViewSectionHeadSizeForSection:i].height;
        }
        // 每个分区section的attribute
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        attribute.frame = CGRectMake(0, sectionY,self.collectionView.frame.size.width, sectionH);
        [self.attributeArray addObject:attribute];
        
        //拿到每个分区所有item的个数
        NSInteger totalItems = [self.collectionView numberOfItemsInSection:i];
        
       if (equalWidth) {
           // 每个分区item的高度
           CGFloat itemW = 0;
           if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)] && totalItems > 0) {
               itemW = [_delegate collectionViewItemSizeForIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]].width;
           }
           
           NSMutableArray *sectionHeightArr = _heightArr[i];
           
           for (NSInteger j=0; j<totalItems; j++) {
               
               CGSize itemSize = CGSizeZero;
               //获取每一个item的size
               NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
               if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)]) {
                   itemSize = [_delegate collectionViewItemSizeForIndexPath:indexPath];
               }
               
               //获取height最小的列
               NSInteger currentCol = [self minCurrentColWithSection:i];
               CGFloat xPos  = (itemW + _interSpace) * currentCol + _interSpace;
               CGFloat yPos = [sectionHeightArr[currentCol] floatValue] + sectionY + sectionH + _interSpace;
               
               CGRect frame = CGRectMake(xPos, yPos, itemW, itemSize.height);
               NSLog(@"%@  %@",indexPath, NSStringFromCGRect(frame));
               UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
               attribute.frame = frame;
               
               [self.attributeArray addObject:attribute];
               //更新最小行的宽度
               
               CGFloat updateH = [sectionHeightArr[currentCol] floatValue] + itemSize.height + _interSpace;
               sectionHeightArr[currentCol] = @(updateH);
               
           }
           
       }else{
           // 每个分区item的高度
           CGFloat itemH = 0;
           if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)] && totalItems > 0) {
               itemH = [_delegate collectionViewItemSizeForIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]].height;
           }
           
           
           for (NSInteger j=0; j<totalItems; j++) {
               
               //获取width最小的行
               NSInteger currentCol = [self minCurrentLineWithSection:i];
               CGFloat yPos = (itemH + _interSpace) * currentCol + _interSpace + sectionY + sectionH;
               CGFloat xPos = [_widthArr[i][currentCol] floatValue];
               
               CGSize itemSize = CGSizeZero;
               //获取每一个item的size
               NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
               if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)]) {
                   itemSize = [_delegate collectionViewItemSizeForIndexPath:indexPath];
               }
               
               // 如果新的宽度大于屏幕的宽度则新起一行
               if (xPos + itemSize.width + _interSpace > self.collectionView.frame.size.width) {
                   [_widthArr[i] addObject:@(_interSpace)];
                   //获取width最小的行
                   currentCol = [self minCurrentLineWithSection:i];
                   xPos = _interSpace;
                   yPos = (itemH + _interSpace) * currentCol + _interSpace + sectionY + sectionH;
               }
               
               CGRect frame = CGRectMake(xPos, yPos, itemSize.width, itemH);
               
               UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
               attribute.frame = frame;
               
               [self.attributeArray addObject:attribute];
               //更新最小行的宽度
               CGFloat upDateX = [_widthArr[i][currentCol]  floatValue] + itemSize.width + _interSpace;
               _widthArr[i][currentCol] = @(upDateX);
               
           }
           
       }

    }

    
}

#pragma mark ====== 计算横向滚动时的itemFrame =======
-(void)caculateItemFrameForScrollHorizontalWith:(NSInteger)totalSections{
    for (NSInteger i=0; i<totalSections; i++) {

        // 每个分区section的高度
        CGSize sectionSize = CGSizeZero;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewSectionHeadSizeForSection:)]) {
            sectionSize = [_delegate collectionViewSectionHeadSizeForSection:i];
        }

        // 每个分区section的Y值
        CGFloat sectionY = [self getSectionY:i];

        // 每个分区section的attribute
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        attribute.frame = CGRectMake(0, sectionY,sectionSize.width, sectionSize.height);
        [self.attributeArray addObject:attribute];

        //拿到每个分区所有item的个数
        NSInteger totalItems = [self.collectionView numberOfItemsInSection:i];
        
        // 每个分区item的宽度
        CGSize itemSize = CGSizeZero;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)] && totalItems > 0) {
            itemSize = [_delegate collectionViewItemSizeForIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
        }
        
        CGFloat yPos = _interSpace + sectionY + sectionSize.height;
        
        for (NSInteger j=0; j<totalItems; j++) {

//            CGSize itemSize = CGSizeZero;
//            //获取每一个item的size
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
//            if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)]) {
//                itemSize = [_delegate collectionViewItemSizeForIndexPath:indexPath];
//            }

            CGFloat xPos = [_widthArr[i] floatValue] + _interSpace ;

            CGRect frame = CGRectMake(xPos, yPos, itemSize.width, itemSize.height);

            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attribute.frame = frame;

            [self.attributeArray addObject:attribute];
            //更新section行的宽度
            CGFloat updateX = [_widthArr[i] floatValue] + itemSize.width + _interSpace;
            _widthArr[i] = @(updateX);
            NSMutableArray *lineHeightArr = _heightArr[i];
            CGFloat updateH = itemSize.height + _interSpace * 2;
            lineHeightArr[j] = @(updateH);

        }
    }
}

#pragma mark ====== 每个分区头部视图的y值 =======
-(CGFloat)getSectionY:(NSInteger)section{
    
    if (section == 0) {
        return 0;
    }
    
    CGFloat y = 0;
    
    for (NSInteger i=0; i<section; i++) {
        
        //拿到每个分区所有item的个数
        NSInteger totalItems = [self.collectionView numberOfItemsInSection:i];
        
        // 每个分区item的高度
        CGFloat itemH = 0;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)] && totalItems > 0) {
            itemH = [_delegate collectionViewItemSizeForIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]].height;
        }
        
        CGFloat sectionH = 0;
        // 每个分区section的高度
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewSectionHeadSizeForSection:)]) {
            sectionH = [_delegate collectionViewSectionHeadSizeForSection:i].height;
        }
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            if (_itemSizeType == ItemSizeEqualAll || _itemSizeType == ItemSizeEqualWidth) {
                y += sectionH + [self maxColumnHightValue:i] + _interSpace;
            }else{
                y += sectionH + [_widthArr[i] count] * ( itemH + _interSpace) + _interSpace;
            }
            
        }else{
            y += sectionH + _interSpace + itemH + _interSpace;
        }
        
    }
    
    return y;

}

#pragma mark ====== 计算collectionView的内容大小 =======
- (CGSize)collectionViewContentSize {
   
    CGFloat height = 0;
    CGFloat width = 0;
    NSInteger totalSections = [self.collectionView numberOfSections];
    for (NSInteger i=0; i<totalSections; i++) {
        // 每个分区section的高度
        CGFloat sectionH = 0;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewSectionHeadSizeForSection:)]) {
            sectionH = [_delegate collectionViewSectionHeadSizeForSection:i].height;
        }
        //拿到每个分区所有item的个数
        NSInteger totalItems = [self.collectionView numberOfItemsInSection:i];
        // 每个分区item的高度
        CGFloat itemH = 0;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionViewItemSizeForIndexPath:)] && totalItems > 0) {
            itemH = [_delegate collectionViewItemSizeForIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]].height;
        }
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {// 纵向滚动
            if (_itemSizeType == ItemSizeEqualAll || _itemSizeType == ItemSizeEqualWidth) {
                 height += sectionH + [self maxColumnHightValue:i];
            }else{
                 height += sectionH + (itemH + _interSpace) * [_widthArr[i] count];
            }

        }else{
            height += sectionH + _interSpace + itemH + _interSpace;
        }
        
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {// 纵向滚动
        height += _interSpace * totalSections ;
        width =self.collectionView.frame.size.width;
    }else{           // 横向滚动     
        width = [self maxLineWidthValue] + _interSpace;
    }
    
    return CGSizeMake(width, height);
}

#pragma mark ====== 返回所有的Element的ayoutAttribute =======
/*
 这个方法的返回值是个数组
 这个数组中存放的都是UICollectionViewLayoutAttributes对象
 UICollectionViewLayoutAttributes对象决定了cell的排布方式（frame等）
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return _attributeArray;
}

#pragma mark ====== Calculate =======
// 每次取最小x的行
- (NSInteger)minCurrentLineWithSection:(NSInteger)section {
    __block CGFloat minWidth = CGFLOAT_MAX;
    __block NSInteger minIndex = 0;
    NSArray *arr = _widthArr[section];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentWidth = [arr[idx] floatValue];
        if (currentWidth < minWidth) {
            minWidth = currentWidth;
            minIndex = idx;
        }
    }];
    
    return minIndex;
}

// 最大的行宽值
- (CGFloat)maxLineWidthValue{
    __block CGFloat maxWidth = CGFLOAT_MIN;
    [_widthArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentWidth = [_widthArr[idx] floatValue];
        if (currentWidth > maxWidth) {
            maxWidth = currentWidth;
        }
    }];
    return maxWidth;
}

// 每次取最小y的列
- (NSInteger)minCurrentColWithSection:(NSInteger)section {
    __block CGFloat minHeight = CGFLOAT_MAX;
    __block NSInteger minIndex = 0;
    NSArray *arr = _heightArr[section];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentHeight = [arr[idx] floatValue];
        if (currentHeight < minHeight) {
            minHeight = currentHeight;
            minIndex = idx;
        }
    }];
    return minIndex;
}

// 某一个分区的最小的列高值
- (CGFloat)maxColumnHightValue:(NSInteger)section{
    __block CGFloat maxHeight = CGFLOAT_MIN;
    NSArray *arr = _heightArr[section];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentHeight = [arr[idx] floatValue];
        if (currentHeight > maxHeight) {
            maxHeight = currentHeight;
        }
    }];
    return maxHeight;
}

#pragma mark ====== Lazy =======
-(NSMutableArray *)widthArr{
    if (_widthArr==nil) {
        _widthArr=[[NSMutableArray alloc] init];
    }
    return _widthArr;
}

-(NSMutableArray *)heightArr{
    if (_heightArr==nil) {
        _heightArr=[[NSMutableArray alloc] init];
    }
    return _heightArr;
}

-(NSMutableArray *)attributeArray{
    if (_attributeArray==nil) {
        _attributeArray=[[NSMutableArray alloc] init];
    }
    return _attributeArray;
}

#pragma mark ====== Setter OR Getter =======
-(NSInteger)numberOfLines{
    return MAX(_numberOfLines, 1);
}

- (void)setInterSpace:(CGFloat)interSpace {
    if (_interSpace != interSpace) {
        _interSpace = interSpace;
        [self invalidateLayout];
    }
}
@end