//
//  LPDQuoteImagesView.m
//  LPDQuoteImagesController
//
//  Created by Assuner on 2016/12/16.
//  Copyright © 2016年 Assuner. All rights reserved.
//

#import "LPDQuoteImagesView.h"


@interface LPDQuoteImagesView ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>

{
    CGFloat _itemWH;
};

//@property (assign, nonatomic) BOOL isSelectOriginalPhoto;            ///是否选了原图

@property (assign, nonatomic) NSUInteger countPerRowInView;           ///view每行照片数

@property (assign, nonatomic) CGFloat margin;                         ///已选图片页面Cell的间距
@property (assign, nonatomic) UIEdgeInsets contentInsets;             ///collectionView的edge配置

@property (strong, nonatomic) UIImagePickerController *imagePickerVc; ///系统的picker，调用相机

@end

@implementation LPDQuoteImagesView

- (instancetype)initWithFrame:(CGRect)frame withCountPerRowInView:(NSUInteger)ArrangeCount cellMargin:(CGFloat)cellMargin{
    if(self = [super initWithFrame: frame]){
        self.backgroundColor = [UIColor whiteColor];
        _selectedPhotos = [[NSMutableArray alloc] init];
        _selectedAssets = [[NSMutableArray alloc] init];
        
        _maxSelectedCount = 9;
        _countPerRowInView = 5;
        _countPerRowInAlbum = 4;
        _margin = 12;
        _contentInsets = UIEdgeInsetsMake(12, 4, 12, 8);
        
        if(ArrangeCount > 0){
            _countPerRowInView = ArrangeCount;
        }
        
        if(cellMargin > 0){
            _margin = cellMargin;
            _contentInsets = UIEdgeInsetsMake(10, _margin/2-2, 0, _margin/2+2);
        }
        
        [self configCollectionView];
    }
    return self;
}


- (UIImagePickerController *)imagePickerVc {///系统的picker，可调用相机
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        
        UIBarButtonItem *lpdBarItem, *BarItem;
            if (@available(iOS 9.0, *)) {
                lpdBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
                BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];

            } else {
                lpdBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
                BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
            }
       
        NSDictionary *titleTextAttributes = [lpdBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    /**********LPDPhotoArrangeCVlLayout******** 拖动排序用这个**********************/
    
    _itemWH = self.lpd_width - 20 / _countPerRowInView - _margin;
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumInteritemSpacing = _margin;
    layout.minimumLineSpacing = _margin;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, self.lpd_width - 20, self.lpd_height) collectionViewLayout:layout];
//    UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
//    _collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, -10);
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = _contentInsets;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self addSubview:_collectionView];
    [_collectionView registerClass:[LPDPhotoArrangeCell class] forCellWithReuseIdentifier:@"LPDPhotoArrangeCell"];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_selectedPhotos.count < _maxSelectedCount) {
        return _selectedPhotos.count + 1;
    }else {
        return _selectedPhotos.count  ;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LPDPhotoArrangeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LPDPhotoArrangeCell" forIndexPath:indexPath];
    cell.videoThumbnail.hidden = YES;
    if(_selectedPhotos.count<_maxSelectedCount) {
        if (indexPath.row == _selectedPhotos.count) {
            (cell.imageThumbnail).image = [UIImage imageNamed:@"矩形复制"];
//            [cell.jiaImgView setImage:[UIImage imageNamed:@"jia-copy"]];
            cell.imageThumbnail.layer.borderWidth = 0;
            cell.jiaImgView.hidden = NO;
            cell.nookDeleteBtn.hidden = YES;
            
        } else {
            cell.imageThumbnail.image = _selectedPhotos[indexPath.row];
            cell.asset = _selectedAssets[indexPath.row];
            cell.imageThumbnail.layer.borderWidth = 0;
            cell.jiaImgView.hidden = YES;
            cell.nookDeleteBtn.hidden = NO;
            
        }
    }else {
        cell.imageThumbnail.image = _selectedPhotos[indexPath.row];
        cell.asset = _selectedAssets[indexPath.row];
        cell.imageThumbnail.layer.borderWidth = 0;
        cell.jiaImgView.hidden = YES;
        cell.nookDeleteBtn.hidden = NO;
    }
    cell.nookDeleteBtn.tag = indexPath.row;
    [cell.nookDeleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    if (self.delegate  && [self.delegate respondsToSelector:@selector(getSelectedPhotos:)]) {
        [self.delegate getSelectedPhotos:_selectedPhotos];
    }
    return cell;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self pushImagePickerController];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count) {
        if (self.isShowTakePhotoSheet) {
            UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"取消" message:@"拍照" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
            UIAlertAction *select = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self takePhoto];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *other = [UIAlertAction actionWithTitle:@"去相册选择" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [self pushImagePickerController];
            }];
            [alertView addAction:select];
            [alertView addAction:cancel];
            [alertView addAction:other];
            [[self ViewController:self] presentViewController:alertView animated:YES completion:nil];
            [sheet showViewController:[self ViewController:self] sender:self];
            
        } else {
            [self pushImagePickerController];
        }
        
    } else { //预览照片或者视频
        id asset = _selectedAssets[indexPath.row];
        BOOL isVideo = NO;
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = asset;
            isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = asset;
            isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        }
        if (isVideo) { // 预览视频
            TZVideoPlayerController*vc = [[TZVideoPlayerController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
            vc.model = model;
            [self.navcDelegate presentViewController:vc animated:YES completion:nil];
        } else { // 预览照片
            TZImagePickerController *selectImagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
            selectImagePickerVc.maxImagesCount = _maxSelectedCount;
            selectImagePickerVc.allowPickingOriginalPhoto = NO;
            
            selectImagePickerVc.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                _selectedPhotos = [NSMutableArray arrayWithArray:photos];
                _selectedAssets = [NSMutableArray arrayWithArray:assets];
                [_collectionView reloadData];
                _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
            };
            [self.navcDelegate presentViewController:selectImagePickerVc animated:YES completion:nil];
        }
    }
}

