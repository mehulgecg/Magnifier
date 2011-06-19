//
//  MainViewController.m
//  KrazyKim
//
//  Created by James Hillhouse on 5/13/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import "MagnifyingGlassViewController.h"

#import "MagnifyingGlass.h"
#import "UIImage+ScaleRotate.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <CoreImage/CoreImage.h>





//CGFloat         DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
//CGFloat         RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};
static CGFloat  kMaxHeight				= 380.0; // Defines maximum image height
static CGFloat  kMaxWidth				= 280.0; // Defines maximum image width
static BOOL     hasRunOnce              = NO;



@interface MagnifyingGlassViewController () 

- (CGRect)rectFromImage:(UIImage *)anImage inView:(UIView *)aView;

// Image and CGImageRef Methods
- (void)renderView:(UIView*)aView inContext:(CGContextRef)context;

// Gesture Recognizers
- (void)createGestureRecognizers;
- (void)handleDoubleTapFromGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer;
- (void)handlePanFromGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)handleResizeFromGestureRecognizer:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)handlePanResizeFromGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)userJustDoubleTapped:(NSError *)error;
@end




@implementation MagnifyingGlassViewController



@synthesize managedObjectContext = _managedObjectContext;

@synthesize worldMapView        = _worldMapView;
@synthesize worldMapImageView   = _worldMapImageView;
@synthesize worldMapImage       = _worldMapImage;
@synthesize worldImageSize      = _worldImageSize;

@synthesize xScale;
@synthesize yScale;

@synthesize magnifier;
@synthesize magnifierView;
@synthesize magnifierLabel;

@synthesize tapRecognizer;
@synthesize panRecognizer;
@synthesize pinchRecognizer;
@synthesize rotationRecognizer;
@synthesize panResizeRecognizer;

@synthesize imagePicker;
@synthesize ImageTestingView;
@synthesize ImageTestingImageView;



#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    NSLog(@"\n\n-viewDidLoad\n\n");
    
    [super viewDidLoad];
    
    //
    // Create the Gesture Recognizers
    //
    [self createGestureRecognizers];
    
    
    //
    // Set the main background image conditioned on this being a first run.
    //
    if (!hasRunOnce) 
    {
        self.worldMapImage = [UIImage imageWithCGImage:[UIImage imageNamed:@"iPhone4"].CGImage scale:[[UIScreen mainScreen]scale] orientation:UIImageOrientationUp];
    }
    
    hasRunOnce = YES;
}



- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"\n\n-viewDidAppear\n\n");
    [super viewDidAppear:animated];
    
    [self setNewImage:self.worldMapImage inImageView:self.worldMapImageView];
 
    //NSLog(@"image orientation = %u", self.worldMapImage.imageOrientation);
    
    //
    //Create the magnifying glass object and set its values
    //
    self.magnifier = [[MagnifyingGlass alloc] init];
    
    [self.magnifier createMagnifyingGlassWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.magnifier.magnifyingGlassView =  self.magnifierView;
    self.magnifier.magnifyingGlassLabel = self.magnifierLabel;
    self.magnifier.magnifyingGlassImage = self.worldMapImage;
    self.magnifierLabel.alpha = 0.0;
    self.magnifierView.backgroundColor = [UIColor clearColor];
    
    [self.magnifier updateMagnifyingGlass];
}



- (void)viewDidUnload
{
    NSLog(@"\n\n-viewDidUnload\n\n");
    
    [self setImageTestingView:nil];
    [self setImageTestingImageView:nil];
    [super viewDidUnload];
    
    //self.worldMapImageView = nil;
    //self.worldMapImageView.image = nil;
}



