//
//  EntryCell.h
//  lographsPrototype
//
//  Created by プー坊 on 11/09/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EntryCell : UITableViewCell {
    
    UILabel *titleLabel;
    UILabel *dateLabel;
    UILabel *amountLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *amountLabel;

@end
