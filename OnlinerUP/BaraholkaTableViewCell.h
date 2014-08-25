//
//  BaraholkaTableViewCell.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/23/14.
//
//

#import <UIKit/UIKit.h>

@interface BaraholkaTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sellTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *torgLabel;


@end