#pragma mark - Image Methods
- (IBAction)setNewImage:(UIImage *)anImage inImageView:(UIImageView *)anImageView
{
    //
    //
    // Check out the method visibleBounds:toView:
    //
    //
    
    
    //
    //
    // Don't forget to apply contentScale: 
    // 
    // and [[UIScreen mainScreen] scale] * scaleOfZoom
    //
    //
    //
    
    
    NSLog(@"\n\n\n\n-setNewImage");
    
    
    //
    // Let's see how big the image is...this will likely go away in the final release.
    //
    CGSize imageSize = CGSizeMake(anImage.size.width, anImage.size.height);
    NSLog(@"image size = (%f, %f)", imageSize.width, imageSize.height);
    
    
    //
    // Scale the rect to fit the image within the the bounds of the screen
    //
    CGRect newImageRect = [self rectFromImage:anImage inView:self.worldMapView];
    NSLog(@"newImageRect = (%f, %f, %f, %f)", newImageRect.origin.x, newImageRect.origin.y, newImageRect.size.width, newImageRect.size.height);
   
    
    //
    // Resize container view to the diminsions of the resized rect.
    //
    self.worldMapView.center = self.view.center;
    self.worldMapView.frame = CGRectMake(newImageRect.origin.x, newImageRect.origin.y, newImageRect.size.width, newImageRect.size.height);
    NSLog(@"worldMapView frame = %f, %f, %f, %f", self.worldMapView.frame.origin.x, self.worldMapView.frame.origin.y, self.worldMapView.frame.size.width, self.worldMapView.frame.size.height);
    
    
    //
    // Resize the image view containing the image to the dimensions of the resized rect.
    //
    self.worldMapImageView.center = self.worldMapView.center;
    self.worldMapImageView.frame = CGRectMake(0.0, 0.0, newImageRect.size.width, newImageRect.size.height);
    NSLog(@"worldMapImageView frame = %f, %f, %f, %f", self.worldMapImageView.frame.origin.x, self.worldMapImageView.frame.origin.y, self.worldMapImageView.frame.size.width, self.worldMapImageView.frame.size.height);
    NSLog(@"worldImage size = %f, %f,", self.worldMapImage.size.width, self.worldMapImage.size.height);
    
    
    self.worldMapImageView.layer.minificationFilter = kCAFilterTrilinear;
	self.worldMapImageView.layer.minificationFilterBias = 0;

    
    UIImage *tempImage = [anImage scaleToRect:newImageRect];
    NSLog(@"anImage scaled size = %f, %f", anImage.size.width, anImage.size.height);
    NSLog(@"tempImage scaled size = %f, %f", tempImage.size.width, tempImage.size.height);

    
    self.worldMapImageView.image = tempImage;
    self.worldMapImageView.alpha = 0.9;
    //self.worldMapImageView.image = [UIImage imageWithCGImage:self.worldMapImage.CGImage scale:[[UIScreen mainScreen]scale] orientation:UIImageOrientationUp];
    

    // 
    // Now set-up the image for the magnifying glass.
    //
    //
    // Start by capturing the whole screen. We have to do this because UIGraphicsBeginImageContextWithOptions, like its predessor 
    // UIGraphicsBeginImageContext, uses UIKit's coorodinate system, the origin for which is the upper left-hand corner of the 
    // screen.
    //
    // Why wouldn't I want to pass-in the actual image size?
    //
    CGSize newImageSize = CGSizeMake(newImageRect.size.width, newImageRect.size.height);
    
    UIGraphicsBeginImageContextWithOptions(newImageSize, NO, 0);
    
    
    //UIGraphicsBeginImageContextWithOptions([[UIScreen mainScreen] bounds].size, NO, 0);
    //NSLog(@"[[UIScreen mainScreen]bounds] = %f, %f, %f, %f", [[UIScreen mainScreen]bounds].origin.x, [[UIScreen mainScreen]bounds].origin.y, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect tempRect = CGRectMake(0.0, 0.0, newImageRect.size.width, newImageRect.size.height);
    CGContextClearRect(context, tempRect);
    
    CGContextSaveGState(context);


    //CGContextConcatCTM(context, CGContextGetUserSpaceToDeviceSpaceTransform(context));
    
    CGContextTranslateCTM(context, newImageSize.width / 2.0, newImageSize.height / 2.0);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -newImageSize.width / 2.0, -newImageSize.height / 2.0);
    
    
    //CGContextTranslateCTM(context, self.worldMapView.center.x, self.worldMapView.center.y);
    //CGContextRotateCTM(context, M_PI);
    //CGContextTranslateCTM(context, -self.worldMapView.center.x, -self.worldMapView.center.y);

    /*
    //
    // Offset by the portion of the bounds left of and above the anchor point
    //
    CGContextTranslateCTM(context,
                          -[self.worldMapView bounds].size.width * [[self.worldMapView layer] anchorPoint].x,
                          -[self.worldMapView bounds].size.height * [[self.worldMapView layer] anchorPoint].y);
    
    */
    

    CGContextDrawImage(context, tempRect, anImage.CGImage);
    
    
    //
    // This is where the image is drawn to the origin of the image rect.
    //
    //UIGraphicsPushContext(context);
    //[anImage drawAtPoint:CGPointMake(newImageRect.origin.x, newImageRect.origin.y)];
    //[anImage drawInRect:newImageRect];
    //UIGraphicsPopContext();
    
    
    CGContextRestoreGState(context);
    
    
    //
    // Retrieve the screenshot image containing both the camera content and the overlay view
    //
    self.worldMapImage = UIGraphicsGetImageFromCurrentImageContext();
    NSLog(@"final image size = %f, %f", self.worldMapImage.size.width, self.worldMapImage.size.height);
    
    UIGraphicsEndImageContext();
    
    self.ImageTestingImageView.image = self.worldMapImage;

    
    //
    // Core Image Code
    //
