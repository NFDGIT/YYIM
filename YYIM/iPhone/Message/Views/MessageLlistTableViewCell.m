//
//  MessageLlistTableViewCell.m
//  YYIM
//
//  Created by Jobs on 2018/7/10.
//  Copyright © 2018年 Jobs. All rights reserved.
//

#import "MessageLlistTableViewCell.h"
#import "PersonManager.h"
#import "UIImage+Helper.h"
#import "PersonManager.h"


@interface MessageLlistTableViewCell()
@property (nonatomic,strong)UIImageView * imgView;
@property (nonatomic,strong)UILabel *     labelName;
@property (nonatomic,strong)UILabel *     labelSignature;

@property (nonatomic,strong)UILabel *     labelCount;

@end
@implementation MessageLlistTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}
-(void)initUI{
    _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
    _imgView.layer.cornerRadius = _imgView.width/2;
    [self.contentView addSubview:_imgView];
    
    
    
    _labelName = [[UILabel alloc]initWithFrame:CGRectMake(_imgView.right + 10, _imgView.top, self.width - _imgView.right - 20, 20)];
    _labelName.font = FontBig;
    _labelName.textColor = ColorBlack;
    [self.contentView addSubview:_labelName];

    
    _labelSignature = [[UILabel alloc]initWithFrame:CGRectMake(_imgView.right + 10, _labelName.bottom + 10, self.width - _imgView.right - 20, 20)];
    _labelSignature.font = FontBig;
    _labelSignature.textColor = ColorBlack;
    [self.contentView addSubview:_labelSignature];

    
    _labelCount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    _labelCount.font = FontNormal;
    _labelCount.textColor = [UIColor whiteColor];
    _labelCount.backgroundColor = ColorRed;
    _labelCount.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_labelCount];
    
   
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self layout];
}
-(void)layout{
    _imgView.left = _imgView.top = 10;
    
    _labelName.left = _imgView.right + 10;
    _labelName.top = _imgView.top;
    
    _labelSignature.left = _labelName.left;
    _labelSignature.top = _labelName.bottom + 10;
    
    
    {
        [_labelCount sizeToFit];
        if (_labelCount.width < 25) {
            _labelCount.width = 25;
        }
        if ( _labelCount.height < 25) {
            _labelCount.height = 25;
        }
        
        _labelCount.layer.cornerRadius = _labelCount.height/2;
        _labelCount.layer.masksToBounds = YES;
        
        _labelCount.right = self.width - 20;
        _labelCount.centerY =_imgView.centerY;
        
        _labelCount.hidden = _model.newCount == 0;
    }

    
    

}
-(void)setModel:(ConversationModel *)model{
    _model = model;
    
    
    _labelName.text = _model.name;
    _labelSignature.text = _model.Id;
    
    if (_model.GroupMsg) {
        _imgView.image = [UIImage imageNamed:@"群组_default"];
    }else{
    
        
        UserInfoModel * userInfoModel =  [[PersonManager share]getModelWithId:_model.Id];
        _labelName.text = [NSString stringWithFormat:@"%@",userInfoModel.RealName];
        _labelSignature.text = [NSString stringWithFormat:@"%@",userInfoModel.UnderWrite];
        
        
        _imgView.image = [UIImage imageNamed:@"touxiang_default"];
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"LocalHeadIcon.bundle/%@.jpg",userInfoModel.HeadName]];
        if (image) {
            _imgView.image = image;
        }
        if (![[NSString stringWithFormat:@"%@",userInfoModel.UserStatus] isEqualToString:@"1"]) {
            _imgView.image = [UIImage changeGrayImage:_imgView.image];
        }
        
    }

    _labelCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)_model.newCount];

    
    
    [self layoutSubviews];
    self.ph_Height = _imgView.bottom + 10;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
