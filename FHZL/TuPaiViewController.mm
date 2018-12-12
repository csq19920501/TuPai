//
//  TuPaiViewController.m
//  FHZL
//
//  Created by hk on 2018/1/30.
//  Copyright © 2018年 hk. All rights reserved.
//
#import "TuPaiNewsVC.h"
#import "CYTabBarController.h"
#import "PictureEditVC_TwoFirst.h"
#import "MapPhoneModel.h"
#import <AVFoundation/AVFoundation.h>
#import "PictureEditVC.h"
#import "TuPaiViewController.h"
#import "Header.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "LookPeople.h"
#import "ImageSingelModel.h"
#import "CSQPhotoPreviewController.h"
#import "TIPmodel.h"
#import "KDXFvoiceManager.h"
#import "WMTimeLineViewController1.h"
#import "PreviewVC.h"
#define LS(key)  NSLocalizedString(key, nil)

#import "BMKClusterManager.h"
#import "photoTableviewC.h"
#import "UserCenterOldVC.h"
#import "NewBiaoTiVC.h"
#import "CSQ_titleImageButton.h"
#import "CityChangeViewController.h"
#import "NewMyVC.h"
#import "ShopCarVC.h"
/*
 *点聚合Annotation
 */
@interface ClusterAnnotation : BMKPointAnnotation

///所包含annotation个数
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong)NSArray* csqPhoneArray;

@end

@implementation ClusterAnnotation

@synthesize size = _size;

@end


/*
 *点聚合AnnotationView
 */
@interface ClusterAnnotationView : BMKPinAnnotationView {
    
}

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic,strong) UIImageView *photoView;

@end

@implementation ClusterAnnotationView

@synthesize size = _size;
@synthesize label = _label;
@synthesize photoView = _photoView;

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBounds:CGRectMake(0.f, 0.f, 50.f, 50.f)];

        _photoView = [UIImageView new];
        CGFloat wigthPhoto = 50;
        _photoView.frame = CGRectMake((self.width - wigthPhoto)/2 , (self.height - wigthPhoto)/2, wigthPhoto,wigthPhoto);
        _photoView.layer.masksToBounds = YES;
        _photoView.layer.cornerRadius = _photoView.width/2;
        [self addSubview:_photoView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(30.f, 0.f, 20, 20)];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:10];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor blueColor];
        _label.layer.masksToBounds = YES;
        _label.layer.cornerRadius = _label.width/2;
        if (IOS_VERSION >= 10.0) {
            self.label.adjustsFontSizeToFitWidth = YES;
        }
        [self addSubview:_label];
        self.alpha = 0.85;
    }
    return self;
}

- (void)setSize:(NSInteger)size {
    _size = size;
    if (_size == 1) {
        self.label.hidden = YES;
        self.pinColor = BMKPinAnnotationColorRed;
        return;
    }
    self.label.hidden = NO;
    _label.text = [NSString stringWithFormat:@"%ld", size];
    if (size > 99) {
        self.label.backgroundColor = [UIColor redColor];
        _label.text = @"99+";
    }
    else if (size > 9) {
        self.label.backgroundColor = [UIColor purpleColor];
        _label.text = [NSString stringWithFormat:@"%ld", size];
    }
    else if (size > 5) {
        self.label.backgroundColor = [UIColor blueColor];
    } else {
        self.label.backgroundColor = [UIColor greenColor];
    }
}
@end


@interface TuPaiViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UISearchBarDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,navcDelegate,BMKSuggestionSearchDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BMKLocationService* _locService;
    CLLocationCoordinate2D _userCoordinate;

    BOOL isFirst;
    NSMutableArray *photoDataArray;
//    NSMutableArray *imageArray;
    MapPhoneModel *photoModelAdding;
    
    BMKClusterManager *_clusterManager;//点聚合管理类
    NSInteger _clusterZoom;//聚合级别
    NSMutableArray *_clusterCaches;//点聚合缓存标注
    photoTableviewC *photoTableview;
    
    BMKSuggestionSearch *_searcher;
    NSMutableArray *dataArr;
    UITableView *_searchTableView;
}
@property (weak, nonatomic) IBOutlet BMKMapView *_mapView;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic, strong) LookPeople *phoneAnnotation;
@property (nonatomic,strong)NSMutableArray *imageArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstant;
@property (nonatomic,strong)UISearchBar *searchBar;

@property(nonatomic,strong)CSQ_titleImageButton *addressButton;



@end

@implementation TuPaiViewController

