//
//  MusicCell.h
//  WeiZhong_ios
//
//  Created by haoke on 17/3/13.
//
//

#import <UIKit/UIKit.h>

@interface MusicCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIView *upLine;
@property (weak, nonatomic) IBOutlet UIView *downLine;

@end
