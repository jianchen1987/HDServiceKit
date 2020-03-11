//
//  H5DescTableViewCell.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/11.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "H5DescTableViewCell.h"

@interface H5DescTableViewCell ()

@end

@implementation H5DescTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.detailTextLabel.numberOfLines = -1;
        self.detailTextLabel.font = [UIFont systemFontOfSize:16];
        self.textLabel.numberOfLines = -1;
        self.textLabel.font = [UIFont systemFontOfSize:22];
        self.textLabel.textColor = [UIColor blueColor];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title desc:(NSString *)desc {

    self.textLabel.text = title;
    self.detailTextLabel.text = desc;
}

@end
