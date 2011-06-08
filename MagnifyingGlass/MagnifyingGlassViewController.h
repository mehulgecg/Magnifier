//
//  MainViewController.h
//  KrazyKim
//
//  Created by James Hillhouse on 5/13/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import "InfoViewController.h"

#import "MagnifyingGlass.h"

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MagnifyingGlassViewController : UIViewController <InfoViewControllerDelegate, UIGestureRecognizerDelegate> 
{
    UIView          *_worldMapView;
    UIImageView     *_worldMapImageView;
    UIImage         *_worldMapImage;
    CGSize          _worldImageSize;
    
    MagnifyingGlass *_magnifyingGlassView;
    UILabel         *magnifyingGlassLabel;
}

@property (nonatomic, retain)           NSManagedObjectContext      *managedObjectContext;

@property (nonatomic, retain) IBOutlet  UIView          *worldMapView;
@property (nonatomic, retain) IBOutlet  UIImageView     *worldMapImageView;
@property (nonatomic, retain)           UIImage         *worldMapImage;
@property                               CGSize          worldImageSize;

@property                               CGFloat         xScale;
@property                               CGFloat         yScale;

@property (nonatomic, retain) IBOutlet  MagnifyingGlass *magnifyingGlassView;
@property (nonatomic, retain) IBOutlet  UILabel         *magnifyingGlassLabel;
//@property                               CGFloat         magnifyingGlassDiameter;
//@property                               CGFloat         maxMagnifyingGlassDiameter;
//@property                               CGFloat         minMagnifyingGlassDiameter;
//@property                               CGFloat         magnifyingGlassZoom;
//@property                               CGFloat         magnifyingGlassScale;

@property (nonatomic, retain)           UITapGestureRecognizer      *tapRecognizer;
@property (nonatomic, retain)           UIPanGestureRecognizer      *panRecognizer;
@property (nonatomic, retain)           UIPinchGestureRecognizer    *pinchRecognizer;
@property (nonatomic, retain)           UIRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, retain)           UIPanGestureRecognizer      *panResizeRecognizer;


// MagnifyingGlass Public Methods
//- (IBAction)updateMagnifyingGlass;

// Method to add a new image...not sure if this'll be in Magnifying Glass or not.
- (IBAction)setNewImage:(UIImage *)anImage inImageView:(UIView *)anImageView;

// View Controller Action Method
- (IBAction)showInfo:(id)sender;

@end
