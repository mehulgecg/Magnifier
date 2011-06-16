//
//  MagnifyingGlass.m
//  MagnifyingGlass
//
//  Created by Jim Hillhouse on 6/8/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import "MagnifyingGlass.h"



#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>



@interface MagnifyingGlass () 

// MagnifyingGlass Private Methods
//- (void)updateMagnifyingGlass;
//- (void)updateMagnifyingGlassForZoom;
//- (void)updateMagnifyingGlassForDiameter;
//- (void)updateMagnifyingGlassLabelForZoom;
//- (void)updateMagnifyingGlassLabelForDiameter;

//- (void)createMagnifyingGlassWithFrame:(CGRect)frame;
//- (CGRect)rectFromImage:(UIImage *)anImage inView:(UIView *)aView;
@end




@implementation MagnifyingGlass



@synthesize magnifyingGlassView;
@synthesize magnifyingGlassLabel;
@synthesize magnifyingGlassImage;

@synthesize magnifyingGlassDiameter;
@synthesize maxMagnifyingGlassDiameter;
@synthesize minMagnifyingGlassDiameter;
@synthesize magnifyingGlassZoom;
@synthesize magnifyingGlassScale;




- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)createMagnifyingGlassWithFrame:(CGRect)frame
{
    
    
    //
    // MagnifyingGlass Settings
    //
    self.maxMagnifyingGlassDiameter = frame.size.width * 0.7;
    self.minMagnifyingGlassDiameter = frame.size.width * 0.3;
    self.magnifyingGlassDiameter    = self.minMagnifyingGlassDiameter;
    
    self.magnifyingGlassView.layer.borderColor = [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] CGColor];
    
    self.magnifyingGlassZoom    =   1.0;
    self.magnifyingGlassScale   =   1.0;
    self.magnifyingGlassLabel.alpha = 0.0;
    
    self.magnifyingGlassView.center = CGPointMake(100.0, 100.0);
    
    [self updateMagnifyingGlass];
}



# pragma mark - MagnifyingGlass Methods
- (void)updateMagnifyingGlass
{
    //NSLog(@"-updateMagnifyingGlass");
    
    
    CGPoint newMagnifyingGlassOrigin;
    CGSize newMagnifyingGlassSize;
    
    
    //
    // This chunk of code handles resizing of the magnifying glass.
    //
    //{
        //NSLog(@"\n\n\n\n\n Resizing the magnifying glass");
        //NSLog(@"magnifying glass initial diameter = %f", self.magnifyingGlassDiameter);
        //
        // Change the magnifying glass diameter while checking to ensure it doesn't exceed min or max dimensions
        //
        if (self.magnifyingGlassDiameter >= self.minMagnifyingGlassDiameter && self.magnifyingGlassDiameter <= self.maxMagnifyingGlassDiameter) 
        {
            //NSLog(@"magnifying glass not too big nor too small");
            newMagnifyingGlassOrigin    = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassDiameter / 2.0 ), 
                                                      self.magnifyingGlassView.center.y - ( self.magnifyingGlassDiameter / 2.0 ));
            
            newMagnifyingGlassSize      = CGSizeMake(self.magnifyingGlassDiameter, 
                                                     self.magnifyingGlassDiameter);
        }   
        
        if (self.magnifyingGlassDiameter < self.minMagnifyingGlassDiameter) 
        {
            //NSLog(@"magnifying glass too small");
            self.magnifyingGlassDiameter = self.minMagnifyingGlassDiameter;
            
            newMagnifyingGlassOrigin    = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassDiameter / 2.0 ), 
                                                      self.magnifyingGlassView.center.y - ( self.magnifyingGlassDiameter / 2.0 ));
            
            newMagnifyingGlassSize      = CGSizeMake(self.magnifyingGlassDiameter, 
                                                     self.magnifyingGlassDiameter);
        }
        
        if (self.magnifyingGlassDiameter > self.maxMagnifyingGlassDiameter) 
        {
            //NSLog(@"magnifying glass too big");
            self.magnifyingGlassDiameter = self.maxMagnifyingGlassDiameter;
            
            newMagnifyingGlassOrigin    = CGPointMake(self.magnifyingGlassView.center.x - ( self.magnifyingGlassDiameter / 2.0 ),
                                                      self.magnifyingGlassView.center.y - ( self.magnifyingGlassDiameter / 2.0 ));
            
            newMagnifyingGlassSize      = CGSizeMake(self.magnifyingGlassDiameter, 
                                                     self.magnifyingGlassDiameter);
        }
        //NSLog(@"magnifying glass diameter = %f", self.magnifyingGlassDiameter);
        
        
        
        //NSLog(@"magnifyingGlassDiameter = %f\n\n\n\n\n", self.magnifyingGlassDiameter);
        
        CGRect newMagnifyingGlassViewRect = CGRectMake(newMagnifyingGlassOrigin.x, 
                                                       newMagnifyingGlassOrigin.y, 
                                                       newMagnifyingGlassSize.width, 
                                                       newMagnifyingGlassSize.height);
        
        self.magnifyingGlassView.frame = newMagnifyingGlassViewRect;
    //}    
    
    
    
    //
    // This chunk of code handles zooming of the magnifying glass
    //
    //{
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
        CGImageRef magnifyingGlassImageRef = CGImageCreateWithImageInRect( self.magnifyingGlassImage.CGImage, magnifiedImageFrame );
        
        self.magnifyingGlassView.layer.contents = objc_unretainedObject(magnifyingGlassImageRef);
        self.magnifyingGlassView.layer.borderWidth = 4.0;
        self.magnifyingGlassView.layer.cornerRadius = self.magnifyingGlassView.frame.size.width / 2.0;
        
        CGImageRelease(magnifyingGlassImageRef);
    //}
    
    ////NSLog(@"MagnifyingGlass center = %f,%f", self.magnifyingGlassView.center.x, self.magnifyingGlassView.center.y);
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



- (void)dimMagnifyingGlass
{
    [UIView animateWithDuration:0.0 animations:^{
        [self.magnifyingGlassView.layer setBorderColor:[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5] CGColor]];
    }];
}



- (void)undimMagnifyingGlass
{
    [UIView animateWithDuration:0.0 animations:^{
        [self.magnifyingGlassView.layer setBorderColor:[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] CGColor]];
    }];
    [self updateMagnifyingGlass];
}


@end
