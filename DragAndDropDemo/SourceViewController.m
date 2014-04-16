//
//  SourceViewController.m
//  DragAndDropDemo
//
//  Created by Son Ngo on 2/10/14.
//  Copyright (c) 2014 Son Ngo. All rights reserved.
//

#import "SourceViewController.h"
#import "CardCell.h"

#define draggableCellWidth 260
#define horizontalInset 30

@interface SourceViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
  UICollectionView *_collectionView;
  ViewController *_parentController;
  NSMutableArray *_models;
  MyModel *_selectedModel;
    int currentPage;
}
@end

#pragma mark -
@implementation SourceViewController

- (instancetype)initWithCollectionView:(UICollectionView *)view andParentViewController:(ViewController *)parent {
  if (self = [super init]) {
    [self setUpModels];
    [self initCollectionView:view];
    [self setUpGestures];
      currentPage = 0;
    _parentController = parent;
  }
  return self;
}

- (void)cellDragCompleteWithModel:(MyModel *)model withValidDropPoint:(BOOL)validDropPoint {
  if (model != nil) {
    // get indexPath for the model
    NSUInteger index = [_models indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    if (validDropPoint && indexPath != nil) {
      [_models removeObjectAtIndex:index];
      [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
      
      [_collectionView reloadData];
    } else {
      
      UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
      cell.alpha = 1.0f;
    }
  }
}

#pragma mark - Setup methods
- (void)setUpModels {
  _models = [NSMutableArray array];
  
  for (int i=0; i<10; i++) {
    [_models addObject:[[MyModel alloc] initWithValue:i]];
  }
}

- (void)initCollectionView:(UICollectionView *)view {
  _collectionView            = view;
  _collectionView.delegate   = self;
  _collectionView.dataSource = self;
    _collectionView.contentInset = UIEdgeInsetsMake(0, horizontalInset, 0, horizontalInset);
  [_collectionView registerClass:[CardCell class] forCellWithReuseIdentifier:CELL_REUSE_ID];
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    currentPage = round(scrollView.contentOffset.x / 270);
    if (velocity.x > 0)
        currentPage++;
    else
        currentPage--;
    if (currentPage < 0)
        currentPage = 0;
    else if (currentPage >= [_models count])
        currentPage = [_models count]-1;
    CGFloat hOffset = 240 + 270*(currentPage-1);        ////////////todo: handle landscape and ipad
    *targetContentOffset = CGPointMake(hOffset,0);
}

- (void)setUpGestures {
  
  UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handlePress:)];
  longPressGesture.numberOfTouchesRequired = 1;
  longPressGesture.minimumPressDuration    = 0.1f;
  [_collectionView addGestureRecognizer:longPressGesture];
}

#pragma mark - Gesture Recognizer
- (void)handlePress:(UILongPressGestureRecognizer *)gesture {
  CGPoint point = [gesture locationInView:_collectionView];
 
  if (gesture.state == UIGestureRecognizerStateBegan) {
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:point];
    if (indexPath != nil) {
      _selectedModel = [_models objectAtIndex:indexPath.item];
      
      // calculate point in parent view
      point = [gesture locationInView:_parentController.view];
      
      [_parentController setSelectedModel:_selectedModel atPoint:point];
      
      // hide the cell
      [_collectionView cellForItemAtIndexPath:indexPath].alpha = 0.0f;
    }
  }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  CardCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_ID forIndexPath:indexPath];
  
  MyModel *model = [_models objectAtIndex:indexPath.item];
  [cell setModel:model];
  
  return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(draggableCellWidth, 50);
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//  return UIEdgeInsetsMake(0, 10, 0, 10);
//}

@end
