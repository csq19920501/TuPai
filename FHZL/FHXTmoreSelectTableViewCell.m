//
//  FHXTmoreSelectTableViewCell.m
//  WeiZhong_ios
//
//  Created by hk on 16/7/18.
//
//

#import "FHXTmoreSelectTableViewCell.h"
#import "Header.h"

@implementation FHXTmoreSelectTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self createSubView];
    }
    return self;
}

-(void)createSubView
{
    CGFloat width = SCREENWIDTH;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, width - 40, 40)];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.nameLabel];
    
    UILabel *henxianLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, width, 1)];
    henxianLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    [self.contentView addSubview:henxianLabel];
    
    self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 41, width - 40, 40)];
    self.addressLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.addressLabel];
    
    UILabel *bottonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 89, width, 1)];
    bottonLabel.backgroundColor = [UIColor colorWithRed:240 / 255. green:240 / 255. blue:240 / 255. alpha:1];
    [self.contentView addSubview:bottonLabel];
    
//    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.selectButton.frame = CGRectMake(0, 0, width, 81);
//    self.selectButton.backgroundColor = [UIColor clearColor];
//    [self.selectButton addTarget:self action:@selector(getout) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:self.selectButton];
}

-(void)getout
{
    if (!self.buttonView)
    {
        self.buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, self.contentView.height)];
        self.buttonView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_buttonView];
    }
    else
    {
        _buttonView.hidden = NO;
        [self.contentView bringSubviewToFront:_buttonView];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