//    CGRect imageTestingRect = CGRectMake(0.0, 0.0, newImageRect.size.width, newImageRect.size.height);
//    CIImage *tempCoreImage = [CIImage imageWithCGImage:anImage.CGImage];
//    CGRect tempCoreImageRect = [tempCoreImage extent];
//    NSLog(@"tempCoreImageRect = %f, %f, %f, %f", tempCoreImageRect.origin.x, tempCoreImageRect.origin.y, tempCoreImageRect.size.width, tempCoreImageRect.size.height);
//    CGAffineTransform transform = CGAffineTransformMakeScale(10.0, 10.0);
//    tempCoreImage = [tempCoreImage imageByApplyingTransform:transform];

//    CIFilter *scaleAdjust = [CIFilter filterWithName:@"CIAffineTransform"];
//    [scaleAdjust setDefaults];
//    [scaleAdjust setValue:tempCoreImage forKey:@"inputImage"];
//    [scaleAdjust setValue:5.0 forKey:@"inputTransform"];
    
//    CIContext *ciContext = [CIContext contextWithOptions:nil];
    
    //UIImage *ciImage = [UIImage imageWithCIImage:tempCoreImage]; // This will not work!
//    UIImage *ciImage = [UIImage imageWithCGImage:[ciContext createCGImage:tempCoreImage fromRect:CGRectMake(0, 0, newImageRect.size.width * [[UIScreen mainScreen] scale], newImageRect.size.height * [[UIScreen mainScreen] scale])]];
//    NSLog(@"ciImage size = %f, %f", ciImage.size.width, ciImage.size.height);
//    self.ImageTestingImageView.image = ciImage;
    
    NSLog(@"\n\n");
}



#pragma mark -
#pragma mark Other Methods

