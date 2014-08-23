//
//  MyAdTableViewCell.m
//  OnlinerUP
//
//  Created by Alex Kardash on 7/29/14.
//  Copyright (c) 2014 sozdai. All rights reserved.
//

#import "MyAdTableViewCell.h"

@implementation MyAdTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{

    
}


-(void)tapDetected{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)envelopeButtonClick:(UIButton *)sender {
}
@end