- (IBAction)mapAdd:(id)sender {
    __mapView.zoomLevel ++;
}
- (IBAction)mapDele:(id)sender {
    __mapView.zoomLevel --;
}
- (IBAction)changeMapType:(id)sender {
    UIButton *but = (UIButton *)sender;
    but.selected = !but.selected;
    if (but.selected) {
        __mapView.mapType = BMKMapTypeSatellite;
    }else{
        __mapView.mapType = BMKMapTypeStandard;
    }
}

- (IBAction)userLocation:(id)sender {
    BMKCoordinateRegion userRegion ;
    userRegion.center = _userCoordinate;
    userRegion.span.latitudeDelta = 0.01;
    userRegion.span.longitudeDelta = 0.01;
    [__mapView setRegion:userRegion animated:NO];
}
- (IBAction)crameaClick:(id)sender {
//    NSLog(@"拍照");
//    NewBiaoTiVC *vc = [[NewBiaoTiVC alloc]init];
//    vc.enumType = Look;
//    [self.navigationController pushViewController:vc animated:YES];
//
//    return;
    [self getCamera];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.topConstant.constant = kTopHeight;
    isFirst = YES;
    _clusterCaches = [[NSMutableArray alloc] init];
    photoDataArray = [NSMutableArray array];
    _imageArray = [NSMutableArray array];
    _clusterManager = [[BMKClusterManager alloc] init];
    [self  setNavi];
    [self setMap];
    __mapView.showsUserLocation = YES;//显示定位图层
    [_locService startUserLocationService];
    
    _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSearch.delegate = self;
    [self getPhotoArray];
    
    _searcher = [[BMKSuggestionSearch alloc] init];
    _searcher.delegate = self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [__mapView viewWillAppear];
    __mapView.delegate = self;
    _locService.delegate = self;
    _geoCodeSearch.delegate = self;
    _searcher.delegate = self;
    [self changeNavi];
    [self changeUserInfo];
    if (!isFirst) {
        [self getPhotoArrayNoUiutil];
    }
    self.navigationController.navigationBar.hidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [__mapView viewWillDisappear];
    __mapView.delegate = nil;
    
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    _geoCodeSearch.delegate = nil;
    _searcher.delegate = nil;
}
#pragma mark mapDele
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    [__mapView updateLocationData:userLocation];
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    [__mapView updateLocationData:userLocation];
    
    _userCoordinate = CLLocationCoordinate2DMake( userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    USERMANAGER.mapDetial.userCoordinate   = _userCoordinate;
    if (isFirst) {
        isFirst = NO;
        BMKCoordinateRegion userRegion ;
        userRegion.center = _userCoordinate;
        userRegion.span.latitudeDelta = 0.01;
        userRegion.span.longitudeDelta = 0.01;
        [__mapView setRegion:userRegion animated:NO];
//        [self addAllAnnotation];
    }

}
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
    
    [_searchBar resignFirstResponder];
    [self.view  endEditing:YES];
    _searchTableView.hidden = YES;
}
//点中地图标注后会回调此接口
-(void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi
{
    [_searchBar resignFirstResponder];
    [self.view  endEditing:YES];
    _searchTableView.hidden = YES;
}


-(void)setMap{
    __mapView.zoomLevel = 16.f;
    __mapView.delegate = self;
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isRotateAngleValid = true;
    param.isAccuracyCircleShow = NO;
    param.locationViewImgName = @"bnavi_icon_location_fixed@2x";
    param.locationViewOffsetX = 0;
    param.locationViewOffsetY = 0;
    [__mapView updateLocationViewWithParam:param];
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService setPausesLocationUpdatesAutomatically:NO];
    //  [_locService setAllowsBackgroundLocationUpdates:YES];
    
    dataArr = [NSMutableArray array];
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(50, kTopHeight, kScreenWidth - 100, 220)];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.hidden = YES;
    [self.view addSubview:_searchTableView];
}
-(void)changeAddress{
    CityChangeViewController *cityVC = [CityChangeViewController new];
    cityVC.successBlock = ^(NSString *cityStr){
        [self.addressButton setTitle:cityStr forState:UIControlStateNormal];
    };
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:cityVC];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)setNavi{
    self.view.backgroundColor = HBackColor;
    //上架临时处理
    CSQ_titleImageButton *seleAddressBut = [[CSQ_titleImageButton alloc]init];
    [seleAddressBut setTitle:@"深圳" forState:UIControlStateNormal];
    [seleAddressBut setImage:[UIImage imageNamed:@"排行榜_向下"] forState:UIControlStateNormal];
    seleAddressBut.frame = CGRectMake(0, 0, 60, 30);
    [seleAddressBut addTarget:self action:@selector(changeAddress) forControlEvents:UIControlEventTouchUpInside];
    self.addressButton = seleAddressBut;
    seleAddressBut.titleLabel.font = [UIFont systemFontOfSize:13];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:seleAddressBut];
    
    [self addNavigationItemWithImageNames
     :@[@"ui2_user_icon0.png"] isLeft:NO target:self action:@selector(showLeft) tags:@[@1001]];

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 160, 40)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.frame = titleView.frame;
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.placeholder = @"搜标签";
    [titleView addSubview:_searchBar];
    
    for (UIView *view in _searchBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            for (UIView *subView in view.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]){
                    //设置输入框
//                    [subView setBackgroundColor:RGB(19, 147, 222)];
//                    [(UITextField*)subView setTextColor:[UIColor whiteColor]];
                     break;
                }
            }
        }
    }
    _searchBar.backgroundImage = [UIImage imageNamed:@"透明.jpg"];
    self.navigationItem.titleView = titleView;
}
-(void)showLeft{

    CYTabBarController *GT_10Tabbar = [[CYTabBarController alloc]init];
    [CYTabBarConfig shared].selectedTextColor = [UIColor colorWithRed:45/255. green:159/255. blue:254/255. alpha:1];
    
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:[NewMyVC new]];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:[TuPaiNewsVC new]];
    
    
    ShopCarVC *VC3 = [ShopCarVC new];
    VC3.hasTarbar = YES;
    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:VC3];

    [GT_10Tabbar addChildController:nav1 title:@"我的" imageName:@"底部_定位_N.png" selectedImageName:@"底部_定位_P.png"];
    [GT_10Tabbar addChildController:nav2 title:@"消息" imageName:@"底部_列表_N.png"  selectedImageName:@"底部_列表_P.png"];
    [GT_10Tabbar addChildController:nav3 title:@"购物车" imageName:@"底部_警报信息_N.png"  selectedImageName:@"底部_警报信息_P.png"];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController pushViewController:GT_10Tabbar animated:YES];
}
-(void)showRight{
    WMTimeLineViewController1 * VC = [[WMTimeLineViewController1 alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark cramea


//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == actionSheet.destructiveButtonIndex) {
//        NSLog(@"拍照");
//        [self getCamera];
//
//    } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
//        NSLog(@"相册");
//        [self openImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    }
//}

#pragma mark 拍摄完成后要执行的方法
//Changed by boris on 2016.10.25
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSData *finalData = nil;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"拍摄%@",image);
        UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
        
        //得到图片
//        [_headImage setBackgroundImage:info[@"UIImagePickerControllerEditedImage"] forState:UIControlStateNormal];
//        finalData = UIImageJPEGRepresentation(info[@"UIImagePickerControllerEditedImage"], 0.5);
        
        PictureEditVC_TwoFirst  *pictVC = [[PictureEditVC_TwoFirst alloc]init];
        pictVC.photoImage = image;
        pictVC.pictureEditV_Type = PictureEditV_New;
        [pictVC setUpdatePictureSuccess:^{
            NSLog(@"上传图片成功返回图拍主页面刷新图片");
//            _searchBar.text = nil;
//            [self getPhotoArray];
        }];
        [self.navigationController pushViewController:pictVC animated:YES];

        [self dismissViewControllerAnimated:YES completion:^{
////            [UIUtil showProgressHUD:nil inView:self.view];
//
        }];

    } else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
         NSLog(@"拍摄%@", info[@"UIImagePickerControllerEditedImage"]);
//        [_headImage setBackgroundImage:info[@"UIImagePickerControllerEditedImage"] forState:UIControlStateNormal];
//        finalData = UIImageJPEGRepresentation(info[@"UIImagePickerControllerEditedImage"], 0.5);
         [self dismissViewControllerAnimated:YES completion:nil];
    }
    //Upload head image
    if (finalData) {
//        NSDictionary *dict = @{@"nickname":self.cdm.userInfoEntity.nickName,@"access_token":self.cdm.userInfoEntity.accessToken};
//        [self uploadHeadImage:finalData withParams:dict];
    }
    //退出相册
}


