//
//  main.m
//  MagnifyingGlass
//
//  Created by James Hillhouse on 5/24/11.
//  Copyright 2011 PortableFrontier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MagnifyAppDelegate.h"

int main(int argc, char *argv[])
{
    //
    // Pre-ARC Canned Code
    //
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    int retVal = UIApplicationMain(argc, argv, nil, nil);
//    [pool release];
//    return retVal;

    int retVal = 0;
    @autoreleasepool 
    {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([MagnifyAppDelegate class]));
    }
    return retVal;
}
