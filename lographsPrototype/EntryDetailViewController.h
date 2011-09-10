//
//  EntryDetailViewController.h
//  lographsPrototype
//
//  Created by プー坊 on 11/09/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntryDetailViewController : UIViewController {
    NSDictionary *entry;

    IBOutlet UILabel *nameLabel;
    IBOutlet UITextField *amountText;
}

@property (nonatomic, retain) NSDictionary *entry;

- (IBAction)tapAddButton:(id)sender;

@end
