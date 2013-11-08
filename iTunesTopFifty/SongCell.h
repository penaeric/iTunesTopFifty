//
//  SongCell.h
//  iTunesTopFifty
//
//  Created by Eric Pena on 11/7/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

@interface SongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
