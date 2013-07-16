//
//  KSWorkspaceUtilities.m
//  Sandvox
//
//  Created by Mike on 28/04/2011.
//  Copyright © 2011 Karelia Software
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

#import "KSWorkspaceUtilities.h"

#import "KSURLUtilities.h"


@implementation NSWorkspace (KSWorkspaceUtilities)

#pragma mark Requesting Information

- (NSImage *)ks_iconForType:(NSString *)aUTI;
{
	NSString *extension = [self preferredFilenameExtensionForType:aUTI];
	NSImage *result = [self iconForFileType:extension];
    //[result normalizeSize];
	return result;
}

#pragma mark 

- (void)ks_setBundleBit:(BOOL)flag forFileAtURL:(NSURL *)url;
{
	FSRef fileRef;
	OSErr error = FSPathMakeRef((UInt8 *)[[url path] fileSystemRepresentation], &fileRef, NULL);
	
	// Get the file's current info
	FSCatalogInfo fileInfo;
	if (!error)
	{
		error = FSGetCatalogInfo(&fileRef, kFSCatInfoFinderInfo, &fileInfo, NULL, NULL, NULL);
	}
	
	if (!error)
	{
		// Adjust the bundle bit
		FolderInfo *finderInfo = (FolderInfo *)fileInfo.finderInfo;
		if (flag) {
			finderInfo->finderFlags |= kHasBundle;
		}
		else {
			finderInfo->finderFlags &= ~kHasBundle;
		}
		
		// Set the altered flags of the file
		error = FSSetCatalogInfo(&fileRef, kFSCatInfoFinderInfo, &fileInfo);
	}
	
	if (error) NSLog(@"OSError %i in -[NSWorkspace setBundleBit:forFile:]", error);
}

@end
