//
//  KSFileWrapperExtensions.m
//
//  Copyright (c) 2012 Mike Abdullah and Karelia Software
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

#pragma mark Directories

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

#pragma mark Symlinks

- (NSFileWrapper *)ks_symbolicLinkDestinationFileWrapper;
{
#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6
    if (![self respondsToSelector:@selector(symbolicLinkDestinationURL)] ||
        ![NSFileWrapper instancesRespondToSelector:@selector(initWithURL:options:error:)])
    {
        NSFileWrapper *result = [[NSFileWrapper alloc] initWithPath:[self symbolicLinkDestination]];
        return [result autorelease];
    }
#endif
    
    NSFileWrapper *result = [[NSFileWrapper alloc] initWithURL:[self symbolicLinkDestinationURL]
                                                       options:0
                                                         error:NULL];
    return [result autorelease];
}

#pragma mark Writing Files

- (BOOL)ks_writeToURL:(NSURL *)URL options:(NSFileWrapperWritingOptions)options originalParentDirectoryURL:(NSURL *)originalParentDirectory error:(NSError **)outError;
{
    NSString *filename = [self filename];
    NSURL *originalURL = (filename ? [originalParentDirectory URLByAppendingPathComponent:filename] : nil);
    
    // NSFileWrapper won't create hardlinks when writing an individual file, so we try to do so ourselves when reasonable, for performance reasons
    if ([self isRegularFile])    
    {
        // If the file is already inside a doc, we favour hardlinking for performance
        if ([self matchesContentsOfURL:originalURL])
        {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            BOOL result = [fileManager linkItemAtURL:originalURL toURL:URL error:outError];
            
            if (!result)
            {
                // Linking might fail because:
                // - The destination URL already exists
                // - It's an external filesystem which doesn't support hardlinks
                // - Attempted to link across filesystems
                //
                // If so, can just fall back to copying, which will handle all situations, except: destination already existing, and that fails fast on copying anyway
                result = [fileManager copyItemAtURL:originalURL toURL:URL error:outError];
            }
            [fileManager release];
            
            return result;
        }
    }
    
    // For regular files, asking NSFileWrapper is the final fallback
    // For directories that have already been copied into a doc, this will take the fast path of using hardlinks if possible. Unfortunately when taking the slow path, it does so by loading each file into memory. We dump them back out again when releasing the wrapper, but this could definitely be improved
    // For everything else (highly rare) this is the easy fallback
    return [self writeToURL:URL options:options originalContentsURL:originalURL error:outError];
}

@end
