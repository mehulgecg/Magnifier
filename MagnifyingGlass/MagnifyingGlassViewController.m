//
//  MainViewController.m
//  KrazyKim
//
//  Created by James Hillhouse on 5/13/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import "MagnifyingGlassViewController.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>



//static CGFloat    kMinReticleSize       =  60.0; // Smallest reticle
//static CGFloat    kMaxReticleSize       = 160.0; // Largest reticle size



@interface MagnifyingGlassViewController () 

// MagnifyingGlass Private Methods
- (void)resizeMagnifyingGlass;


- (CGRect)rectFromImage:(UIImage *)anImage inView:(UIView *)aView;

// Image and CGImageRef Methods
- (void)renderView:(UIView*)aView inContext:(CGContextRef)context;

// Gesture Recognizers
- (void)createGestureRecognizers;
- (void)handleDoubleTapFromGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer;
- (void)handlePanFromGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)handleResizeFromGestureRecognizer:(UIRotationGestureRecognizer *)gestureRecognizer;
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

@synthesize magnifyingGlassView         = _magnifyingGlassView;
@synthesize magnifyingGlassDiameter;
@synthesize maxMagnifyingGlassDiameter;
@synthesize minMagnifyingGlassDiameter;
@synthesize magnifyingGlassZoom;
@synthesize magnifyingGlassScale;
@synthesize magnifyingGlassLabel;

@synthesize tapRecognizer;
@synthesize panRecognizer;
@synthesize pinchRecognizer;
@synthesize rotationRecognizer;



#pragma mark - View Controller Methods

- (void)dealloc
{
    [_managedObjectContext release];
    
    [_worldMapImageView release];
    [_worldMapImage release];
    [_worldMapView release];
    
    [_magnifyingGlassView release];
    
    [tapRecognizer release];
    [panRecognizer release];
    [pinchRecognizer release];
    [rotationRecognizer release];
    
    [magnifyingGlassLabel release];
    [super dealloc];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.worldMapImage = [UIImage imageNamed:@"KrazyKimWarMap.png"];
    self.worldMapImageView.image = self.worldMapImage;
    
    
    //
    // Reticle ivars
    //
    self.maxMagnifyingGlassDiameter = [[UIScreen mainScreen] bounds].size.width - 100.0;
    self.minMagnifyingGlassDiameter = [[UIScreen mainScreen] bounds].size.width - 220.0;
    self.magnifyingGlassDiameter    = self.minMagnifyingGlassDiameter;
    
    self.magnifyingGlassZoom    =   1.0;
    self.magnifyingGlassScale   =   1.0;
    self.magnifyingGlassLabel.alpha = 0.0;
    
   
    //
    // Create the Gesture Recognizers
    //
    [self createGestureRecognizers];
    
    [self setNewImage:[UIImage imageWithCGImage:[UIImage imageNamed:@"NASA_Leaders_Tesla_Testdrive_1024.jpg"].CGImage scale:[[UIScreen mainScreen]scale] orientation:UIImageOrientationUp] inImageView:self.worldMapImageView];
    
    [self updateMagnifyingGlass];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}