- (CGRect)rectFromImage:(UIImage *)anImage inView:(UIView *)aView
{
    NSLog(@"\n\n-rectFromImage:inView:");
	CGRect imageRect;
    
    self.worldMapView.layer.transform = CATransform3DIdentity;
    self.worldMapImageView.layer.transform = CATransform3DIdentity;
	
	////////////////////////////////////////////////////
	//
	// Image ratio
	//
	////////////////////////////////////////////////////
    
    NSLog(@"\n\n-rectFromImage:anImage:inView:");
    NSLog(@"Image size = %f, %f", anImage.size.width, anImage.size.height);
    NSLog(@"Resizing rect of size = %f, %f", aView.frame.size.width, aView.frame.size.height);
    
	CGFloat imageResizedWidth;
	CGFloat imageResizedHeight;
	CGFloat imageScaleWidth     = kMaxWidth / anImage.size.width;
	CGFloat imageScaleHeight    = kMaxHeight / anImage.size.height;
    
    NSLog(@"scaled width and height = %f, %f", imageScaleWidth, imageScaleHeight);
	    
    if (imageScaleWidth > 1.0 || imageScaleHeight > 1.0) 
    {
        imageScaleWidth     = 1.0;
        imageScaleHeight    = 1.0;
    }
    else
    {
        imageScaleWidth			= kMaxWidth / anImage.size.width;
        imageScaleHeight		= kMaxHeight / anImage.size.height;
    }
	
	if (anImage.size.width > anImage.size.height) // Landscape
	{
        NSLog(@"Landscape");
		imageResizedWidth		= floorf(anImage.size.width * imageScaleWidth);
		imageResizedHeight		= floorf(anImage.size.height * imageScaleWidth);
	}
	if (anImage.size.height > anImage.size.width) // Portrait
	{
        NSLog(@"Portait");
		imageResizedWidth		= floorf(anImage.size.width * imageScaleHeight);
		imageResizedHeight		= floorf(anImage.size.height * imageScaleHeight);
	}
	if (anImage.size.height == anImage.size.width) 
	{
		imageResizedWidth		= floorf(anImage.size.width * imageScaleWidth);
		imageResizedHeight		= floorf(anImage.size.height * imageScaleWidth);
	}
    
    NSLog(@"aView center = %f, %f", aView.center.x, aView.center.y);
    

	imageRect           = CGRectMake(aView.center.x - imageResizedWidth / 2.0, // origin.x
                                      aView.center.y - imageResizedHeight / 2.0, // origin.y
                                      imageResizedWidth, // width
                                      imageResizedHeight); // height
    
    NSLog(@"To resized imageRect = %f, %f, %f, %f", imageRect.origin.x, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
    NSLog(@"\n\n");
    
    
    
    return imageRect;
}



#pragma mark -
#pragma mark Methods for OpenGL & UIKView Screenshots based on Q&A 1702, Q&A 1703, Q&A 1704, & Q&A 1714

- (void)renderView:(UIView*)view inContext:(CGContextRef)context
{
	//////////////////////////////////////////////////////////////////////////////////////
	//																					//
	// This works like a charm when you have multiple views that need to be rendered	//
	// in a UIView when one of those views is an OpenGL CALayer view or a camera stream	//
	// or some other view that will not work with - (UIImage*)screenshot, as defined 	//
	// in Technical Q&A QA1703, "Screen Capture in UIKit Applications".					//
	//																					//
	//////////////////////////////////////////////////////////////////////////////////////
	
	
	//
	// -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context.
	//
    CGContextSaveGState(context);
    
	
	//
	// Center the context around the window's anchor point.
	//
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    
	
	//
	// Apply the window's transform about the anchor point.
	//
    CGContextConcatCTM(context, [view transform]);
	
	
	//
    // Offset by the portion of the bounds left of and above the anchor point.
	//
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    
	
	//
	// Render the layer hierarchy to the current context.
	//
    [[view layer] renderInContext:context];
	
    
	//
	// Restore the context. BTW, you're done.
	//
    CGContextRestoreGState(context);
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
	gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFromGestureRecognizer:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	self.tapRecognizer                      = (UITapGestureRecognizer *)gestureRecognizer;
	self.tapRecognizer.numberOfTapsRequired = 2;
	self.tapRecognizer.delegate             = self;
	
	// Pan Gesture (for translating magnifying glass)
	gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFromGestureRecognizer:)];
	self.panRecognizer                      = (UIPanGestureRecognizer *)gestureRecognizer;
	[self.magnifierView addGestureRecognizer:panRecognizer];
	panRecognizer.delegate                  = self;
	
	// Pinch Gesture (for zoom of magnifying glass)
	gestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomFromGestureRecognizer:)];
	self.pinchRecognizer                    = (UIPinchGestureRecognizer *)gestureRecognizer;
	[self.view addGestureRecognizer:pinchRecognizer];
	pinchRecognizer.delegate                = self;
	
	// Rotation Gesture (for resizing magnifying glass)
    gestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizeFromGestureRecognizer:)];
    self.rotationRecognizer                 = (UIRotationGestureRecognizer *)gestureRecognizer;
    [self.view addGestureRecognizer:rotationRecognizer];
    rotationRecognizer.delegate             = self;
	
	// Pan Gesture ( for resizing magnifying glass)
	gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanResizeFromGestureRecognizer:)];
	self.panResizeRecognizer                = (UIPanGestureRecognizer *)gestureRecognizer;
	[self.view addGestureRecognizer:panResizeRecognizer];
    self.panResizeRecognizer.minimumNumberOfTouches = 2;
	panResizeRecognizer.delegate            = self;
}



- (void)handleDoubleTapFromGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"\n\n\n\nDouble tap\n\n\n\n");
    //CGSize screenSize = [[UIScreen mainScreen]bounds].size;
    //CGPoint screenCenter = CGPointMake(screenSize.width / 2.0, screenSize.height / 2.0);
    
    CGPoint screenCenter = self.worldMapImageView.center;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.magnifierView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.magnifierView.layer.position = screenCenter;
        
        
    }completion:^( BOOL finished )
     { 
         self.magnifierView.transform = CGAffineTransformMakeScale(1.0, 1.0);
         [self.magnifier updateMagnifyingGlass];
     }];
}



