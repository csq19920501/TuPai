//
//  AlarmListCell.m
//  FHZL
//
//  Created by hk on 17/12/21.
//  Copyright © 2017年 hk. All rights reserved.
//

#import "AlarmListCell.h"
#import "UserManager.h"
#import "Header.h"
@implementation AlarmListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _deviceNameLabel.layer.cornerRadius = 4;
    _deviceNameLabel.layer.masksToBounds = YES;
}
-(void)setAlarmModel:(alarmModel *)AlarmModel{
    _AlarmModel = AlarmModel;
    _alarmImage.image = [UIImage imageNamed:@"警报信息_内容区_警报_N.png"];
    _alarmIMEILabel.text = [NSString stringWithFormat:@"IMEI:%@",AlarmModel.macId];
    
    _deviceNameLabel.text = AlarmModel.macName;
    CGRect frame = [AlarmModel.macName boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    
    if (!kStringIsEmpty(_deviceNameLabel.text)) {
        self.nameLabelWidth.constant = (frame.size.width + 10) <= 110 ?frame.size.width + 10:110;
    }
    
    _timeLabel.text = [UserManager getDateDisplayString:[AlarmModel.alarmDate longLongValue]];
    
    NSArray *nameArray = @[@"低电量警报",@"acc打开警报",@"acc关闭警报",@"外接电源线断开警报",@"车门打开警报",@"车辆行驶超速警报",@"SOS警报",@"进入GPS盲区警报",@"汽车震动警报",@"汽车移动警报",@"驶出GPS盲区警报",@"设备摘除警报",@"电子围栏驶出警报",@"电子围栏进入警报"];
    switch ([AlarmModel.alarmType integerValue]) {
        case 101:
        {
            _alrmType.text = nameArray[0];
        }
            break;
        case 102:
        {
            _alrmType.text = nameArray[1];
        }
            break;
        case 103:
        {
            _alrmType.text = nameArray[2];
        }
            break;
        case 104:
        {
            _alrmType.text = nameArray[3];
        }
            break;
        case 105:
        {
            _alrmType.text = nameArray[4];
        }
            break;
        case 106:
        {
            _alrmType.text = nameArray[5];
        }
            break;
        case 107:
        {
            _alrmType.text = nameArray[6];
        }
            break;
        case 108:
        {
            _alrmType.text = nameArray[7];
        }
            break;
        case 109:
        {
            _alrmType.text = nameArray[8];
        }
            break;
        case 110:
        {
            _alrmType.text = nameArray[9];
        }
            break;
        case 111:
        {
            _alrmType.text = nameArray[10];
        }
            break;
        case 112:
        {
            _alrmType.text = nameArray[11];
        }
            break;
        case 200:
        {
            _alrmType.text = nameArray[12];
        }
            break;
        case 201:
        {
            _alrmType.text = nameArray[13];
        }
            break;
            
        default:{
            _alrmType.text = @"未知类型警报";
        }
            break;
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
