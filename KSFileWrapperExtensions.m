//
//  KSFileWrapperExtensions.m
//  Sandvox
//
//  Created by Mike Abdullah on 09/09/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSFileWrapperExtensions.h"


@implementation NSFileWrapper (KSFileWrapperExtensions)

- (NSString *)addFileWrapper:(NSFileWrapper *)wrapper subdirectory:(NSString *)subpath;
{
    // Create any directories required by the path
    NSArray *components = [subpath pathComponents];
    NSFileWrapper *parentWrapper = self;
    
    NSUInteger i, count = [components count];
    for (i = 0; i < count; i++)
    {
        NSString *aComponent = [components objectAtIndex:i];
        NSFileWrapper *wrapper = [[parentWrapper fileWrappers] objectForKey:aComponent];
        if (!wrapper)
        {
            wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
            [wrapper setPreferredFilename:aComponent];
            [parentWrapper addFileWrapper:wrapper];
            [wrapper release];
        }
        
        parentWrapper = wrapper;
    }
    
    // Add the wrapper  
    return [parentWrapper addFileWrapper:wrapper];
}

@end