//更新聚合状态
- (void)updateClusters {
    _clusterZoom = (NSInteger)__mapView.zoomLevel;
    NSLog(@"_clusterZoom = %d",_clusterZoom);
    @synchronized(_clusterCaches) {
        if ((_clusterZoom - 3)>= _clusterCaches.count) {
            NSLog(@"_clusterCaches.count = %lu",(unsigned long)_clusterCaches.count);
            _clusterZoom  = _clusterCaches.count - 1 + 3;
        }
        __block NSMutableArray *clusters = [_clusterCaches objectAtIndex:(_clusterZoom - 3)];
        
        if (clusters.count > 0) {
            [__mapView removeAnnotations:__mapView.annotations];
            [__mapView addAnnotations:clusters];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ///获取聚合后的标注
                __block NSArray *array = [_clusterManager getClusters:_clusterZoom];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (BMKCluster *item in array) {
                        ClusterAnnotation *annotation = [[ClusterAnnotation alloc] init];
                        annotation.coordinate = item.coordinate;
                        annotation.size = item.size;
                        annotation.csqPhoneArray = item.clusterItems;
                        [clusters addObject:annotation];
                    }
                    [__mapView removeAnnotations:__mapView.annotations];
                    [__mapView addAnnotations:clusters];
                });
            });
        }
    }
}
#pragma mark annotionView
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //普通annotation
    NSString *AnnotationViewID = @"ClusterMark";
    ClusterAnnotation *cluster = (ClusterAnnotation*)annotation;
    ClusterAnnotationView *annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    annotationView.size = cluster.size;
    annotationView.draggable = NO;
    annotationView.annotation = cluster;
    //必须设置YES 才能显示气泡
    annotationView.canShowCallout = NO;
    if (cluster.csqPhoneArray.count >0) {
        BMKClusterItem *ClusterItem =  cluster.csqPhoneArray[0];
        photoModelAdding = ClusterItem.csqPhoneModel;
        if([photoModelAdding.icconid integerValue] == 13 || [photoModelAdding.icconid integerValue] == 14){
            [annotationView.photoView sd_setImageWithURL:[NSURL URLWithString:photoModelAdding.headPicPath] placeholderImage:[UIImage imageNamed:@"微众世界_头像0"]];
        }else{
            annotationView.photoView.image = [UIImage imageNamed:[NSString stringWithFormat:@"ui2_user_icon%ld.png",(long)[photoModelAdding.icconid integerValue]]];
        }
    }
    return annotationView;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"点击大头针");
    if ([view isKindOfClass:[ClusterAnnotationView class]]) {
        
    ClusterAnnotationView *annotationView = (ClusterAnnotationView*)view;
    ClusterAnnotation *cluster = annotationView.annotation;
    if (cluster.csqPhoneArray.count == 1) {
        BMKClusterItem *clusterItem = cluster.csqPhoneArray[0];
        MapPhoneModel *model = clusterItem.csqPhoneModel;
        [self showModel:model];
    }else{
//        [UIUtil showToast:@"功能待开发" inView:self.view];
        photoTableview = [[photoTableviewC alloc]init];
        
        photoTableview.modelArray = [cluster.csqPhoneArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            BMKClusterItem *ClusterItem1 = (BMKClusterItem*)obj1;
            MapPhoneModel *model1 = ClusterItem1.csqPhoneModel;
            BMKClusterItem *ClusterItem2 = (BMKClusterItem*)obj2;
            MapPhoneModel *model2 = ClusterItem2.csqPhoneModel;
            if ([model1.groupDate integerValue] < [model2.groupDate integerValue]) {
                return NSOrderedDescending;
            } else if ([model1.groupDate integerValue] > [model2.groupDate integerValue]) {
                return NSOrderedAscending;
            }else{
                return NSOrderedSame;
            }
        }];
        
//        [photoTableview.modelArray addObjectsFromArray:cluster.csqPhoneArray];
        
        
        
        [photoTableview showInView:[AppData theTopView]];
        [photoTableview reloadData];
        MPWeakSelf(self)
        [photoTableview setDidClickCell:^(MapPhoneModel *model){
            [weakself showModel:model];
        }];
    }
    [mapView deselectAnnotation:view.annotation animated:NO];
        
    }
}
/**
 *地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
 *@param mapview 地图View
 *@param status 此时地图的状态
 */
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
    if (_clusterZoom != 0 && _clusterZoom != (NSInteger)mapView.zoomLevel) {
//        [self updateClusters];
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (kStringIsEmpty(_searchBar.text)) {
        [self getPhotoArrayNoUiutil];
    }else{
        [self updateClusters];
    }
}

