//
//  FlipsideViewController.h
//  KrazyKim
//
//  Created by James Hillhouse on 5/13/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewControllerDelegate;

@interface InfoViewController : UIViewController 
{

}

@property (nonatomic, assign) id <InfoViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end


@protocol InfoViewControllerDelegate
- (void)infoViewControllerDidFinish:(InfoViewController *)controller;
@end
