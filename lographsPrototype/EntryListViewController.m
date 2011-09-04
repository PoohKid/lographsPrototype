//
//  EntriesListViewController.m
//  lographsPrototype
//
//  Created by プー坊 on 11/09/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntryListViewController.h"
#import "EntryCell.h"
#import "EntryDetailViewController.h"

@implementation EntryListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [entryList_ release], entryList_ = nil;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    entryList_ = [[NSArray arrayWithObjects:
                   @"お昼寝の時間",
                   @"間食",
                   @"イライラ",
                   @"子供の身長",
                   @"子供の体重",
                   nil] retain];
    self.tableView.rowHeight = 61.0;
}

- (void)viewDidUnload
{
    [entryList_ release], entryList_ = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [entryList_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EntryCell";

    EntryCell *cell = (EntryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0] retain] autorelease];
    }

//    NSString *text;
//    UIFont *font;
//    CGSize size;
//    text = cell.titleLabel.text;
//    font = cell.titleLabel.font;
//    size = [text sizeWithFont:font];
//    NSLog(@"%@, %@, %f", text, font.fontName, font.pointSize); //お昼寝の時間, Helvetica, 18.000000
//    NSLog(@"%f, %f", size.width, size.height); //109.000000, 22.000000
//    text = cell.dateLabel.text;
//    font = cell.dateLabel.font;
//    size = [text sizeWithFont:font];
//    NSLog(@"%@, %@, %f", text, font.fontName, font.pointSize); //2011/08/23 08:21, Helvetica, 12.000000
//    NSLog(@"%f, %f", size.width, size.height); //95.000000, 15.000000

    // Configure the cell...
    //cell.textLabel.text = [entryList_ objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = [entryList_ objectAtIndex:indexPath.row];
            cell.dateLabel.text = @"2011/08/23 08:21";
            cell.amountLabel.text = @"1回";
            break;
        case 1:
            cell.titleLabel.text = [entryList_ objectAtIndex:indexPath.row];
            cell.dateLabel.text = @"2011/08/23 08:21";
            cell.amountLabel.text = @"1回";
            break;
        case 2:
            cell.titleLabel.text = [entryList_ objectAtIndex:indexPath.row];
            cell.dateLabel.text = @"2011/08/23 08:21";
            cell.amountLabel.text = @"☆☆";
            break;
        case 3:
            cell.titleLabel.text = [entryList_ objectAtIndex:indexPath.row];
            cell.dateLabel.text = @"2011/08/23 08:21";
            cell.amountLabel.text = @"30cm";
            break;
        case 4:
            cell.titleLabel.text = [entryList_ objectAtIndex:indexPath.row];
            cell.dateLabel.text = @"2011/08/23 08:21";
            cell.amountLabel.text = @"12Kg";
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    EntryDetailViewController *entryDetailViewController = [[EntryDetailViewController alloc] initWithNibName:@"EntryDetailViewController" bundle:nil];

    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:entryDetailViewController animated:YES];
    [entryDetailViewController release];
}

@end
