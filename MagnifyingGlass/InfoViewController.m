//
//  FlipsideViewController.m
//  KrazyKim
//
//  Created by James Hillhouse on 5/13/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import "InfoViewController.h"



@interface InfoViewController() 
- (void)createGestureRecognizers;
- (void)handleTapFromGestureRecognizer;
@end


@implementation InfoViewController



@synthesize delegate = _delegate;
@synthesize tapRecognizer;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor]; 
    
    //
    // Create the Gesture Recognizers
    //
    [self createGestureRecognizers];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate infoViewControllerDidFinish:self];
}



#pragma mark -
#pragma mark Gesture Recognizers
- (void)createGestureRecognizers
{
    
    //
    // Gesture Recognizers
    //
    UIGestureRecognizer *gestureRecognizer;
	
    // Tap Gesture (for recentering magnifying glass)
	gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFromGestureRecognizer:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	self.tapRecognizer                      = (UITapGestureRecognizer *)gestureRecognizer;
	self.tapRecognizer.numberOfTapsRequired = 1;
	self.tapRecognizer.delegate             = self;
}



- (void)handleTapFromGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self done:recognizer];
}

@end
