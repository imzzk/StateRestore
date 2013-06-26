//
//  MyViewController.m
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import "MyViewController.h"
#import "Item.h"
#import "DataSource.h"

static NSString *kUnsavedItemKey =@"unsavedItemKey";

#ifdef MANUALLY_CREATE_VC_FOR_RESTORATION
@interface MyViewController () <UIViewControllerRestoration>
#else
@interface MyViewController ()
#endif
@property(nonatomic,weak)IBOutlet UINavigationBar *navigationBar;

@property(nonatomic,weak)IBOutlet UITextField *editField;
@property(nonatomic,weak)IBOutlet UITextView *textView;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *saveButton;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation MyViewController

- (void)awakeFromNib
{
    // note: usually we set the restoration identifier in the storyboard, but if you want
    // to do it in code, do it here
    //
#ifdef MANUALLY_CREATE_VC_FOR_RESTORATION
    self.restorationClass = [self class];
#endif
}

- (void)setupWithItem
{
    if (self.item)
    {
        self.editField.text = self.item.title;
        self.textView.text = self.item.notes;
        self.navigationBar.topItem.title = self.item.title;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.editField];
    
    [self.textView becomeFirstResponder];  // we want the keyboard up when this view appears

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:self.editField];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupWithItem];
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


#pragma mark - UIStateRestoration

// this is called when the app is suspended to the background
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"MyViewController: encodeRestorableStateWithCoder");
    
    // save off any recent changes first since we are about to be suspended
    self.item.notes = self.textView.text;
    [[DataSource sharedInstance] save];
    
    // encode only its UUID (identifier), and later we get back the item by searching for its UUID
    [coder encodeObject:self.item.identifier forKey:kUnsavedItemKey];
    
    [super encodeRestorableStateWithCoder:coder];
}

// this is called when the app is re-launched
- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    // important: don't affect our views just yet, we might not visible or we aren't the current
    // view controller, save off our ivars and restore our text view in viewWillAppear
    //
    NSLog(@"MyViewController: decodeRestorableStateWithCoder");
    
    // decode the edited item
    if ([coder containsValueForKey:kUnsavedItemKey])
    {
        // unarchive the UUID (identifier) and search for the item by its UUID
        NSString *identifier = [coder decodeObjectForKey:kUnsavedItemKey];
        self.item = [[DataSource sharedInstance] itemWithIdentifier:identifier];
        [self setupWithItem];
    }
    
    [super decodeRestorableStateWithCoder:coder];
}


#pragma mark - UIViewControllerRestoration

#ifdef MANUALLY_CREATE_VC_FOR_RESTORATION
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    NSLog(@"MyViewController: viewControllerWithRestorationIdentifierPath called for %@", identifierComponents);
    
    MyViewController *vc = nil;
    
    // get our main storyboard to obtain our view controller
    UIStoryboard *storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    if (storyboard)
    {
        vc = (MyViewController *)[storyboard instantiateViewControllerWithIdentifier:@"viewController"];
        vc.restorationIdentifier = [identifierComponents lastObject];
        vc.restorationClass = [MyViewController class];
    }
    return vc;
}
#endif


#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    // user tapped the Save button, save the contents
    //
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.item.notes = self.textView.text;
        self.item.title = self.editField.text;
        
        [self.delegate editHasEnded:self withItem:self.item];
    }];
}

- (IBAction)cancelAction:(id)sender
{
    // user tapped the Cancel button, don't save
    //
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Keyboard support

- (void)adjustViewForKeyboardReveal:(BOOL)showKeyboard notificationInfo:(NSDictionary *)notificationInfo
{
    // the keyboard is showing so resize the text view's height
	CGRect keyboardRect = [[notificationInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
    [[notificationInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.textView.frame;
    
    // note the keyboard rect's width and height are reversed in landscape
    NSInteger adjustDelta =
    UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? CGRectGetHeight(keyboardRect) : keyboardRect.size.width;
    
    if (showKeyboard)
        frame.size.height -= adjustDelta;
    else
        frame.size.height += adjustDelta;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.textView.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
	[self adjustViewForKeyboardReveal:YES notificationInfo:[aNotification userInfo]];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self adjustViewForKeyboardReveal:NO notificationInfo:[aNotification userInfo]];
}

- (void)editFieldChanged:(NSNotification *)notif
{
    // disable the Save button if there is no text for the title
    UITextField *textField = [notif object];
    self.saveButton.enabled = textField.text.length > 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