- (void)viewDidUnload
{
    [_worldMapView release];
    self.worldMapView   = nil;
    
    [_worldMapImageView release];
    self.worldMapImageView  = nil;
    
    [_worldMapImage release];
    self.worldMapImage  = nil;
    
    self.magnifyingGlassView    = nil;

    [self setMagnifyingGlassLabel:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (IBAction)setNewImage:(UIImage *)anImage inImageView:(UIImageView *)anImageView
{
    NSLog(@"\n\n\n\n-setNewImage");

    CGSize imageSize = CGSizeMake(anImage.size.width, anImage.size.height);
        
    self.xScale = anImageView.frame.size.width / imageSize.width;
    self.yScale = anImageView.frame.size.height / imageSize.height;
    
    //
    // Code to move the world map image around
    //
//    CGFloat xTranslation = 0.0;
//    CGFloat yTranslation = 0.0;
    
    
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
    
    
    NSLog(@"self.worldMapImageView.size = %f, %f", self.worldMapImageView.frame.size.width, self.worldMapImageView.frame.size.height);
    NSLog(@"imageSize = (%f, %f)", imageSize.width, imageSize.height);
    NSLog(@"xScale, yScale = (%f, %f)", self.xScale, self.yScale);
    NSLog(@"anImage size = %f, %f", anImage.size.width, anImage.size.height);
    NSLog(@"newImageRect = %f, %f, %f, %f", newImageRect.origin.x, newImageRect.origin.y, newImageRect.size.width, newImageRect.size.height);
    NSLog(@"self.worldMapImage Size = %f, %f", self.worldMapImage.size.width, self.worldMapImage.size.height);
    NSLog(@"self.worldImageView Image Size = %f, %f", self.worldMapImageView.image.size.width, self.worldMapImageView.image.size.height);
    NSLog(@"self.worldImageView Rect = %f, %f, %f, %f", self.worldMapImageView.frame.origin.x, self.worldMapImageView.frame.origin.y, self.worldMapImageView.frame.size.width, self.worldMapImageView.frame.size.height);
    NSLog(@"self.worldMapView Rect = %f, %f, %f, %f\n\n", self.worldMapView.frame.origin.x, self.worldMapView.frame.origin.y, self.worldMapView.frame.size.width, self.worldMapView.frame.size.height);
}



# pragma mark MagnifyingGlass Methods
- (IBAction)updateMagnifyingGlass
{
    NSLog(@"-updateReticle");
    
//    CGPoint newReticleOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassView.bounds.size.width / 2.0 ) / self.magnifyingGlassZoom, 
//                                           self.magnifyingGlassView.center.y - ( self.magnifyingGlassView.bounds.size.height / 2.0 ) / self.magnifyingGlassZoom );

//    CGSize newReticleSize = CGSizeMake(self.magnifyingGlassView.frame.size.width / self.magnifyingGlassZoom, 
//                                       self.magnifyingGlassView.frame.size.height / self.magnifyingGlassZoom);
    
    
    CGPoint newReticleOrigin;
    CGSize newReticleSize;
    
    if (self.magnifyingGlassZoom >= 1.0 && self.magnifyingGlassZoom <= 3.0) 
    {
        newReticleOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassView.bounds.size.width / 2.0 ) / self.magnifyingGlassZoom, 
                                               self.magnifyingGlassView.center.y - ( self.magnifyingGlassView.bounds.size.height / 2.0 ) / self.magnifyingGlassZoom );
        
        newReticleSize = CGSizeMake(self.magnifyingGlassView.frame.size.width / self.magnifyingGlassZoom, 
                                           self.magnifyingGlassView.frame.size.height / self.magnifyingGlassZoom);
    }        

    if (self.magnifyingGlassZoom < 1.0) 
    {
        self.magnifyingGlassZoom = 1.0;
        
        newReticleOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassView.bounds.size.width / 2.0 ) / self.magnifyingGlassZoom, 
                                               self.magnifyingGlassView.center.y - ( self.magnifyingGlassView.bounds.size.height / 2.0 ) / self.magnifyingGlassZoom );
        
        newReticleSize = CGSizeMake(self.magnifyingGlassView.frame.size.width / self.magnifyingGlassZoom, 
                                           self.magnifyingGlassView.frame.size.height / self.magnifyingGlassZoom);
    }
    
    if (self.magnifyingGlassZoom > 3.0) 
    {
        self.magnifyingGlassZoom = 3.0;
        
        newReticleOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassView.bounds.size.width / 2.0 ) / self.magnifyingGlassZoom, 
                                       self.magnifyingGlassView.center.y - ( self.magnifyingGlassView.bounds.size.height / 2.0 ) / self.magnifyingGlassZoom );
        
        newReticleSize = CGSizeMake(self.magnifyingGlassView.frame.size.width / self.magnifyingGlassZoom, 
                                    self.magnifyingGlassView.frame.size.height / self.magnifyingGlassZoom);
    }

    CGFloat screenScale = [[UIScreen mainScreen] scale];
    
    newReticleOrigin.x *= screenScale;
    newReticleOrigin.y *= screenScale;
    newReticleSize.width *= screenScale;
    newReticleSize.height *= screenScale;

    
    
    CGRect magnifiedImageFrame = CGRectMake( newReticleOrigin.x, newReticleOrigin.y, newReticleSize.width, newReticleSize.height );
    
    
    //
    // It bears reminding that CGImageCreateWithImageInRect(CGImageRef, CGRect) creates a subimage from the larger CGImageRef in the 
    // CGRect. This method is specifically NOT for scaling an image; use drawInRect:(CGRect) for (one way at least) scaling.
    //
    CGImageRef reticleImageRef = CGImageCreateWithImageInRect( self.worldMapImage.CGImage, magnifiedImageFrame );
    
    
    self.magnifyingGlassView.layer.contents = (id)reticleImageRef;
    self.magnifyingGlassView.layer.borderWidth = 5.0;
    self.magnifyingGlassView.layer.borderColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] CGColor];
    self.magnifyingGlassView.layer.cornerRadius = self.magnifyingGlassView.frame.size.width / 2.0;
     

    NSLog(@"magnifying origin = (%f, %f)", magnifiedImageFrame.origin.x, magnifiedImageFrame.origin.y);
    NSLog(@"magnifying size = (%f, %f)", magnifiedImageFrame.size.width, magnifiedImageFrame.size.height);
    NSLog(@"reticle position = %f, %f", self.magnifyingGlassView.layer.position.x, self.magnifyingGlassView.layer.position.y);
    NSLog(@"reticle frame origin = (%f, %f)", self.magnifyingGlassView.frame.origin.x, self.magnifyingGlassView.frame.origin.y);
    NSLog(@"reticle center = (%f, %f)\n\n\n", self.magnifyingGlassView.center.x, self.magnifyingGlassView.center.y);
    
    CGImageRelease(reticleImageRef);
}



