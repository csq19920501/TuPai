//
//  MusicModel.h
//  WeiZhong_ios
//
//  Created by haoke on 17/3/13.
//
//

#import <Foundation/Foundation.h>

@interface MusicModel : NSObject<NSCoding>

@property(nonatomic,copy)NSString *songId;
@property(nonatomic,copy)NSString *songName;
@property(nonatomic,copy)NSString *artist;

@end
