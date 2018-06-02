//
//  IPImageReaderViewController.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageReaderViewController.h"
#import "IPZoomScrollView.h"
#import "IPAssetModel.h"
#import "IPAlertView.h"
#import<AssetsLibrary/AssetsLibrary.h>
#import "IPPrivateDefine.h"
#import "IPAnimationTranstion.h"
#import "IPImageReaderCell.h"
#import "IPImageReaderLayout.h"

@interface IPImageReaderViewController ()<UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

/**图片数组*/
@property (nonatomic, strong)NSArray *dataArr;

/**第一次出现时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isFirst;

/**发生转屏时,要滚动到指定位置*/
@property (nonatomic, assign)BOOL isRoration;

/**需要跳转到指定位置*/
@property (nonatomic, assign)NSUInteger currentPage;

/**左返回按钮*/
@property (nonatomic, weak)UIButton *leftButton;

/**右返回按钮*/
@property (nonatomic, weak)UIButton *rightButton;

/**头部视图*/
@property (nonatomic, weak)UIImageView *headerView;

/**旋屏前的位置*/
@property (nonatomic, assign)NSUInteger pageIndexBeforeRotation;

@end

@implementation IPImageReaderViewController

static NSString * const reuseIdentifier = @"Cell";
+ (instancetype)imageReaderViewControllerWithData:(NSArray<IPAssetModel *> *)data TargetIndex:(NSUInteger)index{
    if (data == nil || data.count == 0 ) {
        return nil;
    }
    IPImageReaderLayout *layout = [IPImageReaderLayout new];
    
    IPImageReaderViewController *vc = [[IPImageReaderViewController alloc]initWithCollectionViewLayout:layout];
    vc.dataArr = data;
    vc.currentPage = index;
    return vc;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _animationTranstionBgColor = [UIColor blackColor];
    self.view.backgroundColor = _animationTranstionBgColor;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.navigationController.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    [self.collectionView registerClass:[IPImageReaderCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addHeaderView];
    
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)addHeaderView{
    
    //添加背景图
    UIImageView *headerView = [[UIImageView alloc]init];
    headerView.userInteractionEnabled = YES;
    UIImage *headerImage =[UIImage imageNamed:@"photobrowse_top"];
    headerView.image = headerImage;
    headerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *leftBtnImage =[UIImage imageNamed:@"bar_btn_icon_returntext_white"];
    [leftBtn setImage:leftBtnImage forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:leftBtn];
    self.leftButton = leftBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *image =[UIImage imageNamed:@"img_icon_check_Big"];
    UIImage *image_p =[UIImage imageNamed:@"img_icon_check_Big_p"];
    [rightBtn setImage:image forState:UIControlStateNormal];
    [rightBtn setImage:image_p forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:rightBtn];
    self.rightButton = rightBtn;
    
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, IOS7_STATUS_BAR_HEGHT + 44);
    self.leftButton.frame = CGRectMake(-5, IOS7_STATUS_BAR_HEGHT, 44, 44);
    self.rightButton.frame = CGRectMake(self.view.bounds.size.width - 44, IOS7_STATUS_BAR_HEGHT, 44, 44);
    
    NSUInteger maxIndex = self.dataArr.count - 1;
    NSUInteger minIndex = 0;
    if (self.currentPage < minIndex) {
        self.currentPage = minIndex;
    } else if (self.currentPage > maxIndex) {
        self.currentPage = maxIndex;
    }
    if (self.isFirst == NO) {
        
        if (self.currentPage == 0) {//当滚动到0的位置时,默认是不调用scrolldidscroll方法的
            IPAssetModel *model = self.dataArr[0];
            self.rightButton.selected = model.isSelect;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        self.isFirst = YES;
    }
    if (self.isRoration) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        self.isRoration = NO;
        IPAssetModel *model = self.dataArr[_currentPage];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        [thePage displayImageWithFullScreenImage];
    }
    if (self.forceTouch) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentPage inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        IPAssetModel *model = self.dataArr[_currentPage];
        IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
        if (thePage) {
            self.forceTouch = NO;
            [thePage displayImageWithFullScreenImage];
        }
        
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    IPAssetModel *model = self.dataArr[_currentPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
    self.navigationController.delegate = self;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
     IPLog(@"IPImageReaderViewController---didReceiveMemoryWarning");
    
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    
    IPLog(@"IPImageReaderViewController---dealloc");
}
- (void)cancle{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)selectBtn:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        if (self.currentSelectCount == self.maxSelectCount) {
            [IPAlertView showAlertViewAt:self.view MaxCount:self.maxSelectCount];
            btn.selected = NO;
            return;
        }
        self.currentSelectCount ++;
    }else {
        self.currentSelectCount --;
    }
