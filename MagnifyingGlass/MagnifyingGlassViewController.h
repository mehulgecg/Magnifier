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

@interface MagnifyingGlassViewController : UIViewController <InfoViewControllerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> 
{
    UIView          *_worldMapView;
    UIImageView     *_worldMapImageView;
    UIImage         *_worldMapImage;
    CGSize          _worldImageSize;
    
    MagnifyingGlass *magnifier;
    UIView          *magnifierView;
    UILabel         *magnifierLabel;
    
    
	// UIAlertSheet
	UIActionSheet   *choosePhotoAction;
}

@property (nonatomic, retain)           NSManagedObjectContext      *managedObjectContext;

@property (nonatomic, retain) IBOutlet  UIView          *worldMapView;
@property (nonatomic, retain) IBOutlet  UIImageView     *worldMapImageView;
@property (nonatomic, retain)           UIImage         *worldMapImage;
@property                               CGSize          worldImageSize;

@property                               CGFloat         xScale;
@property                               CGFloat         yScale;

@property (nonatomic, retain)           MagnifyingGlass *magnifier;
@property (nonatomic, retain) IBOutlet  UIView          *magnifierView;
@property (nonatomic, retain) IBOutlet  UILabel         *magnifierLabel;

@property (nonatomic, retain)           UITapGestureRecognizer      *tapRecognizer;
@property (nonatomic, retain)           UIPanGestureRecognizer      *panRecognizer;
@property (nonatomic, retain)           UIPinchGestureRecognizer    *pinchRecognizer;
@property (nonatomic, retain)           UIRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, retain)           UIPanGestureRecognizer      *panResizeRecognizer;


@property (nonatomic, retain)           UIImagePickerController     *imagePicker;


// MagnifyingGlass Public Methods
//- (IBAction)updateMagnifyingGlass;

// Method to add a new image...not sure if this'll be in Magnifying Glass or not.
- (IBAction)setNewImage:(UIImage *)anImage inImageView:(UIView *)anImageView;

// View Controller Action Method
- (IBAction)showInfo:(id)sender;

@end
