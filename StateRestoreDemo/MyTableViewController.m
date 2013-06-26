//
//  MyTableViewController.m
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import "MyTableViewController.h"
#import "DataSource.h"
#import "Item.h"

static NSString *kUnsavedEditStateKey = @"unsavedEditStateKey";

#ifdef MANUALLY_CREATE_VC_FOR_RESTORATION
@interface MyTableViewController () <UIViewControllerRestoration>
#else
@interface MyTableViewController ()
#endif

@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionButton;

@end

@implementation MyTableViewController

- (void)awakeFromNib
{
    // note: usually we set the restoration identifier in the storyboard, but if you want
    // to do it in code, do it here
    //
#ifdef MANUALLY_CREATE_VC_FOR_RESTORATION
    self.restorationClass = [self class];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([[DataSource sharedInstance] count] == 0)
    {
        // we don't have items stored yet, so create some default ones
        //
        [[DataSource sharedInstance] addItem:[[Item alloc] initWithTitle:@"Item 1" notes:@"Item 1 notes"]];
        [[DataSource sharedInstance] addItem:[[Item alloc] initWithTitle:@"Item 2" notes:@"Item 2 notes"]];
        [[DataSource sharedInstance] addItem:[[Item alloc] initWithTitle:@"Item 3" notes:@"Item 3 notes"]];
        [[DataSource sharedInstance] addItem:[[Item alloc] initWithTitle:@"Item 4" notes:@"Item 4 notes"]];
        
        [[DataSource sharedInstance] save];
    }

}

- (IBAction)actionButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Mail", @"Add to Favorites", nil];
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (IBAction)addButton:(id)sender
{
    DataSource *dataSource = [DataSource sharedInstance];
    [dataSource addItem:[[Item alloc] initWithTitle:@"New Item" notes:@""]];
    [dataSource save];
    
    // after we've added the item to our data source, insert a row to the table
    //
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 2)
    {
        NSArray *selectedPaths = [self.tableView indexPathsForSelectedRows];
        if (selectedPaths.count == 0)
        {
            // no selected rows, so act on the entire table
        }
        else
        {
            // act on each specific row
            for (NSIndexPath *path in selectedPaths)
            { }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;   // allow for deletion
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES; // all rows can be edited
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES; // all rows can be reordered
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    // disable the add button while in edit mode
    self.addButton.enabled = !self.tableView.editing;
    
    if (!editing)
    {
        // save any reordering or deletions
        [[DataSource sharedInstance] save];
    }
}

// user deleted a table cell, so handle the deletion in our data source
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[DataSource sharedInstance] removeItemAtIndex:indexPath.row];
        
        // animate the deletion from the table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Item *itemToMove = [[DataSource sharedInstance] itemAtIndex:sourceIndexPath.row];
    [[DataSource sharedInstance] removeItemAtIndex:sourceIndexPath.row];
    [[DataSource sharedInstance] insertItem:itemToMove atIndex:destinationIndexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.actionButton.enabled = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.actionButton.enabled = ([tableView indexPathsForSelectedRows] != nil);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%d",[[DataSource sharedInstance] count]);
    return [[DataSource sharedInstance] count];  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [[[DataSource sharedInstance] itemAtIndex:indexPath.row] title];
    
    return cell;
}

// since we are the primary view controller, we need these 2 rotating methods:
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *tappedCellIndexPath = [self.tableView indexPathForCell:sender];
        
        MyViewController *destinationVC = (MyViewController *)segue.destinationViewController;
        destinationVC.delegate = self;  // notify us when this note has been saved
        
        // here we just set the destintation view controller's backing object
        Item *rowObj = [[DataSource sharedInstance] itemAtIndex:tappedCellIndexPath.row];
        destinationVC.item = rowObj;
    }
}

#pragma mark - UIStateRestoration

#ifdef MANUALLY_CREATE_VC_FOR_RESTORATION
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    MyTableViewController *vc = nil;
    
    NSLog(@"MyTableViewController: viewControllerWithRestorationIdentifierPath");
    
    // get our main storyboard
    UIStoryboard *storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    if (storyboard)
    {
        vc = (MyTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"tableViewController"];
        vc.restorationIdentifier = [identifierComponents lastObject];
        vc.restorationClass = [MyTableViewController class];
    }
    return vc;
}
#endif

// this is called when the app is suspended to the background
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"MyTableViewController: encodeRestorableStateWithCoder");
    
    [coder encodeBool:[self.tableView isEditing] forKey:kUnsavedEditStateKey];
    
    [super encodeRestorableStateWithCoder:coder];
}

// this is called when the app is re-launched
- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    // important: don't affect our views just yet, we might not visible or we aren't the current
    // view controller, save off our ivars and restore our text view in viewWillAppear
    //
    NSLog(@"MyTableViewController: decodeRestorableStateWithCoder");
    
    [super decodeRestorableStateWithCoder:coder];
    
    self.tableView.editing = [coder decodeBoolForKey:kUnsavedEditStateKey];
    
    [self.tableView reloadData];
}


#pragma mark - UIDataSourceModelAssociation

// determine the identifier for the item at the given index path,
// note: if this method is not called, then you probably don't have the restore identifier
// set on your UITableView, or you have not adopted "UIDataSourceModelAssociation"
//
- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)path inView:(UIView *)view
{
    NSLog(@"MyTableViewController: modelIdentifierForElementAtIndexPath");
    
    NSString *identifier = nil;
    
    if (path && view)
    {
        // return an identifier of the given NSIndexPath, in case next time the data source has changed
        Item *item = [[DataSource sharedInstance] itemAtIndex:path.row];
        if (item != nil)
        {
            identifier = item.identifier;
        }
    }
    
    return identifier;
}

// during state restoration, "view" can call this method to locate objects that are not
// where they were expected to be.
//
- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    NSLog(@"MyTableViewController: indexPathForElementWithModelIdentifier");
    
    NSIndexPath *indexPath = nil;
    
    if (identifier && view)
    {
        // come up with the appropriate object for the given identifier, in case the data
        // source has changed
        //
        Item *item = [[DataSource sharedInstance] itemWithIdentifier:identifier];
        if (item)
        {
            indexPath = [[DataSource sharedInstance] indexPathForItem:item];
        }
    }
    
    return indexPath;
}


#pragma mark - MyViewControllerDelegate

// our detail view controller (MyViewController) is telling us it finished editing the notes
//
- (void)editHasEnded:(MyViewController *)viewController withItem:(Item *)item
{
    [[DataSource sharedInstance] save];
    
    NSIndexPath *indexPath = [[DataSource sharedInstance] indexPathForItem:item];
    if (indexPath != nil)
    {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}


@end