-(void)showModel:(MapPhoneModel*)model{
    
    NewBiaoTiVC *newBiaoTiVC = [[NewBiaoTiVC alloc]init];
    newBiaoTiVC.mapPhoneModel = model;
    if ([model.userID isEqualToString: USERMANAGER.user.userID]) {
        newBiaoTiVC.enumType = AddType;
    }else{
        newBiaoTiVC.enumType = Look;
    }
    [self.navigationController pushViewController:newBiaoTiVC animated:YES];
    return;
    
    [UIUtil showProgressHUD:nil inView:self.view];
    NSDictionary *dic = @{@"groupId":CsqStringIsEmpty(model.ID)};
    [ZZXDataService HFZLRequest:@"photo/show-photo" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             [UIUtil hideProgressHUD];
             [_imageArray removeAllObjects];
             NSArray *imageArr = data[@"data"];
             if (!kArrayIsEmpty(imageArr)) {
                 for (NSDictionary *imageDict in imageArr) {
                     ImageSingelModel *model1 = [ImageSingelModel provinceWithDictionary:imageDict];
                     [_imageArray addObject:model1];
                 }
                 BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([model.y floatValue], [model.x floatValue]));
                 BMKMapPoint point2 = BMKMapPointForCoordinate(USERMANAGER.mapDetial.userCoordinate);
                 CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
                 
                 _phoneAnnotation = [[LookPeople alloc]init];
                 
                 _phoneAnnotation.distanceLabel.text = [NSString stringWithFormat:@"距离%.0f米",distance];
                 _phoneAnnotation.addressLabel.text = [NSString stringWithFormat:@"%@",model.address];
                 _phoneAnnotation.detailModel = model;
                 
                 MPWeakSelf(self)
                 [_phoneAnnotation setDidClickPhotoButton:^(int number,NSArray*imageArr){
//                     CSQPhotoPreviewController *previewVC = [[CSQPhotoPreviewController alloc]init];
//                     previewVC.photos = imageArr;
//                     previewVC.currentIndex = number;
//                     [previewVC setDidDismiss:^{
//                         weakself.phoneAnnotation.hidden = NO;
//                     }];
//                     [weakself.navigationController pushViewController:previewVC animated:YES];
//                     MPStrongSelf(imageArray)
                     
//                     PreviewVC *preVC = [[PreviewVC alloc]init];
//                     [preVC.photoArray addObjectsFromArray:weakself.imageArray];
//                     preVC.detailModel = model;
//                     [preVC setDeleSuccess:^{
//                         NSLog(@"删除成功返回图拍主页面刷新图片");
//                         weakself.searchBar.text = nil;
//                         [weakself getPhotoArray];
//                     }];
//                     [weakself.navigationController pushViewController:preVC animated:YES];
                     
                     NewBiaoTiVC *newBiaoTiVC = [[NewBiaoTiVC alloc]init];
                     newBiaoTiVC.mapPhoneModel = model;
                     if ([model.userID isEqualToString: USERMANAGER.user.userID]) {
                         newBiaoTiVC.enumType = AddType;
                     }else{
                         newBiaoTiVC.enumType = Look;
                     }
                     [weakself.navigationController pushViewController:newBiaoTiVC animated:YES];
                 }];
                 [_phoneAnnotation setDidClickNaviButton:^{
                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您是否要导航到该目的地" message:nil preferredStyle:  UIAlertControllerStyleAlert];
                     [alert addAction:[UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleDefault handler:nil]];
                     [alert addAction:[UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *act){
                         NSLog(@"导航到目的地");
                         TIPmodel *modelTIP = [[TIPmodel alloc]init];
                         modelTIP.latitude = [model.y floatValue];
                         modelTIP.longitude = [model.x floatValue];
                         modelTIP.addressString =  model.address;
                         [[KDXFvoiceManager shareInstance]sendNai:modelTIP];
                     }]];
                     [weakself presentViewController:alert animated:true completion:nil];
                 }];
                 [_phoneAnnotation showInView:[AppData theTopView]];
                 _phoneAnnotation.imageDataArray = _imageArray;
             }else{
                 [UIUtil showToast:@"未有图片" inView:self.view];
             }
         }else{
             [UIUtil showToast:@"加载失败" inView:self.view];
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"网络异常" inView:self.view];
     }];
}
-(void)photoHeadClick:(UIButton*)but{
    NSLog(@"点击图片头像");
    NSInteger tagN = but.tag;
    MapPhoneModel *model = photoDataArray[tagN - 2000];
}
-(void)addAllAnnotation{
//    [__mapView removeAnnotations:__mapView.annotations];
    [_clusterManager clearClusterItems];
    [_clusterCaches removeAllObjects];
    for (MapPhoneModel *photoModel in photoDataArray) {
        BMKClusterItem *clusterItem = [[BMKClusterItem alloc] init];
        clusterItem.coor = CLLocationCoordinate2DMake([photoModel.y floatValue],[photoModel.x floatValue]);
        clusterItem.csqPhoneModel = photoModel;
        [_clusterManager addClusterItem:clusterItem];
        [_clusterCaches addObject:[NSMutableArray array]];
    }
    [self updateClusters];
    [self autoMapView];
}
//适配地图
-(void)autoMapView{
    BMKMapPoint * temppoints = new BMKMapPoint[photoDataArray.count];

    for (int i = 0; i <photoDataArray.count; i++) {
        MapPhoneModel *model = photoDataArray[i];
        CLLocationCoordinate2D coor1;
        coor1.latitude = [model.y floatValue];
        coor1.longitude = [model.x floatValue];
        //        coor1 = [JZLocationConverter BD_bd09ToWgs84:coor1];
        BMKMapPoint pt1 = BMKMapPointForCoordinate(coor1);
        temppoints[i].x = pt1.x;
        temppoints[i].y = pt1.y;
    }
    BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:photoDataArray.count];
    [self mapViewFitPolyLine:polyLine];
}
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];

    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];


        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX - (rbX - ltX)*0.6, ltY - (rbY - ltY)*0.45);
    rect.size = BMKMapSizeMake((rbX - ltX)*2.2, (rbY - ltY)*1.9);
    [__mapView setVisibleMapRect:rect];
    
    //  __mapView.zoomLevel = __mapView.zoomLevel - 2;  //加载这个会有抖动效果 每次结束后都有个收缩情况
}
-(void)getPhotoArray{
    [UIUtil showProgressHUD:@"请稍候..." inView:self.view];
    
    NSString *radiousStr = kStringIsEmpty(_searchBar.text)?[NSString stringWithFormat:@"%.0f",pow(2,(22 - __mapView.zoomLevel))*2.5 * 10 * 1.5]:@"100000";
    
    NSDictionary *dic = @{@"radius":radiousStr,
                          @"x":[NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.longitude],
                          @"y":[NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.latitude],
                          @"title":CsqStringIsEmpty(_searchBar.text)
                          };
    [ZZXDataService HFZLRequest:@"photo/show-group" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             NSArray *photoArray = data[@"data"];
             if (!kArrayIsEmpty(photoArray)) {
                 [UIUtil hideProgressHUD];
                 [photoDataArray removeAllObjects];
                 
                 NSInteger modelCount = 0;
                 for (NSDictionary *photoDict in photoArray) {
                     
                     if ([photoDict[@"x"] floatValue] == 0.0) {
                         continue;
                     }
                     
                     MapPhoneModel *model = [MapPhoneModel provinceWithDictionary:photoDict];
                     model.tagNumber = modelCount;
                     modelCount++;
                     [photoDataArray addObject:model];
                 }
                 [self addAllAnnotation];
             }else{
//                 [UIUtil showToast:@"未找到信息" inView:self.view];
                 [UIUtil hideProgressHUD];
                 [__mapView removeAnnotations:__mapView.annotations];
             }
         }else{
             switch ([data[@"code"]integerValue]) {
                 case 200002:
                 {
                     [UIUtil showToast:@"未绑定设备" inView:self.view];
                 }
                     break;
                 default:
                     [UIUtil showToast:@"获取失败" inView:self.view];
                     break;
             }
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"获取失败" inView:self.view];
     }];
}
-(void)getPhotoArrayNoUiutil{
    NSDictionary *dic = @{@"radius":[NSString stringWithFormat:@"%.0f",pow(2,(22 - __mapView.zoomLevel))*2.5 * 10 *1.5],
                          @"x":[NSString stringWithFormat:@"%f",__mapView.centerCoordinate.longitude],
                          @"y":[NSString stringWithFormat:@"%f",__mapView.centerCoordinate.latitude],
                          @"title":CsqStringIsEmpty(_searchBar.text)
                          };
    [ZZXDataService HFZLRequest:@"photo/show-group" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             NSArray *photoArray = data[@"data"];
             if (!kArrayIsEmpty(photoArray)) {
                 [UIUtil hideProgressHUD];
                 [photoDataArray removeAllObjects];
                 
                 NSInteger modelCount = 0;
                 for (NSDictionary *photoDict in photoArray) {
                     if ([photoDict[@"x"] floatValue] == 0.0) {
                         continue;
                     }
                     
                     MapPhoneModel *model = [MapPhoneModel provinceWithDictionary:photoDict];
                     model.tagNumber = modelCount;
                     modelCount++;
                     [photoDataArray addObject:model];
                 }
                 
                 
                 [_clusterManager clearClusterItems];
                 [_clusterCaches removeAllObjects];
                 for (MapPhoneModel *photoModel in photoDataArray) {
                     BMKClusterItem *clusterItem = [[BMKClusterItem alloc] init];
                     clusterItem.coor = CLLocationCoordinate2DMake([photoModel.y floatValue],[photoModel.x floatValue]);
                     clusterItem.csqPhoneModel = photoModel;
                     [_clusterManager addClusterItem:clusterItem];
                     [_clusterCaches addObject:[NSMutableArray array]];
                 }
                 [self updateClusters];
             }else{
                 [__mapView removeAnnotations:__mapView.annotations];
             }
         }
     } fail:^(NSError *error)
     {
     }];
}
#pragma mark SearchDele
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    Search_Good_VC *searchVC = [Search_Good_VC new];
    searchVC.serchBlock = ^(NSString *searchStr){
        _searchBar.text = searchStr;
        [self getPhotoArray];
    };
    [searchBar resignFirstResponder];
    [self.view  endEditing:YES];
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击搜索");
    [searchBar resignFirstResponder];
    [self.view  endEditing:YES];
    [self getPhotoArray];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (searchBar == _searchBar)
    {
//        NSString *toBeString = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
//
//        BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
//        option.cityname = @""; //搜索城市名
//        option.keyword = toBeString; //搜索关键字
//        NSLog(@"我在这儿toBeString:%@",toBeString);
//        BOOL flag = [_searcher suggestionSearch:option];
//        if(flag)
//        {
//
//        }
//        else
//        {
//            NSLog(@"我在这儿:搜索建议检索发送失败");
//        }
    }
    return YES;
}
#pragma mark --- BMKSuggestionSearchDelegate

