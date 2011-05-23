//
//  KSFileWrapperExtensions.m
//
//  Copyright (c) 2011, Mike Abdullah and Karelia Software
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "KSFileWrapperExtensions.h"


@implementation NSFileWrapper (KSFileWrapperExtensions)

- (NSString *)addFileWrapper:(NSFileWrapper *)wrapper subdirectory:(NSString *)subpath;
{
    // Create any directories required by the subpath
    NSArray *components = [subpath pathComponents];
    NSFileWrapper *parentWrapper = self;
    
    NSUInteger i, count = [components count];
    for (i = 0; i < count; i++)
    {
        NSString *aComponent = [components objectAtIndex:i];
        NSFileWrapper *aWrapper = [[parentWrapper fileWrappers] objectForKey:aComponent];
        if (!aWrapper)
        {
            aWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
            [aWrapper setPreferredFilename:aComponent];
            [parentWrapper addFileWrapper:aWrapper];
            [aWrapper release];
        }
        
        parentWrapper = aWrapper;
    }
    
    // We finally have a suitable parent to add the wrapper to
    return [parentWrapper addFileWrapper:wrapper];
}

- (void)ks_removeAllVisibleFileWrappers;
{
    // Leopard had a bug where -fileWrappers returns its own backing store, which means it will mutate while enumerating
    NSDictionary *wrappers = [[self fileWrappers] copy];
    
    for (NSString *aFilename in wrappers)
    {
        if (![aFilename hasPrefix:@"."])
        {
            NSFileWrapper *aWrapper = [wrappers objectForKey:aFilename];
            [self removeFileWrapper:aWrapper];
        }
    }
    
    [wrappers release];
}

@end
