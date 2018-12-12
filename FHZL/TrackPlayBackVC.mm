//
//  ViewController.m
//  FHZL
//
//  Created by hk on 17/12/19.
//  Copyright © 2017年 hk. All rights reserved.
//
#import "UIImage+Rotate.h"
#import "TrackPlayBackVC.h"
#import "TrackCourtVC.h"
#import "Header.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#define MYBUNDLE_NAME @ "mapapi.bundle"

@interface RouteAnnotation : BMKPointAnnotation
{
    int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
    int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end


@interface TrackPlayBackVC ()<BMKMapViewDelegate,BMKLocationServiceDelegate,cellClickDele>{
    BMKLocationService* _locService;
    BMKPointAnnotation* pointAnnotation;
    BMKPinAnnotationView *annotationView;
    CLLocationCoordinate2D centerCoordinate;
    CLLocationCoordinate2D _userCoordinate;
    CLLocationCoordinate2D _carCoordinate;
    BOOL isFirst;
    carModel *carStateModel;
    NSMutableArray *carStateArray;
    carModel *CarModelAdding;
    NSTimer *timer;
    
    
    int tipInt;
    int isOneGeo;
    SingelCalendarVIew *calenderView;
    UIView *menuView;
    BOOL isShowCalender;
    RouteAnnotation* carItem;
    NSTimer*  Timer;
    NSArray *railArray;
    NSArray *allRailArray;
    int  step;
    BMKAnnotationView *carView;
    float stepTime;
    int stepQuick;//速度deng
    BOOL isNotMoveCar;
}
@property (weak, nonatomic) IBOutlet UILabel *gsmTimeStr;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UISlider *MusicSlider;
@property (weak, nonatomic) IBOutlet BMKMapView *_mapView;
//@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *slowButton;
@property (weak, nonatomic) IBOutlet UILabel *slowLabel;

@property (nonatomic, strong)NSString *starTime;
@property (nonatomic, strong)NSString *endTime;
@end

@implementation TrackPlayBackVC


- (IBAction)touchDown:(id)sender {
    if (isNotMoveCar) {
        [Timer setFireDate:[NSDate distantFuture]];
    }
    
}
- (IBAction)touchCancel:(id)sender {
    if (isNotMoveCar) {
        [Timer setFireDate:[NSDate date]];
    }
}
- (IBAction)touch_Up_inside:(id)sender {
    if (!kArrayIsEmpty(railArray)) {
        UISlider *sli = sender;
        int count = railArray.count - 2;
        step = (int)count * (sli.value);
    }
    if (isNotMoveCar) {
        [Timer setFireDate:[NSDate date]];
    }
    
    NSDictionary *railDict1 = railArray[step];
    NSDictionary *railDict2 = railArray[step+1];
    CGFloat ja,tgAAA;
    CGFloat wa,jb,wb;
    ja =  [railDict1[@"x"] floatValue];
    wa = [railDict1[@"y"] floatValue];
    jb = [railDict2[@"x"] floatValue];
    wb = [railDict2[@"y"] floatValue];
    tgAAA = [self GetJiaoDu:wa :ja :wb :jb];
    tgAAA = 90. - tgAAA + 360;

    NSDictionary *railDict = railArray[step];
    CLLocationCoordinate2D coor1;
    coor1.latitude = [railDict[@"y"] floatValue];
    coor1.longitude = [railDict[@"x"] floatValue];
    coor1 = [JZLocationConverter BD_bd09ToWgs84:coor1];
    
    
    if([_carModel.ico intValue] <0 || [_carModel.ico intValue] >9){
        _carModel.ico = @"0";
    }
    NSString *str = [NSString stringWithFormat:@"mycar_top_%d_%@",[_carModel.ico intValue],[_carModel.online intValue] == 0?@"p":@"n"];
    UIImage *changeImage = [UIImage imageNamed:str];
    carView.image = [changeImage imageRotatedByDegrees:tgAAA];
    
    carItem.coordinate = coor1;

}
- (IBAction)touch_up_outside:(id)sender {
    if (!kArrayIsEmpty(railArray)) {
        int count = (int)railArray.count - 1;
        step = count - 1; //倒数第二个
    }
    if (isNotMoveCar) {
        [Timer setFireDate:[NSDate date]];
    }
    
    NSDictionary *railDict1 = railArray[step];
    NSDictionary *railDict2 = railArray[step+1];
    CGFloat ja,tgAAA;
    CGFloat wa,jb,wb;
    ja =  [railDict1[@"x"] floatValue];
    wa = [railDict1[@"y"] floatValue];
    jb = [railDict2[@"x"] floatValue];
    wb = [railDict2[@"y"] floatValue];
    tgAAA = [self GetJiaoDu:wa :ja :wb :jb];
    tgAAA = 90. - tgAAA + 360;
//    carView.transform = CGAffineTransformMakeRotation(tgAAA * M_PI / 180.f);
    NSDictionary *railDict = railArray[step];
    CLLocationCoordinate2D coor1;
    coor1.latitude = [railDict[@"y"] floatValue];
    coor1.longitude = [railDict[@"x"] floatValue];
    coor1 = [JZLocationConverter BD_bd09ToWgs84:coor1];
    
    
    if([_carModel.ico intValue] <0 || [_carModel.ico intValue] >9){
        _carModel.ico = @"0";
    }
    NSString *str = [NSString stringWithFormat:@"mycar_top_%d_%@",[_carModel.ico intValue],[_carModel.online intValue] == 0?@"p":@"n"];
    UIImage *changeImage = [UIImage imageNamed:str];
    carView.image = [changeImage imageRotatedByDegrees:tgAAA];
    
    carItem.coordinate = coor1;
  
}




- (IBAction)pauseButton:(id)sender {
    if (railArray.count < 2) {
        return;
    }
    if (!_pauseButton.selected) {
        if (!Timer) {
            [self  moveCar];
            Timer = [NSTimer scheduledTimerWithTimeInterval:stepTime
                                                     target:self
                                                   selector:@selector(moveCar)
                                                   userInfo:nil
                                                    repeats:YES];
        }else{
            [Timer setFireDate:[NSDate distantPast]];
        }
        //        statusView.hidden = NO;
        isNotMoveCar = NO;
    }else{
        [Timer setFireDate:[NSDate distantFuture]];
        //        statusView.hidden = YES;
        isNotMoveCar = YES;
    }
    _pauseButton.selected = !_pauseButton.selected;
}
- (IBAction)slowButton:(id)sender {
    switch (stepQuick) {
        case 1:{
            stepQuick = 2;
            stepTime = 2;
//            [_slowButton setTitle:@"x2" forState:UIControlStateNormal];
            _slowLabel.text = @"x2";
        }
            
            break;
        case 2:
            stepQuick = 3;
            _slowLabel.text = @"x3";
            stepTime = 1;
            break;
        case 3:
            stepQuick = 4;
            _slowLabel.text = @"x4";
            stepTime = 0.6;
            break;
        case 4:
            stepQuick = 5;
            _slowLabel.text = @"x5";
            stepTime = 0.3;
            break;
        case 5:
            stepQuick = 6;
            _slowLabel.text = @"x6";
            stepTime = 0.1;
            break;
        case 6:
            stepQuick = 1;
            _slowLabel.text = @"x1";
            stepTime = 3;
            break;
        default:
            break;
    }
    
    
    //    stepTime = _slowButton.selected?3.:1;
    if (_pauseButton.selected) {
        [Timer invalidate];
        Timer  = nil;
        Timer = [NSTimer scheduledTimerWithTimeInterval:stepTime
                                                 target:self
                                               selector:@selector(moveCar)
                                               userInfo:nil
                                                repeats:YES];
    }else{
        [Timer invalidate];
        Timer  = nil;
        Timer = [NSTimer scheduledTimerWithTimeInterval:stepTime
                                                 target:self
                                               selector:@selector(moveCar)
                                               userInfo:nil
                                                repeats:YES];
        [Timer setFireDate:[NSDate distantFuture]];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self  setNavi];
    [self setMap];
    _slowLabel.text = @"x1";
    
    carStateModel = [[carModel alloc]init];
    isFirst = YES;
    __mapView.showsUserLocation = NO;//显示定位图层
    
//    [_locService startUserLocationService];
//    _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
//    _geoCodeSearch.delegate = self;
    [self.MusicSlider setThumbImage:[UIImage imageNamed:@"底部音乐显示底盘_进度条滑块"] forState:UIControlStateNormal];
    
    isShowCalender = NO;
    stepTime = 3.;
    stepQuick  = 1;
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
    NSString *selectStr = [dateFormatter2 stringFromDate:[NSDate date]];
    [self getRouteStart:selectStr endTime:selectStr];
}
-(void)getRouteStart:(NSString *)startTime endTime:(NSString *)endTime{
    
    if (_pauseButton.selected) {
        [Timer setFireDate:[NSDate distantFuture]];
        isNotMoveCar = YES;
        _pauseButton.selected = !_pauseButton.selected;
    }
    _MusicSlider.value = 0;
    [UIUtil showProgressHUD:@"请稍候..." inView:self.view];
    
    startTime = [NSString stringWithFormat:@"%@ 00:00:01",startTime] ;
    endTime = [NSString stringWithFormat:@"%@ 23:59:59",endTime];
    NSLog(@"startTIme = %@ endTime= %@",startTime,endTime);
    
    
    NSDictionary *dic = @{@"userId":CsqStringIsEmpty(USERMANAGER.user.userID),
                          @"macId":CsqStringIsEmpty(_carModel.macId),
                          @"start":[NSString stringWithFormat:@"%lld",[UserManager getTimerInterval:startTime]],
                          @"end":[NSString stringWithFormat:@"%lld",[UserManager getTimerInterval:endTime]]
                          };
    
    step = 0;
    railArray = nil;
    allRailArray = nil;
    NSArray* array = [NSArray arrayWithArray:__mapView.annotations];
    [__mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:__mapView.overlays];
    [__mapView removeOverlays:array];
    carView = nil;
    [__mapView removeAnnotation:carItem];
    carItem = nil;

    _speedLabel.text = @"";
    _gsmTimeStr.text = @"";
    
    [ZZXDataService HFZLRequest:@"track/history-tracks" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             [UIUtil hideProgressHUD];
             
             railArray = data[@"data"];
             allRailArray = railArray;
             BMKMapPoint * temppoints = new BMKMapPoint[railArray.count];
             for (int i = 0; i < railArray.count; i++) {
                 NSDictionary *railDict = railArray[i];
                 CLLocationCoordinate2D coor1;
                 coor1.latitude = [railDict[@"y"] floatValue];
                 coor1.longitude = [railDict[@"x"] floatValue];
                 coor1 = [JZLocationConverter BD_bd09ToWgs84:coor1];
                 
                 BMKMapPoint pt1 = BMKMapPointForCoordinate(coor1);
                 temppoints[i].x = pt1.x;
                 temppoints[i].y = pt1.y;
                 
                 if (i == 0) {
                     RouteAnnotation* item = [[RouteAnnotation alloc]init];
                     item.coordinate = coor1;
                     item.title = @"起点";
                     item.type = 0;
                     [__mapView addAnnotation:item]; // 添加起点标注
                     NSDictionary *railDict = railArray[0];
                     _speedLabel.text = [NSString stringWithFormat:@"%@km/h",railDict[@"speed"]];
                     _gsmTimeStr.text = [UserManager getDateDisplayString:[railDict[@"gpsTime"] longLongValue]];
                 }
                 if (i == railArray.count - 1  && railArray.count >= 2) {
                     RouteAnnotation* item = [[RouteAnnotation alloc]init];
                     item.coordinate = coor1;
                     item.title = @"终点";
                     item.type = 1;
                     [__mapView addAnnotation:item]; // 添加起点标注
                 }
                 if (i == 0) {
                     carItem = [[RouteAnnotation alloc]init];
                     carItem.coordinate = coor1;
                     carItem.type = 2;
                     [__mapView addAnnotation:carItem]; // 添加车标注
                 }
             }
             BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:railArray.count];
             [__mapView addOverlay:polyLine]; // 添加路线overlay
             delete []temppoints;
             [self mapViewFitPolyLine:polyLine];
         }else{
             [UIUtil showToast:data[@"msg"] inView:self.view];
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"网络异常" inView:self.view];
     }];
}

