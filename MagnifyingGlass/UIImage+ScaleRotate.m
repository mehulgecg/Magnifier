#import "UIImage+ScaleRotate.h"

//#import <UIKit/UIKit.h>
#import <math.h>


@implementation UIImage (ScaleRotate)



- (UIImage *)scaleToRect:(CGRect)aRect
{
    NSLog(@"\n\n-scaleToRect:");
    
    
    // Scaling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGSize aSize = CGSizeMake(aRect.size.width, aRect.size.height);
    aSize.width *= [[UIScreen mainScreen] scale];
    aSize.height *= [[UIScreen mainScreen] scale];
    NSLog(@"self.size = %f, %f", self.size.width, self.size.height);
    NSLog(@"aRect size (adjusted for hi-res screen) = %f, %f", aSize.width, aSize.height);
    
    
    CGContextRef context = CGBitmapContextCreate(NULL, aSize.width, aSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextClearRect(context, aRect);

    if(self.imageOrientation == UIImageOrientationRight)
    {
        NSLog(@"UIImageOrientationRight");
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, 0.0f, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, aSize.height, aSize.width), self.CGImage);
    }
    
    if(self.imageOrientation == UIImageOrientationLeft)
    {
        NSLog(@"UIImageOrientationLeft");
        CGContextRotateCTM(context, M_PI_2);
        CGContextTranslateCTM(context, -aSize.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, aSize.height, aSize.width), self.CGImage);
    }
 
    else
    {
        CGContextDrawImage(context, CGRectMake(0, 0, aSize.width, aSize.height), self.CGImage);
    }
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);

    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    NSLog(@"scaledImage size = %f, %f", image.size.width, image.size.height);

    CGImageRelease(scaledImage);
    
    NSLog(@"\n\n");

    return image;
}


@end