- (void)onGetSuggestionResult:(BMKSuggestionSearch *)searcher result:(BMKSuggestionResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR)
    {
        [dataArr removeAllObjects];
        for (int i = 0;  i < result.ptList.count; i++)
        {
            TIPmodel *model = [[TIPmodel alloc] init];
            model.keyString = result.keyList[i];
            model.addressString = [NSString stringWithFormat:@"%@%@",result.cityList[i],result.districtList[i]];
            NSValue *va = result.ptList[i];
            CLLocationCoordinate2D coordinate;
            [va getValue:&coordinate];
            model.latitude = coordinate.latitude;
            model.longitude = coordinate.longitude;
            [dataArr addObject:model];
        }
        NSLog(@"我在这儿:搜索结果个数dataArr.count = %lu",(unsigned long)dataArr.count);
        
        if (dataArr.count > 0)
        {
            _searchTableView.hidden = NO;
            [_searchTableView reloadData];
        }
        else
        {
            _searchTableView.hidden = YES;
            [_searchTableView reloadData];
        }
    }
    else
    {
        [dataArr removeAllObjects];
        _searchTableView.hidden = YES;
    }
}
#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tipCellIdentifier = @"tipCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tipCellIdentifier];
    }
    
    TIPmodel *tip = dataArr[indexPath.row];
    cell.textLabel.text = tip.keyString;
    cell.detailTextLabel.text = tip.addressString;
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 1, cell.contentView.frame.size.width, 1)];
//    label.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
//    [cell.contentView addSubview:label];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TIPmodel *tip = dataArr[indexPath.row];
    _searchBar.text = tip.keyString;
    _searchTableView.hidden = YES;
    [_searchBar resignFirstResponder];
    [self.view  endEditing:YES];
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(tip.latitude, tip.longitude);
    BMKCoordinateRegion userRegion;
    userRegion.center = centerCoordinate;
    userRegion.span.latitudeDelta = 0.01;
    userRegion.span.longitudeDelta = 0.01;
    [__mapView setRegion:userRegion animated:NO];
}