-(void)moveCar{
    isNotMoveCar = NO;
    NSDictionary *railDict1 = railArray[step];
    NSDictionary *railDict2 = railArray[step+1];
    CGFloat ja,tgAAA;
    CGFloat wa,jb,wb;
    
    ja =  [railDict1[@"x"] floatValue];
    wa = [railDict1[@"y"] floatValue];
    jb = [railDict2[@"x"] floatValue];
    wb = [railDict2[@"y"] floatValue];
    tgAAA = [self GetJiaoDu:wa :ja :wb :jb];
    tgAAA = 90. - tgAAA + 360;
    
    step++;
    NSDictionary *railDict = railArray[step];
    CLLocationCoordinate2D coor1;
    coor1.latitude = [railDict[@"y"] floatValue];
    coor1.longitude = [railDict[@"x"] floatValue];
    coor1 = [JZLocationConverter BD_bd09ToWgs84:coor1];
    
    _speedLabel.text = [NSString stringWithFormat:@"%@km/h",railDict[@"speed"]];
    _gsmTimeStr.text = [UserManager getDateDisplayString:[railDict[@"gpsTime"] longLongValue]];
    
    if([_carModel.ico intValue] <0 || [_carModel.ico intValue] >9){
        _carModel.ico = @"0";
    }
    NSString *str = [NSString stringWithFormat:@"mycar_top_%d_%@",[_carModel.ico intValue],[_carModel.online intValue] == 0?@"p":@"n"];
    UIImage *changeImage = [UIImage imageNamed:str];
    carView.image = [changeImage imageRotatedByDegrees:tgAAA];
   
    
    [UIView animateWithDuration:stepTime animations:
     ^(void){
         [carItem setCoordinate:coor1];
     } completion:nil];
    
    if (step == railArray.count -1) {
        [Timer invalidate];
        Timer = nil;
        step = 0;
        _pauseButton.selected = NO;
        //        statusView.hidden = YES;
        isNotMoveCar = YES;
    }
    _MusicSlider.value = (float)step/railArray.count;
}

