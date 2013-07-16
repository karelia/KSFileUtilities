//
//  KSFileWrapperExtensions.h
//
//  Created by Mike Abdullah
//  Copyright © 2012 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Cocoa/Cocoa.h>


@interface NSFileWrapper (KSFileWrapperExtensions)

// Like -addFileWrapper:, but if you supply a subdirectory the wrapper will be added as a grandchild (or deeper), rather than child
- (NSString *)addFileWrapper:(NSFileWrapper *)wrapper subdirectory:(NSString *)subpath;

// Removes all child file wrappers, except those whose filename begins with a period
- (void)ks_removeAllVisibleFileWrappers;

// Tries to construct a wrapper from the link's destination
- (NSFileWrapper *)ks_symbolicLinkDestinationFileWrapper;


#pragma mark Writing

// Simulates the behaviour NSFileWrapper gives you when writing a package, whereby files inside are hardlinked if possible. This method allows you to write an individual file and have it hard linked if possible
- (BOOL)ks_writeToURL:(NSURL *)URL options:(NSFileWrapperWritingOptions)options originalParentDirectoryURL:(NSURL *)originalParentDirectory error:(NSError **)outError;

// Just the like the above but very specialist allowing you to give up should hard linking fail, and not bother spending time doing a full copy
- (BOOL)ks_writeToURL:(NSURL *)URL options:(NSFileWrapperWritingOptions)options originalParentDirectoryURL:(NSURL *)originalParentDirectory copyIfLinkingFails:(BOOL)fallbackToCopy error:(NSError **)outError;

@end