#pragma mark - LPDPhotoArrangeCVDataSource

/// 长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < _selectedPhotos.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < _selectedPhotos.count && destinationIndexPath.item < _selectedPhotos.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    
    [_collectionView reloadData];
}
//
- (void)pushImagePickerController {
    if (self.maxSelectedCount <= 0) {
        return;
    }
    TZImagePickerController *lpdImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxSelectedCount columnNumber:self.countPerRowInAlbum delegate:self pushPhotoPickerVc:YES];
    lpdImagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    lpdImagePickerVc.allowPickingVideo = NO;
    lpdImagePickerVc.allowPickingOriginalPhoto = NO;
    lpdImagePickerVc.sortAscendingByModificationDate = NO;
    
    if (self.maxSelectedCount > 1) {
        // 设置目前已经选中的图片数组去初始化picker
        lpdImagePickerVc.selectedAssets = _selectedAssets;
        lpdImagePickerVc.showSelectBtn = NO;
        
    }else {
        lpdImagePickerVc.showSelectBtn = YES;
    }
//    [self.navcDelegate presentViewController:lpdImagePickerVc animated:YES completion:nil];
    [[self ViewController:self] presentViewController:lpdImagePickerVc animated:YES completion:nil];
}
//找到UIViewController
-(UIViewController *)ViewController:(id)my_self{
    for (UIView* next = [my_self superview]; next; next = next.superview) {
        UIResponder *nextResponder = next.nextResponder;
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}
#pragma mark - UIImagePickerController

- (void)takePhoto {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if (@available(iOS 8.0, *)) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }

        [[self ViewController:self] presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *lpdImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        lpdImagePickerVc.sortAscendingByModificationDate = YES;
        [lpdImagePickerVc showProgressHUD];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        //  保存图片，获取到asset
        if (!image) {
            return;
        }
        [[TZImageManager manager] savePhotoWithImage:image completion:^(PHAsset *asset, NSError *error) {
            {
                        if (error) {
                            [lpdImagePickerVc hideProgressHUD];
                            NSLog(@"图片保存失败 %@",error);
                        } else {
                            [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES needFetchAssets:NO completion:^(TZAlbumModel *model) {
                                [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                                    [lpdImagePickerVc hideProgressHUD];
                                    TZAssetModel *assetModel = models.firstObject;
                                    if (lpdImagePickerVc.sortAscendingByModificationDate) {
                                        assetModel = models.lastObject;
                                    }

                                    [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                                }];
                            }];
                        }
                    }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    [_collectionView reloadData];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}



#pragma mark - LPDImagePickerControllerDelegate


/// 用户点击了取消 代理
- (void)lpd_imagePickerControllerDidCancel:(LPDImagePickerController *)picker {
    NSLog(@"cancel");
}


// lpdImagePicker每次选照片后的保存和更新操作
- (void)imagePickerController:(LPDImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    
    [_collectionView reloadData];
    
    //test**********[self printAssetsName:assets];
}

// 选择了一个视频的代理方法
- (void)imagePickerController:(LPDImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    
    /*************** 打开这段代码发送视频
     [[LPDImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
     NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
     }]; ***********************/
    
    [_collectionView reloadData];
}

#pragma mark - DeleteBtn
- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    
    if(_selectedPhotos.count == _maxSelectedCount - 1){
        [_collectionView reloadData];
    }else{
        [_collectionView performBatchUpdates:^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {
            [_collectionView reloadData];
        }];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
