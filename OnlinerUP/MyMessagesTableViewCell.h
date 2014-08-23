//
//  MyMessagesTableViewCell.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/21/14.
//
//

#import <UIKit/UIKit.h>

@interface MyMessagesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *envelopeImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *authorButton;
@property (weak, nonatomic) IBOutlet UILabel *subjectTextField;

@end
