//
//  IPImageCell.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAssetModel,IPickerViewController;
@protocol IPImageCellDelegate<NSObject>

- (BOOL)clickRightCornerBtnForView:(IPAssetModel *)assetModel;

@end
@interface IPImageCell : UICollectionViewCell
@property (nonatomic, readonly) UIButton *rightCornerBtn;
/**缩略图*/
@property (nonatomic, readonly) UIImageView *imgView;

/**ipvc*/
@property (nonatomic, weak) IPickerViewController *ipVc;
/**代理*/
@property (nonatomic, weak) id <IPImageCellDelegate> delegate;
/**数据模型*/
@property (nonatomic, strong) IPAssetModel *model;
- (void)endDisplay;
- (void)prepareForReuse;
- (void)setUpCameraPreviewLayer;
@end
