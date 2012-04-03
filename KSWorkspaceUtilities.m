//
//  KSWorkspaceUtilities.m
//  Sandvox
//
//  Created by Mike on 28/04/2011.
//  Copyright 2011-2012 Karelia Software. All rights reserved.
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
