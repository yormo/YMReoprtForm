//
//  ZXReasonTableViewCell.m
//  LiveBroadcast
//
//  Created by 含包阁 on 2019/11/10.
//  Copyright © 2019 com.zx.hbg. All rights reserved.
//

#import "ZXReasonTableViewCell.h"
#import "Masonry.h"


@interface ZXReasonTableViewCell ()
@property (strong, nonatomic) UIImageView *selectImage;

@end

@implementation ZXReasonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.font = [UIFont systemFontOfSize:13.f];
            _nameLabel.textColor = [UIColor colorWithRed:34 / 255.0 green:34 / 255.0 blue:34 / 255.0 alpha:1.0];
            [self.contentView addSubview:_nameLabel];
            [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(10);
                make.size.mas_equalTo(CGSizeMake(100, 19));
                make.centerY.mas_equalTo(self.contentView);
            }];
        }

        if (!_selectImage) {
            _selectImage = [[UIImageView alloc] init];
            _selectImage.image = [UIImage imageNamed:@"select_cell_nil"];
            [self.contentView addSubview:_selectImage];
            [_selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(18.5f, 18.5f));
                make.right.mas_equalTo(0);
                make.centerY.mas_equalTo(self.contentView);
            }];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.selectImage.image = [UIImage imageNamed:@"select_cell"];
    } else {
        self.selectImage.image = [UIImage imageNamed:@"select_cell_nil"];
    }
}

@end