- (void)resizeMagnifyingGlass
{
    NSLog(@"\n\nResizing reticle");
    
    CGPoint newMagnifyingGlassViewOrigin = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassDiameter / 2.0 ), 
                                                       self.magnifyingGlassView.center.y - ( self.magnifyingGlassDiameter / 2.0 ));
    
    CGSize newMagnifyingGlassViewSize = CGSizeMake(self.magnifyingGlassDiameter, 
                                                   self.magnifyingGlassDiameter);
    
    NSLog(@"magnifyingGlassDiameter = %f", self.magnifyingGlassDiameter);
    
    if (self.magnifyingGlassView.frame.size.width >= self.minMagnifyingGlassDiameter && self.magnifyingGlassView.frame.size.width <= self.maxMagnifyingGlassDiameter) 
    {
        NSLog(@"reticle.frame.size.width = %f", self.magnifyingGlassView.frame.size.width);
        NSLog(@"reticle just got resized...");
        self.magnifyingGlassView.frame = CGRectMake(newMagnifyingGlassViewOrigin.x, newMagnifyingGlassViewOrigin.y, newMagnifyingGlassViewSize.width, newMagnifyingGlassViewSize.height);
    }   
    
    if (self.magnifyingGlassView.frame.size.width < self.minMagnifyingGlassDiameter) 
    {
        NSLog(@"reticle too small-resizing");
        CGSize minReticleSize       = CGSizeMake(self.minMagnifyingGlassDiameter, self.minMagnifyingGlassDiameter);
        CGPoint minReticleOrigin    = CGPointMake(self.magnifyingGlassView.center.x - self.minMagnifyingGlassDiameter / 2.0, 
                                                  self.magnifyingGlassView.center.y - self.minMagnifyingGlassDiameter / 2.0);
        self.magnifyingGlassView.frame      = CGRectMake(minReticleOrigin.x, minReticleOrigin.y, minReticleSize.width, minReticleSize.height);
    }
    
    if (self.magnifyingGlassView.frame.size.width > self.maxMagnifyingGlassDiameter) 
    {
        NSLog(@"reticle too large-resizing");
        CGSize maxReticleSize       = CGSizeMake(self.maxMagnifyingGlassDiameter, self.maxMagnifyingGlassDiameter);
        CGPoint maxReticleOrigin    = CGPointMake(self.magnifyingGlassView.center.x - self.maxMagnifyingGlassDiameter / 2.0,
                                                  self.magnifyingGlassView.center.y - self.maxMagnifyingGlassDiameter / 2.0);
        self.magnifyingGlassView.frame      = CGRectMake(maxReticleOrigin.x, maxReticleOrigin.y, maxReticleSize.width, maxReticleSize.height);
    }
    [self updateMagnifyingGlass];

}



#pragma mark -
#pragma mark Other Methods

- (CGRect)rectFromImage:(UIImage *)anImage inView:(UIView *)aView
{
    //CGFloat menubarUIOffset = 0.0;
    //	CGFloat	tabbarUIOffset = 44.0;
    
	CGRect imageRect;
	
	////////////////////////////////////////////////////
	//
	// Image ratio
	//
	////////////////////////////////////////////////////
    
    NSLog(@"\n\n");
    NSLog(@"Resizing Rect for viewSize = %f, %f", aView.frame.size.width, aView.frame.size.height);
	
	CGFloat imageResizedWidth;
	CGFloat imageResizedHeight;
	CGFloat imageScaleWidth     = aView.frame.size.width / anImage.size.width;
	CGFloat imageScaleHeight    = aView.frame.size.height / anImage.size.height;
	
	if (anImage.size.width > anImage.size.height) // Landscape
	{
		// NSLog(@"Landscape");
		imageResizedWidth       = floorf( anImage.size.width * imageScaleHeight );
		imageResizedHeight      = floorf( anImage.size.height * imageScaleHeight );
	}
	else // Portrait or Square
	{
		// NSLog(@"Portrait");
		imageResizedWidth       = floorf( anImage.size.width * imageScaleWidth );
		imageResizedHeight      = floorf( anImage.size.height * imageScaleWidth );
	}
    
	imageRect            = CGRectMake(aView.center.x - imageResizedWidth / 2.0, // origin.x
                                      aView.center.y - imageResizedHeight / 2.0, // origin.y
                                      imageResizedWidth, // width
                                      imageResizedHeight); // height
    
    //NSLog(@"resized imageRect = %f, %f, %f, %f", imageRect.origin.x, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
    //NSLog(@"\n\n");
    
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
	
	gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFromGestureRecognizer:)];
	[self.worldMapView addGestureRecognizer:gestureRecognizer];
	self.tapRecognizer                      = (UITapGestureRecognizer *)gestureRecognizer;
	self.tapRecognizer.numberOfTapsRequired = 2;
	self.tapRecognizer.delegate             = self;
	[gestureRecognizer release];
	
	// Pan Gesture (for rotation and tilt)
	gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFromGestureRecognizer:)];
	self.panRecognizer                      = (UIPanGestureRecognizer *)gestureRecognizer;
	[self.magnifyingGlassView addGestureRecognizer:panRecognizer];
	panRecognizer.delegate                  = self;
	[gestureRecognizer release];
	
	// Pinch Gesture (for zoom)
	gestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomFromGestureRecognizer:)];
	self.pinchRecognizer                    = (UIPinchGestureRecognizer *)gestureRecognizer;
	[self.view addGestureRecognizer:pinchRecognizer];
	pinchRecognizer.delegate                = self;
	[gestureRecognizer release];
	
	// Rotation Gesture (for increasing reticle size)
    gestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizeFromGestureRecognizer:)];
    self.rotationRecognizer                 = (UIRotationGestureRecognizer *)gestureRecognizer;
    [self.view addGestureRecognizer:rotationRecognizer];
    rotationRecognizer.delegate             = self;
    [gestureRecognizer release];
}