-(CGFloat)GetJiaoDu:(CGFloat)lat1 :(CGFloat)lng1 :(CGFloat)lat2 :(CGFloat)lng2 {
    CGFloat x1 = lng1;
    CGFloat y1 = lat1;
    CGFloat x2 = lng2;
    CGFloat y2 = lat2;
    CGFloat pi = M_PI;
    CGFloat w1 = y1 / 180. * pi;
    CGFloat j1 = x1 / 180. * pi;
    CGFloat w2 = y2 / 180. * pi;
    CGFloat j2 = x2 / 180. * pi;
    CGFloat ret;
    
    ret = 4 * pow(sin((w1 - w2) / 2), 2) - pow(sin((j1 - j2) / 2) * (cos(w1) - cos(w2)), 2);
    ret = sqrt(ret);
    CGFloat temp = (sin(fabs(j1 - j2) / 2) * (cos(w1) + cos(w2)));
    ret = ret / temp;
    ret = atan(ret) / pi * 180;
    if (j1 > j2) // 1为参考点坐标
    {
        if (w1 > w2) ret += 180;
        else ret = 180 - ret;
    }
    else if (w1 > w2) ret = 360 - ret;
    return ret;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [__mapView viewWillAppear];
//    __mapView.delegate = self;  //同willDisappear
    
//    _locService.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [__mapView viewWillDisappear];
//    __mapView.delegate = nil;  //考虑到后面的视图没有地图这里的操作可以移到showLeft那里
    
    
//    [_locService stopUserLocationService];
//    _locService.delegate = nil;
}
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    [__mapView updateLocationData:userLocation];
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [__mapView updateLocationData:userLocation];
    
    _userCoordinate = CLLocationCoordinate2DMake( userLocation.location.coordinate.latitude,
                                                 userLocation.location.coordinate.longitude);
    if (isFirst) {
        isFirst = NO;
        BMKCoordinateRegion userRegion ;
        userRegion.center = _userCoordinate;
        userRegion.span.latitudeDelta = 0.01;
        userRegion.span.longitudeDelta = 0.01;
        [__mapView setRegion:userRegion animated:NO];
    }
}