//    NSLog(@"%tu",_currentPage);
    IPAssetModel *model = self.dataArr[_currentPage];
    model.isSelect = btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickSelectBtnForReaderView:)]) {
        [self.delegate clickSelectBtnForReaderView:model];
    }
    
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Remember page index before rotation
    _pageIndexBeforeRotation = _currentPage;
    
    
}

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
//    // Perform layout
//    _currentPage = _pageIndexBeforeRotation;
//    self.isRoration = YES;
//    
//    IPAssetModel *model = self.dataArr[_currentPage];
//    self.rightButton.selected = model.isSelect;
//    
//    [self.collectionView reloadData];
//}
//#else
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Perform layout
    _currentPage = _pageIndexBeforeRotation;
    self.isRoration = YES;
    
    IPAssetModel *model = self.dataArr[_currentPage];
    self.rightButton.selected = model.isSelect;
    
    [self.collectionView reloadData];
    
}
//#endif




- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.isRoration = NO;
    IPAssetModel *model = self.dataArr[_currentPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
    
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IPImageReaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    IPAssetModel *model = [self.dataArr objectAtIndex:indexPath.item];
    
    cell.zoomScroll.readerVc = self;
    IPLog(@"cellForItemAtIndexPath--%tu",indexPath.item);
    cell.zoomScroll.imageModel = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.view.bounds.size;
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(IPImageReaderCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    IPLog(@"didEndDisplayingCell--%tu",indexPath.item);
//    [cell.zoomScroll prepareForReuse];
    
}

#pragma mark <UICollectionViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isRoration) {
        return;
    }
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self.dataArr count] - 1) index = [self.dataArr count] - 1;
    NSUInteger previousCurrentPage = _currentPage;
    _currentPage = index;
    if (_currentPage != previousCurrentPage) {
        IPAssetModel *model = self.dataArr[_currentPage];
        self.rightButton.selected = model.isSelect;
    }
   
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
   
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 0.0f;
                     }completion:nil];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.headerView.alpha = 1.0f;
                     }completion:nil];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    IPAssetModel *model = self.dataArr[_currentPage];
    IPZoomScrollView *thePage = [self pageDisplayingPhoto:model];
    [thePage displayImageWithFullScreenImage];
    
    NSLog(@"scrollViewDidEndDecelerating");
}

- (IPZoomScrollView *)pageDisplayingPhoto:(IPAssetModel *)model {
    IPZoomScrollView *thePage = nil;
    for (IPImageReaderCell *cell in self.collectionView.visibleCells) {
        if (cell.zoomScroll.imageModel == model) {
            thePage = cell.zoomScroll; break;
        }
    }
    return thePage;
}
#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if ([toVC isKindOfClass:NSClassFromString(@"IPickerViewController")]) {
        IPAnimationInverseTransition *inverseTransition = [[IPAnimationInverseTransition alloc]init];
        return inverseTransition;
    }else{
        return nil;
    }
}


#pragma mark - interface
- (void)setUpCurrentSelectPage:(NSUInteger)page
{
    
}

@end

