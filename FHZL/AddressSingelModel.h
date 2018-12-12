//
//  AddressSingelModel.h
//  FHZL
//
//  Created by hk on 2018/2/1.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface AddressSingelModel : NSObject
@property(nonatomic,copy)NSString *addressName;
@property(nonatomic,copy)NSString *addressDetailName;
@property(nonatomic,assign)BOOL isSelect;
@property(nonatomic,assign)CLLocationCoordinate2D modelCoordinate;
@end
