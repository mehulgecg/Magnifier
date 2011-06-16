//
//  FlipsideViewController.h
//  KrazyKim
//
//  Created by James Hillhouse on 5/13/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoViewController;


@protocol InfoViewControllerDelegate
- (void)infoViewControllerDidFinish:(InfoViewController *)controller;
@end

@interface InfoViewController : UIViewController <UIGestureRecognizerDelegate>

@property (assign, nonatomic) IBOutlet id <InfoViewControllerDelegate> delegate;
@property (nonatomic, retain)           UITapGestureRecognizer      *tapRecognizer;

- (IBAction)done:(id)sender;

@end
