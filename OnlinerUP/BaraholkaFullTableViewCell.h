//
//  BaraholkaFullTableViewCell.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/31/14.
//
//

#import <UIKit/UIKit.h>

@interface BaraholkaFullTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sellTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *torgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *baraholkaImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commentsImage;

@end