-(void)changeUserInfo{
    NSDictionary *dic = @{@"userId":CsqStringIsEmpty(USERMANAGER.user.userID)
                          
                          };
    
    [ZZXDataService HFZLRequest:@"main/view" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             
             UserManager *userManager = [UserManager sharedInstance];
             userManager.user.isLogined = YES;
             
             NSDictionary *userDict = data[@"data"][@"userInfo"];
             if (!kDictIsEmpty(userDict)) {
                 userManager.user.nickname = GetData(userDict, @"nickName");
                 userManager.user.userID = GetData(userDict, @"id") ;
                 userManager.user.macID = GetData(userDict, @"macId");
                 userManager.user.iconId = GetData(userDict, @"iconId");
                 userManager.user.mobilePhone = GetData(userDict, @"mobilePhone");
                 userManager.user.appCookie = GetData(userDict, @"appCookie");
                 //
                 
                 NSString *str = GetData(userDict, @"headPicPath");
                 if (!kStringIsEmpty(str)) {
                     if ([str hasPrefix:@"http://thirdwx"]) {
                         userManager.user.headPicPath = GetData(userDict, @"headPicPath");
                     }else{
                         userManager.user.upPicPath = GetData(userDict, @"headPicPath");
                     }
                 }
                 
                 
                 
                 userManager.user.mobilePhone = GetData(userDict, @"phone");
             }
             
             NSArray *cardVeiwArr = data[@"data"][@"cardVeiws"];
             if (!kArrayIsEmpty(cardVeiwArr)) {
                 [userManager.AllDeviceArray removeAllObjects];
                 for (NSDictionary *cardDict in cardVeiwArr) {
                     NSLog(@"desc = %@",cardDict[@"desc"]);
                     NSDictionary *cardD;
                     if ([cardDict[@"viewId"] isEqualToString:@"101"]) {
                         NSLog(@"添加101");
                         cardD  = @{TYPE:GT10,orderNum:cardDict[@"orderNum"]};
                         [userManager.AllDeviceArray addObject:cardD];
                     }else if([cardDict[@"viewId"] isEqualToString:@"102"]){
                         NSLog(@"添加102");
                         //                         cardD = @{TYPE:MUSIC,orderNum:cardDict[@"orderNum"]};
                         //                         [userManager.AllDeviceArray addObject:cardD];
                     }else if([cardDict[@"viewId"] isEqualToString:@"103"]){
                         NSLog(@"添加103");
                         cardD = @{TYPE:SUIPAI,orderNum:cardDict[@"orderNum"]};
                         [userManager.AllDeviceArray addObject:cardD];
                     }
                     
                 }
             }
             [[UserManager sharedInstance] save];
             [self changeNavi];
             
         }else{
             //             [UIUtil showToast:@"请重新登录" inView:self.view];
             //             switch ([data[@"code"]integerValue]) {
             //                 case 101016:
             //                 {
             //                     [UIUtil showToast:@"账户密码错误" inView:self.view];
             //                 }
             //                     break;
             //                 case 101017:
             //                 {
             //                     [UIUtil showToast:@"账户未注册" inView:self.view];
             //                 }
             //                     break;
             //                 default:
             //                     [UIUtil showToast:@"登录失败" inView:self.view];
             //                     break;
             //             }
         }
     } fail:^(NSError *error)
     {
         //         [UIUtil showToast:@"网络异常" inView:self.view];
         
     }];
    
    
    
    //    [ZZXDataService HFZLRequest:@"alarm/get-condition" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
    //     {
    //         if ([data[@"code"]integerValue] == 0) {
    //             NSLog(@"condition = %@",data[@"data"]);
    //         }
    //     } fail:^(NSError *error)
    //     {
    //     }];
}
-(void)changeNavi{
    
    BOOL isleft = NO;
    if ([[UserManager sharedInstance].user.iconId integerValue] >= 1 && [[UserManager sharedInstance].user.iconId integerValue] <= 12) {
        [self addNavigationItemWithImageNames
         :@[[NSString stringWithFormat:@"ui2_user_icon%ld.png",(long)[USERMANAGER.user.iconId integerValue]]] isLeft:isleft target:self action:@selector(showLeft) tags:@[@1000]];
    }else if([[UserManager sharedInstance].user.iconId integerValue] == 13 ){
        if (!headImageIsEmpty(USERMANAGER.user.headPicPath) ) {
            [self addNavigationItemWithImageNames
             :@[USERMANAGER.user.headPicPath] isLeft:isleft target:self action:@selector(showLeft) tags:@[@1000]];
        }else{
            [self addNavigationItemWithImageNames
             :@[@"微众世界_头像0"] isLeft:isleft target:self action:@selector(showLeft) tags:@[@1000]];
        }
    }
    else if( [[UserManager sharedInstance].user.iconId integerValue] == 14){
        if (!headImageIsEmpty(USERMANAGER.user.upPicPath) ) {
            [self addNavigationItemWithImageNames
             :@[USERMANAGER.user.upPicPath] isLeft:isleft target:self action:@selector(showLeft) tags:@[@1000]];
        }else{
            [self addNavigationItemWithImageNames
             :@[@"微众世界_头像0"] isLeft:isleft target:self action:@selector(showLeft) tags:@[@1000]];
        }
    }else
    {
        [self addNavigationItemWithImageNames
         :@[@"微众世界_头像0"] isLeft:isleft target:self action:@selector(showLeft) tags:@[@1000]];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    [[SDWebImageManager sharedManager] cancelAll];
    
    
}
@end