- (void)handlePanFromGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
	// CGPoint translation note:
	// Lay-out of iPhone/iPad screen coordinate system
	// 
	//  +------------------------------------> X
	//  |
	//  |
	//  |            ^
	//  |            |
	//  |           (-)
	//  |            |
	//  |    <-(-)--   --(+)->
	//  |            |
	//  |           (+)
	//  |            |
	//  |            v
	//  |
	//  v
	// 
	//  Y
	
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [self.magnifier dimMagnifyingGlass];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) 
    {
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        
        [self.magnifierView setCenter:CGPointMake(self.magnifierView.center.x + translation.x, self.magnifierView.center.y + translation.y)];
        
        [gestureRecognizer setTranslation:CGPointZero inView:[self.magnifierView superview]];
        
        [self.magnifier updateMagnifyingGlass];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) 
    {
        [self.magnifier undimMagnifyingGlass];
    }
}



- (void)handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer
{
    //
    // This sets the spacing between layers.
    //
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStatePossible)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifierLabel.alpha = 1.0;
        }];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) 
    {
        //NSLog(@"\n\n\nZoom Scale = %f", gestureRecognizer.scale);
        
        self.magnifier.magnifyingGlassZoom = gestureRecognizer.scale * 1.75;
        
        [self.magnifier updateMagnifyingGlassForZoom];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) 
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifierLabel.alpha = 0.0;
        }];
    }
} 



- (void)handleResizeFromGestureRecognizer:(UIRotationGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifierLabel.alpha = 1.0;
        }];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) 
    {
        //
        // Turn rotation from radians to degrees since this will work better for what we're trying to do here,
        // which is resize a mangifying glass from some diameter.
        //
        CGFloat reticleScaleIncrement   = [gestureRecognizer rotation] * 180.0 / M_PI;
        
        
        //
        // This resizes the diameter of the magnifying glass
        //
        self.magnifier.magnifyingGlassDiameter += ( reticleScaleIncrement / 10.0 );
        [self.magnifier updateMagnifyingGlassForDiameter];
        
        
        //NSLog(@"reticleScaleIncrement = %f", reticleScaleIncrement);
        //NSLog(@"resulting reticleDiameter = %f\n\n", self.magnifier.magnifyingGlassDiameter);
        
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) 
    {
        [gestureRecognizer setRotation:0.0];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifierLabel.alpha = 0.0;
        }];
    }
}



- (void)handlePanResizeFromGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifierLabel.alpha = 1.0;
        }];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) 
    {
        //
        // Swipe up or down to change the size of the magnifying glass.
        //
        CGFloat magnifyingGlassResizeIncrement   = [gestureRecognizer translationInView:self.worldMapView].y;
        
        
        //
        // This resizes the diameter of the magnifying glass
        //
        self.magnifier.magnifyingGlassDiameter -= magnifyingGlassResizeIncrement / 10.0;
        [self.magnifier updateMagnifyingGlassForDiameter];
        
        
        //NSLog(@"magnifyingGlassResizeIncrement = %f", magnifyingGlassResizeIncrement);
        //NSLog(@"resulting magnifyingGlassDiameter = %f\n\n", self.magnifier.magnifyingGlassDiameter);
        
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) 
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifierLabel.alpha = 0.0;
        }];
    }    
}



# pragma mark - Alerts

- (void) userJustDoubleTapped:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You just double tapped :-)"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
}






# pragma mark - UtilityViewController Delegate Methods

- (void)infoViewControllerDidFinish:(InfoViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}



- (IBAction)showInfo:(id)sender
{    
    InfoViewController *controller = [[InfoViewController alloc] initWithNibName:@"InfoView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}




#pragma mark - View controller rotation methods
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
*/



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"Going to handle device orientation change");
    
    //UIInterfaceOrientation orientation;
    
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"Going to handle device orientation change");
    
    //UIInterfaceOrientation orientation;
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}



#pragma mark -
#pragma mark Camera Methods

