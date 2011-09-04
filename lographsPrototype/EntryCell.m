//
//  EntryCell.m
//  lographsPrototype
//
//  Created by プー坊 on 11/09/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryCell.h"


@implementation EntryCell

@synthesize titleLabel;
@synthesize dateLabel;
@synthesize amountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [titleLabel release];
    [dateLabel release];
    [amountLabel release];
    [super dealloc];
}

@end
