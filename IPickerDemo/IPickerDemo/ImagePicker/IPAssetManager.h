//
//  IPAssetManager.h
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/29.
//  Copyright © 2016年 JL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IPAssetManager,IPImageModel,IPAlbumModel,ALAssetsLibrary;

@protocol IPAssetManagerDelegate <NSObject>


- (void)loadImageDataFinish:(IPAssetManager *)manager FirstAccess:(BOOL)isFirst;

@end




@interface IPAssetManager : NSObject

@property (nonatomic, weak) id <IPAssetManagerDelegate> delegate;

/**相册数组*/
@property (nonatomic, strong)NSMutableArray *albumArr;

/**当前显示的照片数组*/
@property (nonatomic, strong)NSMutableArray *currentPhotosArr;

/**当前显示的专辑列表*/
@property (nonatomic, strong)IPAlbumModel *currentAlbumModel;

+ (instancetype)defaultAssetManager;

/**图库*/
@property (nonatomic, strong)ALAssetsLibrary *defaultLibrary;

- (void)reloadImagesFromLibrary;

- (void)getImagesForAlbumUrl:(NSURL *)albumUrl;

- (void)clearDataCache;
@end