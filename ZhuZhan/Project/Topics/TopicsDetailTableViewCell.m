//
//  TopicsDetailTableViewCell.m
//  ZhuZhan
//
//  Created by 汪洋 on 14-8-27.
//
//

#import "TopicsDetailTableViewCell.h"

@implementation TopicsDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(TopicsModel *)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBCOLOR(239, 237, 237);
        [self addContent:model];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)addContent:(TopicsModel *)model{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 358)];
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 358)];
    [bgImage setBackgroundColor:[UIColor whiteColor]];
    [bgView addSubview:bgImage];
    [self.contentView addSubview:bgView];
    
    headImageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"首页_16"]];
    [headImageView setFrame:CGRectMake(0, 0, 320, 202)];
    headImageView.imageURL = [NSURL URLWithString:model.a_image];
    [bgView addSubview:headImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 212, 320, 30)];
    titleLabel.text = model.a_title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:titleLabel];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 245, 260, 1)];
    [lineImage setBackgroundColor:[UIColor grayColor]];
    [bgView addSubview:lineImage];
    
    contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 253, 288, 80)];
    contentLabel.numberOfLines = 5;
    contentLabel.text = model.a_content;
    contentLabel.font = [UIFont systemFontOfSize:13];
    [bgView addSubview:contentLabel];
}
@end