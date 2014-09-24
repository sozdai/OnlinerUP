//
//  MyAdTableViewCell.h
//  OnlinerUP
//
//  Created by Alex Kardash on 7/29/14.
//  Copyright (c) 2014 sozdai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAdTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textView;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
@property (weak, nonatomic) IBOutlet UIImageView *sellTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentsCountIcon;
@property (weak, nonatomic) IBOutlet UILabel *adCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountAmountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UIButton *upAllButton;
@property (weak, nonatomic) IBOutlet UIButton *envelopeButton;


@end