-(void)setMap{
    __mapView.zoomLevel = 16.1;
    __mapView.delegate = self;
    BMKLocationViewDisplayParam *param = [[BMKLocationViewDisplayParam alloc] init];
    param.isRotateAngleValid = true;
    param.isAccuracyCircleShow = NO;
    param.locationViewImgName = @"bnavi_icon_location_fixed@2x";
    param.locationViewOffsetX = 0;
    param.locationViewOffsetY = 0;
    [__mapView updateLocationViewWithParam:param];
    
//    _locService = [[BMKLocationService alloc]init];
//    _locService.delegate = self;
//    [_locService setPausesLocationUpdatesAutomatically:NO];
//    [_locService setAllowsBackgroundLocationUpdates:YES];
}

-(void)setNavi{
    self.title = @"轨迹回放";
    self.view.backgroundColor = HBackColor;
    [self addNavigationItemWithImageNames
     :@[@"轨迹回放_标题栏_日期_N.png",@"列表_6_N.png"] isLeft:NO target:self action:@selector(showRight:) tags:@[@1000,@1001]];
}
-(void)showLeft{
    //    [self dismissViewControllerAnimated:NO completion:nil];
    [Timer invalidate];
    Timer  = nil;
    [__mapView viewWillDisappear];
    __mapView.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)showRight:(UIButton *)but{
    if (but.tag == 1001) {
        TrackCourtVC *VC = [[TrackCourtVC alloc]init];
        VC.trackCourtArray = allRailArray;
        [VC setCellClick:^(NSArray *railArrayBack){
            if (_pauseButton.selected) {
                [Timer setFireDate:[NSDate distantFuture]];
                isNotMoveCar = YES;
                _pauseButton.selected = !_pauseButton.selected;
            }
            _MusicSlider.value = 0;
            
            [Timer invalidate];
            Timer  = nil;
            
            step = 0;
            railArray = nil;
          
            NSArray* array = [NSArray arrayWithArray:__mapView.annotations];
            [__mapView removeAnnotations:array];
            array = [NSArray arrayWithArray:__mapView.overlays];
            [__mapView removeOverlays:array];
            carView = nil;
            [__mapView removeAnnotation:carItem];
            carItem = nil;
            
            _speedLabel.text = @"";
            _gsmTimeStr.text = @"";
            railArray = railArrayBack;
            BMKMapPoint * temppoints = new BMKMapPoint[railArray.count];
            for (int i = 0; i < railArray.count; i++) {
                NSDictionary *railDict = railArray[i];
                CLLocationCoordinate2D coor1;
                coor1.latitude = [railDict[@"y"] floatValue];
                coor1.longitude = [railDict[@"x"] floatValue];
                coor1 = [JZLocationConverter BD_bd09ToWgs84:coor1];
                
                BMKMapPoint pt1 = BMKMapPointForCoordinate(coor1);
                temppoints[i].x = pt1.x;
                temppoints[i].y = pt1.y;
                
                if (i == 0) {
                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
                    item.coordinate = coor1;
                    item.title = @"起点";
                    item.type = 0;
                    [__mapView addAnnotation:item]; // 添加起点标注
                    NSDictionary *railDict = railArray[0];
                    _speedLabel.text = [NSString stringWithFormat:@"%@km/h",railDict[@"speed"]];
                    _gsmTimeStr.text = [UserManager getDateDisplayString:[railDict[@"gpsTime"] longLongValue]];
                }
                if (i == railArray.count - 1  && railArray.count >= 2) {
                    RouteAnnotation* item = [[RouteAnnotation alloc]init];
                    item.coordinate = coor1;
                    item.title = @"终点";
                    item.type = 1;
                    [__mapView addAnnotation:item]; // 添加起点标注
                }
                if (i == 0) {
                    carItem = [[RouteAnnotation alloc]init];
                    carItem.coordinate = coor1;
                    carItem.type = 2;
                    [__mapView addAnnotation:carItem]; // 添加车标注
                }
            }
            BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:railArray.count];
            [__mapView addOverlay:polyLine]; // 添加路线overlay
            delete []temppoints;
            [self mapViewFitPolyLine:polyLine];
        }];
        
        [self.navigationController pushViewController:VC animated:YES];
    }
    else{
    
    if (!calenderView) {
        calenderView = [[SingelCalendarVIew alloc]initWithFrame:CGRectMake(0, -280, self.view.frame.size.width, 280)];
        calenderView.buttonDele = self;
        [self.view addSubview:calenderView];
        [UIView animateWithDuration:0.2 animations:
         ^(void){
             calenderView.frame = CGRectMake(0, kTopHeight, self.view.frame.size.width, 280);
         } completion:nil];
        isShowCalender = YES;
    }else{
        if (isShowCalender) {
            [UIView animateWithDuration:0.2 animations:
             ^(void){
                 calenderView.frame = CGRectMake(0, -280, self.view.frame.size.width, 280);
             } completion:nil];
            isShowCalender = NO;
        }else{
            [UIView animateWithDuration:0.2 animations:
             ^(void){
                 calenderView.frame = CGRectMake(0, kTopHeight, self.view.frame.size.width, 280);
             } completion:nil];
            isShowCalender = YES;
        }
    }
    }
}
-(void)collectionCellClick:(NSDate*)date{
    NSLog(@"点击日期");
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    but.tag = 1000;
    [self showRight:but];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"yyyy-MM-dd"];
    NSString *selectStr = [dateFormatter2 stringFromDate:date];
    [self getRouteStart:selectStr endTime:selectStr];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 1.5;
        return polylineView;
    }
    return nil;
}
#pragma mark - 私有

- (NSString*)getMyBundlePath1:(NSString *)filename
{
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}

- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
            return view;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
            return view;
        }
            break;
        case 2:
        {
            carView = [mapview dequeueReusableAnnotationViewWithIdentifier:@"Car_node"];
            if (carView == nil) {
                carView = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"Car_node"];//bus_node
                
//                carView.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction@2x.png"]];
                
                if([_carModel.ico intValue] <0 || [_carModel.ico intValue] >9){
                    _carModel.ico = @"0";
                }
                NSString *str = [NSString stringWithFormat:@"mycar_top_%d_%@",[_carModel.ico intValue],[_carModel.online intValue] == 0?@"p":@"n"];
                carView.image = [UIImage imageNamed:str];
//                carView.centerOffset = CGPointMake(0, -(carView.frame.size.height * 0.5));
               
                carView.canShowCallout = TRUE;
            }
            carView.annotation = routeAnnotation;
            return carView;
        }
            break;
            
        default:
            break;
    }
    return nil;
}

//根据polyline设置地图范围
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
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [__mapView setVisibleMapRect:rect];
    __mapView.zoomLevel = __mapView.zoomLevel - 0.3;
}

- (void)dealloc {
    if (__mapView) {
        __mapView = nil;
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

@end
