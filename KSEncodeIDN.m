//
//  KSEncodeIDN.m
//  Sandvox
//
//  Created by Mike on 10/11/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSEncodeIDN.h"


@implementation KSEncodeIDN

+ (Class)transformedValueClass { return [NSURL class]; }

- (id)transformedValue:(id)value;
{
    static NSPasteboard *pboard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pboard = [[NSPasteboard pasteboardWithUniqueName] retain];
    });
    
    [pboard clearContents];
    [pboard writeObjects:@[value]];
    
    NSURL *result = [WebView URLFromPasteboard:pboard];
    return result;
}

@end
