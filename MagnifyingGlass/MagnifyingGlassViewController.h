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
#import <CoreImage/CoreImage.h>

@interface MagnifyingGlassViewController : UIViewController <InfoViewControllerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> 
{
    BOOL            pictureChosen;
    
	// UIAlertSheet
	UIActionSheet   *choosePhotoAction;
    UIView          *imageTestingView;
    UIImageView     *imageTestingImageView;
    UIView          *imageBorderView;
}

@property (nonatomic, retain)           NSManagedObjectContext      *managedObjectContext;

@property (nonatomic, retain) IBOutlet  UIView          *imageContainerView;
@property (nonatomic, strong) IBOutlet UIView           *imageBorderView;
@property (nonatomic, retain) IBOutlet  UIImageView     *imageContainerImageView;
@property (nonatomic, retain)           UIImage         *magnifiedImage;
@property                               CGSize          magnifiedImageSize;

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
@property (nonatomic, strong) IBOutlet UIView                       *imageTestingView;
@property (nonatomic, strong) IBOutlet UIImageView                  *imageTestingImageView;


// MagnifyingGlass Public Methods
//- (IBAction)updateMagnifyingGlass;

// Method to add a new image...not sure if this'll be in Magnifying Glass or not.
- (IBAction)setNewImage:(UIImage *)anImage inImageView:(UIView *)anImageView;

// View Controller Action Method
- (IBAction)showInfo:(id)sender;

@end
