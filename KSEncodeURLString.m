//
//  KSEncodeURLString
//  Sandvox
//
//  Created by Mike on 10/11/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSEncodeURLString.h"


@implementation KSEncodeURLString

+ (Class)transformedValueClass { return [NSURL class]; }

- (id)transformedValue:(id)value;
{
    static NSPasteboard *pboard;
    if (!pboard) pboard = [[NSPasteboard pasteboardWithUniqueName] retain];
    
    [pboard clearContents];
    [pboard writeObjects:@[value]];
    
    NSURL *result = [WebView URLFromPasteboard:pboard];
    return result;
}

@end
