//
//  EntryDetailViewController.m
//  lographsPrototype
//
//  Created by プー坊 on 11/09/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryDetailViewController.h"
#import "LographsModel.h"
#import "NSDictionary+Null.h"

@implementation EntryDetailViewController

@synthesize entry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [entry release], entry = nil;
    [nameLabel release], nameLabel = nil;
    [amountText release], amountText = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"項目";
    nameLabel.text = [entry objectForKeyNull:@"name"];
}

- (void)viewDidUnload
{
    [nameLabel release], nameLabel = nil;
    [amountText release], amountText = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBAction

- (IBAction)tapAddButton:(id)sender
{
    [[LographsModel sharedLographsModel] addEntry:[[entry objectForKeyNull:@"item_id"] intValue]
                                           amount:[amountText.text doubleValue]];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