- (void)handleDoubleTapFromGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.magnifyingGlassView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.magnifyingGlassView.layer.position = CGPointMake(160, 100.0);


    }completion:^( BOOL finished )
     { 
         self.magnifyingGlassView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [self updateMagnifyingGlass];
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
	

    CGFloat tempZoom = self.magnifyingGlassZoom;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.magnifyingGlassView.transform = CGAffineTransformMakeScale(1.25, 1.25);

            [self updateMagnifyingGlass];
        }];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) 
    {
        self.magnifyingGlassView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        
        [self.magnifyingGlassView setCenter:CGPointMake(self.magnifyingGlassView.center.x + translation.x, self.magnifyingGlassView.center.y + translation.y)];
        
        [gestureRecognizer setTranslation:CGPointZero inView:[self.magnifyingGlassView superview]];
        
        [self updateMagnifyingGlass];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) 
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.magnifyingGlassZoom = tempZoom;
            self.magnifyingGlassView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [self updateMagnifyingGlass];
        }];
    }
}



- (void)handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer
{
    //
    // This sets the spacing between layers.
    //
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifyingGlassLabel.alpha = 1.0;
        }];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) 
    {
        NSLog(@"\n\n\nZoom Scale = %f", gestureRecognizer.scale);
        
        self.magnifyingGlassZoom = gestureRecognizer.scale * 1.75;
        
        
//        if ( self.magnifyingGlassZoom >= 1.0 ) 
//        {
//            self.magnifyingGlassZoom = tempScale;
//        }
//        
//        if ( self.magnifyingGlassZoom < 1.0 ) 
//        {
//            self.magnifyingGlassZoom = 1.0;
//        }
//        
//        if ( self.magnifyingGlassZoom > 3.0 ) 
//        {
//            self.magnifyingGlassZoom = 3.0;
//        }
        
        NSString *zoomString = [NSString stringWithFormat:@"%2.1f", self.magnifyingGlassZoom];
        zoomString = [zoomString stringByAppendingString:@"X"];
        self.magnifyingGlassLabel.text = zoomString;
        
        [self updateMagnifyingGlass];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) 
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.magnifyingGlassLabel.alpha = 0.0;
        }];
    }
} 



- (void)handleResizeFromGestureRecognizer:(UIRotationGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) 
    {
        CGFloat reticleScaleIncrement   = [gestureRecognizer rotation] * 180.0 / M_PI;
        
        
        //
        // This resizes the diameter of the magnifying glass
        //
        self.magnifyingGlassDiameter += ( reticleScaleIncrement / 10.0 );
        [self resizeMagnifyingGlass];
         
        
        NSLog(@"reticleScaleIncrement = %f", reticleScaleIncrement);
        NSLog(@"resulting reticleDiameter = %f\n\n", self.magnifyingGlassDiameter);
        
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) 
    {
        [gestureRecognizer setRotation:0.0];
    }
}



# pragma mark Alerts

- (void) userJustDoubleTapped:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You just double tapped :-)"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}






# pragma mark UtilityViewController Delegate Methods

- (void)infoViewControllerDidFinish:(InfoViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}



- (IBAction)showInfo:(id)sender
{    
    InfoViewController *controller = [[InfoViewController alloc] initWithNibName:@"InfoView" bundle:nil];
    controller.delegate = self;
    
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}



@end
