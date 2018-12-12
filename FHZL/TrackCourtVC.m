//
//  TrackCourtVC.m
//  FHZL
//
//  Created by hk on 2018/5/28.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "TrackCourtVC.h"
#import "FHZL-Swift.h"
//#import "TrackPointModel.swift"
#import "Header.h"
//#import "TrackCountCell.swift"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
@interface TrackCourtVC ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong)NSMutableArray *allTrackArray;
@property (nonatomic,strong)NSMutableArray *modelArray;
@end

@implementation TrackCourtVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"轨迹分段";
    [_myTableView registerNib:[UINib nibWithNibName:@"TrackCountCell" bundle:nil] forCellReuseIdentifier:@"TrackCountCell"];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _allTrackArray = [NSMutableArray array];
    _modelArray = [NSMutableArray array];
    if (_trackCourtArray ) {
        
        long long countTime = 0;
        NSMutableArray *firstArray = [NSMutableArray array];
        for (int i = 0; i < _trackCourtArray.count; i++) {
            long long timeInt = [_trackCourtArray[i][@"gpsTime"] longLongValue];
            if ((timeInt - countTime) > 1000 * 60 * 3 && firstArray.count > 5) {
                if (i != 0) {
                    NSArray *trackArray = [firstArray copy];
                    [_allTrackArray addObject:trackArray];
                }
                [firstArray removeAllObjects];
            }
            [firstArray addObject:_trackCourtArray[i]];
            countTime = [_trackCourtArray[i][@"gpsTime"] longLongValue];
            if (i == _trackCourtArray.count - 1) {
                [_allTrackArray addObject:firstArray];
            }
        }
    }
    
    
    for (NSArray *trackArray in _allTrackArray) {
        TrackPointModel *model = [[TrackPointModel alloc]init];
//        [model testFunc];
        if (trackArray.count > 1) {
            CGFloat distacne = 0.;
            for (int i = 0; i < trackArray.count; i++) {
                
                
                if ( i == 0) {
                    
                    model.startTime  = [UserManager getDateDisplayString:[trackArray[i][@"gpsTime"] longLongValue]];
                    NSLog(@"model.startTime = %@",model.startTime);
                    
                    
                }
                if (i == trackArray.count -1) {
                    
                    model.endTime  = [UserManager getDateDisplayString:[trackArray[i][@"gpsTime"] longLongValue]];
                    NSLog(@"model.endTime = %@",model.endTime);
                }
                if (i != 0) {
                    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([trackArray[i][@"y"] floatValue], [trackArray[i][@"x"] floatValue]));
                    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([trackArray[i - 1][@"y"] floatValue], [trackArray[i -1][@"x"] floatValue]));
                    CLLocationDistance dis = BMKMetersBetweenMapPoints(point1,point2);
                    distacne = distacne + dis;
                }
            }
            model.distance = [NSString stringWithFormat:@"%f",distacne];
            
        }else if(trackArray.count == 1){
            model.startTime  = [UserManager getDateDisplayString:[trackArray[0][@"gpsTime"] longLongValue]];
            model.endTime  = [UserManager getDateDisplayString:[trackArray[trackArray.count-1][@"gpsTime"] longLongValue]];
            model.distance = @"0";
        }
        [_modelArray addObject:model];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 81;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"_modelArray.count = %d",_modelArray.count);
    return _modelArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TrackCountCell";
    TrackCountCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TrackPointModel *model = _modelArray[indexPath.row];
    cell.trackPointModel = model;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.cellClick) {
        NSArray * array = _allTrackArray[indexPath.row];
        
        self.cellClick(array);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showLeft{
    
    [self.navigationController popViewControllerAnimated:YES];
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