- (IBAction)choosePhoto:(id)sender 
{
	NSLog(@"-choosePhoto:");
	
	choosePhotoAction = [[UIActionSheet alloc] initWithTitle:@"Choose A New Image" 
													 delegate:self cancelButtonTitle:@"Cancel" 
									   destructiveButtonTitle:nil 
											otherButtonTitles:@"Camera", @"Photo Library", nil];
	
	choosePhotoAction.delegate = self;
	
	choosePhotoAction.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[choosePhotoAction showInView:self.view];
	
	NSLog(@"\n\n");
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (choosePhotoAction) 
	{
		NSLog(@"Choosing a new background.");
		/*
         if (buttonIndex == 0) 
         {
         if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
         {
         
         NSLog(@"Choose live stream");
         UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
         
         self.imagePicker = picker;
         
         self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
         self.imagePicker.allowsEditing = NO;
         self.imagePicker.showsCameraControls = NO;
         self.imagePicker.wantsFullScreenLayout = YES;
         [self presentModalViewController:self.imagePicker animated:YES];
         
         self.imagePicker.cameraOverlayView = self.overlayView;
         
         [self moveOptionsViewOffScreen];
         self.liveStreamCameraButton.hidden = YES;
         
         [self startAnimation];
         
         //
         // This actually starts the music going.
         //
         if (self.playMusic) 
         {
         [self startPlayback];
         }
         
         
         //
         // Without this, UIGestureRecognizer doesn't know who the First Responder is.
         //
         [self becomeFirstResponder];
         
         }
         else 
         {
         NSLog(@"Oops! No camera available");
         UIAlertView *alert = [[UIAlertView alloc] 
         initWithTitle:@"No camera available." 
         message:nil 
         delegate:nil 
         cancelButtonTitle:@"Done" 
         otherButtonTitles:nil];
         
         [alert show];
         [alert release];
         [self moveOptionsViewOffScreen];
         }
         }
         */
		if (buttonIndex == 0) 
		{
			
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
			{
				NSLog(@"Choosing to take a picture");
				
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				picker.sourceType				= UIImagePickerControllerSourceTypeCamera;
				picker.cameraDevice				= UIImagePickerControllerCameraCaptureModePhoto;
                //				picker.allowsEditing			= YES;
				picker.videoQuality				= UIImagePickerControllerQualityType640x480;
				
				picker.delegate					= self;
				
				[self presentModalViewController:picker animated:YES];
				
				NSLog(@"\n\n");
			}
			else 
			{
				NSLog(@"Oops! No camera available");
				UIAlertView *alert = [[UIAlertView alloc] 
									  initWithTitle:@"No camera available." 
									  message:nil 
									  delegate:nil 
									  cancelButtonTitle:@"Done" 
									  otherButtonTitles:nil];
				
				[alert show];
//				[self moveOptionsViewOffScreen];
			}
		}
		
		else if (buttonIndex == 1) 
		{
			NSLog(@"Choosing from the photo library.");
			
			if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) 
			{
				UIImagePickerController *picker	= [[UIImagePickerController alloc] init];
				picker.sourceType				= UIImagePickerControllerSourceTypePhotoLibrary;
				picker.delegate					= self;
				
				// Picker is displayed asynchronously.
				[self presentModalViewController:picker animated:YES];
				
				NSLog(@"\n\n");
			} 		
			
			else 
			{
				UIAlertView *alert = [[UIAlertView alloc] 
									  initWithTitle:@"No photos in your image library." 
									  message:nil 
									  delegate:nil 
									  cancelButtonTitle:@"Done" 
									  otherButtonTitles:nil];
				
				[alert show];
				
			}
		}
	}	
}



- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
	NSLog(@"\n\n-imagePickerController:didFinishPickingMediaWithInfo:");
	
	// If the camera exists, use it. Otherwise, use the images already available on the device
	UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	UIImage *editedImage = [info valueForKey:UIImagePickerControllerEditedImage];
	
	// 
	// Clean-out newImage
	//
	UIImage *newImage = nil;
	
	if (editedImage) 
	{
		newImage = editedImage;
		NSLog(@"newImage just assigned as editedImage.");
	}
	else
	{
		newImage = originalImage;
		NSLog(@"newImage just assigned as originalImage.");
	}
    
    NSLog(@"image orientation = %u", newImage.imageOrientation);
    NSLog(@"newImage size = %f, %f", newImage.size.width, newImage.size.height);
	
    self.worldMapImage = newImage;

    //[self setNewImage:self.worldMapImage inImageView:self.worldMapImageView];
	

	[[picker parentViewController] dismissModalViewControllerAnimated:YES];	
	
	
	//	NSLog(@"finished image picker dismiss\n\n");
	NSLog(@"\n\n");
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker 
{
	NSLog(@"-imagePickerControllerDidCancel:");
	
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
	
	NSLog(@"\n\n");
}



@end
