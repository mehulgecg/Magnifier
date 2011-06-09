//
//  MainViewController.m
//  KrazyKim
//
//  Created by James Hillhouse on 5/13/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import "MagnifyingGlassViewController.h"

#import "MagnifyingGlass.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>



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



#pragma mark - View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Create the Gesture Recognizers
    //
    [self createGestureRecognizers];
    
    
    //
    // Set the main background image
    //
    self.worldMapImageView.image = [UIImage imageNamed:@"Mercury-First_Color_Image"];
    [self setNewImage:[UIImage imageWithCGImage:[UIImage imageNamed:@"Mercury-First_Color_Image.png"].CGImage scale:[[UIScreen mainScreen]scale] orientation:UIImageOrientationUp] inImageView:self.worldMapImageView];
        
    self.magnifier = [[MagnifyingGlass alloc] init];
    
    [self.magnifier createMagnifyingGlassWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.magnifier.magnifyingGlassView =  self.magnifierView;
    self.magnifier.magnifyingGlassLabel = self.magnifierLabel;
    self.magnifier.magnifyingGlassImage = self.worldMapImage;
    self.magnifierLabel.alpha = 0.0;
    self.magnifierView.backgroundColor = [UIColor clearColor];
    
    [self.magnifier updateMagnifyingGlass];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



- (void)viewDidUnload
{
    self.worldMapView   = nil;
    
    self.worldMapImageView  = nil;
    
    self.worldMapImage  = nil;
    
    self.magnifierView    = nil;
    
    [self.magnifier setMagnifyingGlassLabel:nil];
    [super viewDidUnload];
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
    
    CGSize imageSize = CGSizeMake(anImage.size.width, anImage.size.height);
    
    self.xScale = anImageView.frame.size.width / imageSize.width;
    self.yScale = anImageView.frame.size.height / imageSize.height;
    
    
    //
    // Recalculate the image size based on the scale of the image / image view
    //
    CGSize newImageSize = CGSizeMake(imageSize.width * self.xScale, imageSize.height * self.yScale);
    
    
    CGRect newImageRect = [self rectFromImage:anImage inView:self.worldMapImageView];
    
    NSLog(@"newImageRect size = (%f, %f)", newImageRect.size.width, newImageRect.size.height);
    
    
    //
    // Start by capturing the whole image
    //
    UIGraphicsBeginImageContextWithOptions(newImageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //
    // This is where the image is rescaled to a scaled rect.
    //
    UIGraphicsPushContext(context);
    [anImage drawInRect:newImageRect];
    UIGraphicsPopContext();
    
    
    //
    // Retrieve the screenshot image containing both the camera content and the overlay view
    //
    //    self.worldMapImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    self.worldMapImage = UIGraphicsGetImageFromCurrentImageContext();
    self.worldMapImageView.image = self.worldMapImage;
    
    UIGraphicsEndImageContext();
}



# pragma mark - MagnifyingGlass Methods
/*
 - (IBAction)updateMagnifyingGlass
 {
 NSLog(@"-updateMagnifyingGlass");
 
 
 CGPoint newMagnifyingGlassOrigin;
 CGSize newMagnifyingGlassSize;
 
 
 //
 // This chunk of code handles resizing of the magnifying glass.
 //
 {
 NSLog(@"\n\n\n\n\n Resizing the magnifying glass");
 NSLog(@"magnifying glass initial diameter = %f", self.magnifyingGlassDiameter);
 //
 // Change the magnifying glass diameter while checking to ensure it doesn't exceed min or max dimensions
 //
 if (self.magnifyingGlassDiameter >= self.minMagnifyingGlassDiameter && self.magnifyingGlassDiameter <= self.maxMagnifyingGlassDiameter) 
 {
 NSLog(@"magnifying glass not too big nor too small");
 newMagnifyingGlassOrigin    = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassDiameter / 2.0 ), 
 self.magnifyingGlassView.center.y - ( self.magnifyingGlassDiameter / 2.0 ));
 
 newMagnifyingGlassSize      = CGSizeMake(self.magnifyingGlassDiameter, 
 self.magnifyingGlassDiameter);
 }   
 
 if (self.magnifyingGlassDiameter < self.minMagnifyingGlassDiameter) 
 {
 NSLog(@"magnifying glass too small");
 self.magnifyingGlassDiameter = self.minMagnifyingGlassDiameter;
 
 newMagnifyingGlassOrigin    = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassDiameter / 2.0 ), 
 self.magnifyingGlassView.center.y - ( self.magnifyingGlassDiameter / 2.0 ));
 
 newMagnifyingGlassSize      = CGSizeMake(self.magnifyingGlassDiameter, 
 self.magnifyingGlassDiameter);
 }
 
 if (self.magnifyingGlassDiameter > self.maxMagnifyingGlassDiameter) 
 {
 NSLog(@"magnifying glass too big");
 self.magnifyingGlassDiameter = self.maxMagnifyingGlassDiameter;
 
 newMagnifyingGlassOrigin    = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassDiameter / 2.0 ),
 self.magnifyingGlassView.center.y - ( self.magnifyingGlassDiameter / 2.0 ));
 
 newMagnifyingGlassSize      = CGSizeMake(self.magnifyingGlassDiameter, 
 self.magnifyingGlassDiameter);
 }
 NSLog(@"magnifying glass diameter = %f", self.magnifyingGlassDiameter);
 
 
 
 NSLog(@"magnifyingGlassDiameter = %f\n\n\n\n\n", self.magnifyingGlassDiameter);
 
 self.magnifyingGlassView.frame = CGRectMake(newMagnifyingGlassOrigin.x, 
 newMagnifyingGlassOrigin.y, 
 newMagnifyingGlassSize.width, 
 newMagnifyingGlassSize.height);
 }    
 
 
 
 //
 // This chunk of code handles zooming of the magnifying glass
 //
 {
 if (self.magnifyingGlassZoom >= 1.0 && self.magnifyingGlassZoom <= 3.0) 
 {
 newMagnifyingGlassOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassView.bounds.size.width / 2.0 ) / self.magnifyingGlassZoom, 
 self.magnifyingGlassView.center.y - ( self.magnifyingGlassView.bounds.size.height / 2.0 ) / self.magnifyingGlassZoom );
 
 newMagnifyingGlassSize = CGSizeMake(self.magnifyingGlassView.frame.size.width / self.magnifyingGlassZoom, 
 self.magnifyingGlassView.frame.size.height / self.magnifyingGlassZoom);
 }        
 
 if (self.magnifyingGlassZoom < 1.0) 
 {
 self.magnifyingGlassZoom = 1.0;
 
 newMagnifyingGlassOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassView.bounds.size.width / 2.0 ) / self.magnifyingGlassZoom, 
 self.magnifyingGlassView.center.y - ( self.magnifyingGlassView.bounds.size.height / 2.0 ) / self.magnifyingGlassZoom );
 
 newMagnifyingGlassSize = CGSizeMake(self.magnifyingGlassView.frame.size.width / self.magnifyingGlassZoom, 
 self.magnifyingGlassView.frame.size.height / self.magnifyingGlassZoom);
 }
 
 if (self.magnifyingGlassZoom > 3.0) 
 {
 self.magnifyingGlassZoom = 3.0;
 
 newMagnifyingGlassOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassView.bounds.size.width / 2.0 ) / self.magnifyingGlassZoom, 
 self.magnifyingGlassView.center.y - ( self.magnifyingGlassView.bounds.size.height / 2.0 ) / self.magnifyingGlassZoom );
 
 newMagnifyingGlassSize = CGSizeMake(self.magnifyingGlassView.frame.size.width / self.magnifyingGlassZoom, 
 self.magnifyingGlassView.frame.size.height / self.magnifyingGlassZoom);
 }
 
 CGFloat screenScale = [[UIScreen mainScreen] scale];
 
 
 newMagnifyingGlassOrigin.x *= screenScale;
 newMagnifyingGlassOrigin.y *= screenScale;
 newMagnifyingGlassSize.width *= screenScale;
 newMagnifyingGlassSize.height *= screenScale;
 
 
 CGRect magnifiedImageFrame = CGRectMake( newMagnifyingGlassOrigin.x, newMagnifyingGlassOrigin.y, newMagnifyingGlassSize.width, newMagnifyingGlassSize.height );
 
 
 //
 // It bears reminding that CGImageCreateWithImageInRect(CGImageRef, CGRect) creates a subimage from the larger CGImageRef in the 
 // CGRect. This method is specifically NOT for scaling an image; use drawInRect:(CGRect) for (one way at least) scaling.
 //
 CGImageRef magnifyingGlassImageRef = CGImageCreateWithImageInRect( self.worldMapImage.CGImage, magnifiedImageFrame );
 
 self.magnifyingGlassView.layer.contents = objc_unretainedObject(magnifyingGlassImageRef);
 self.magnifyingGlassView.layer.borderWidth = 4.0;
 self.magnifyingGlassView.layer.cornerRadius = self.magnifyingGlassView.frame.size.width / 2.0;
 
 CGImageRelease(magnifyingGlassImageRef);
 }
 }
 
 
 
 - (void)updateMagnifyingGlassForZoom
 {
 [self updateMagnifyingGlassLabelForZoom];
 [self updateMagnifyingGlass];
 }
 
 
 
 - (void)updateMagnifyingGlassForDiameter
 {
 [self updateMagnifyingGlassLabelForDiameter];
 [self updateMagnifyingGlass];
 }
 
 
 
 - (void)updateMagnifyingGlassLabelForZoom
 {
 //
 // Update the magnifying glass label to reflect the new magnification zoom
 //
 NSString *zoomString = [NSString stringWithFormat:@"%2.1f", self.magnifyingGlassZoom];
 zoomString = [zoomString stringByAppendingString:@"X"];
 self.magnifyingGlassLabel.text = zoomString;
 }
 
 
 
 - (void)updateMagnifyingGlassLabelForDiameter
 {
 //
 // Update the magnifying glass label to reflect the new magnification zoom
 //
 NSString *diameterString = [NSString stringWithFormat:@"%2.0f", self.magnifyingGlassDiameter];
 diameterString = [diameterString stringByAppendingString:@" pts"];
 self.magnifyingGlassLabel.text = diameterString;    
 }
 */


#pragma mark -
#pragma mark Other Methods

- (CGRect)rectFromImage:(UIImage *)anImage inView:(UIView *)aView
{
	CGRect imageRect;
	
	////////////////////////////////////////////////////
	//
	// Image ratio
	//
	////////////////////////////////////////////////////
    
    NSLog(@"\n\n");
    NSLog(@"Image size = %f, %f", anImage.size.width, anImage.size.height);
    NSLog(@"Resizing Rect for view with size = %f, %f", aView.frame.size.width, aView.frame.size.height);
    
	
	CGFloat imageResizedWidth;
	CGFloat imageResizedHeight;
	CGFloat imageScaleWidth     = aView.frame.size.width / anImage.size.width;
	CGFloat imageScaleHeight    = aView.frame.size.height / anImage.size.height;
    
    NSLog(@"scaled width and height = %f, %f", imageScaleWidth, imageScaleHeight);
	
	if (anImage.size.width >= anImage.size.height) // Landscape
	{
		NSLog(@"Landscape");
		imageResizedWidth       = floorf( anImage.size.width * imageScaleHeight );
		imageResizedHeight      = floorf( anImage.size.height * imageScaleHeight );
	}
    
	else if (anImage.size.height >= anImage.size.width) // Landscape
	{
		NSLog(@"Landscape");
		imageResizedWidth       = floorf( anImage.size.width * imageScaleWidth );
		imageResizedHeight      = floorf( anImage.size.height * imageScaleWidth );
	}
    
	else // Square
	{
		NSLog(@"Square");
		imageResizedWidth       = floorf( anImage.size.width * imageScaleWidth );
		imageResizedHeight      = floorf( anImage.size.height * imageScaleHeight );
	}
    
	imageRect            = CGRectMake(aView.center.x - imageResizedWidth / 2.0, // origin.x
                                      aView.center.y - imageResizedHeight / 2.0, // origin.y
                                      imageResizedWidth, // width
                                      imageResizedHeight); // height
    
    NSLog(@"resized imageRect = %f, %f, %f, %f", imageRect.origin.x, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
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



/*
 - (void)drawView
 {
 NSLog(@"-drawView");
 
 CGRect worldRect = CGRectMake(200.0, 200.0, self.worldMapImage.size.width, self.worldMapImage.size.height);
 
 // Drawing code
 CGImageRef image = CGImageRetain(_worldMapImage.CGImage);
 
 CGRect imageRect;
 imageRect.origin = CGPointMake(0.0, 0.0);
 imageRect.size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
 
 CGContextRef context = UIGraphicsGetCurrentContext();       
 CGContextClipToRect(context, CGRectMake(0.0, 0.0, worldRect.size.width, worldRect.size.height));      
 CGContextDrawTiledImage(context, imageRect, image);
 CGImageRelease(image);
 
 [self.worldMapImageView.layer renderInContext:context];
 }
 */





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
	[self.worldMapView addGestureRecognizer:gestureRecognizer];
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
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.magnifierView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.magnifierView.layer.position = CGPointMake(160, 230.0);
        
        
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
        NSLog(@"\n\n\nZoom Scale = %f", gestureRecognizer.scale);
        
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
        
        
        NSLog(@"reticleScaleIncrement = %f", reticleScaleIncrement);
        NSLog(@"resulting reticleDiameter = %f\n\n", self.magnifier.magnifyingGlassDiameter);
        
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
        
        
        NSLog(@"magnifyingGlassResizeIncrement = %f", magnifyingGlassResizeIncrement);
        NSLog(@"resulting magnifyingGlassDiameter = %f\n\n", self.magnifier.magnifyingGlassDiameter);
        
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



@end
