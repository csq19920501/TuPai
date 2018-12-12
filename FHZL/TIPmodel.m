//
//  TIPmodel.m
//  WeiZhong_ios
//
//  Created by hk on 16/9/13.
//
//

#import "TIPmodel.h"
#import "ChineseToPinyin.h"
@implementation TIPmodel
-(void)setKeyString:(NSString *)keyString{
    _keyString = keyString;
    _twoCharStr = [ChineseToPinyin csqpinyinFromChinese:keyString];
}
@end
