//
//  MusicModel.m
//  WeiZhong_ios
//
//  Created by haoke on 17/3/13.
//
//

#import "MusicModel.h"

@implementation MusicModel
- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init])
    {
        self.songId       = [aDecoder decodeObjectForKey:@"songId"];
        self.songName       = [aDecoder decodeObjectForKey:@"songName"];
        self.artist       = [aDecoder decodeObjectForKey:@"artist"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.songId forKey:@"songId"];
    [aCoder encodeObject:self.songName forKey:@"songName"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
}

@end
