//
//  KSWorkspaceUtilities.m
//  Sandvox
//
//  Created by Mike on 28/04/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import "KSWorkspaceUtilities.h"

#import "KSURLUtilities.h"


@implementation NSWorkspace (KSWorkspaceUtilities)

- (NSString *)ks_MIMETypeForType:(NSString *)aUTI;
{
	NSString *result = NSMakeCollectable(UTTypeCopyPreferredTagWithClass((CFStringRef)aUTI, kUTTagClassMIMEType));
	result = [result autorelease];
    
    // BUGSID:37340 OS X doesn't know the MIME type for .m4a files, so we're hardcoding it here.
    if (!result)
	{
		if ([aUTI isEqualToString:(NSString *)kUTTypeMPEG4Audio])
		{
			result = @"audio/x-m4a";
		}
		else if ([aUTI isEqualToString:(NSString *)kUTTypeICO])
		{
			result = @"image/vnd.microsoft.icon";
		}
		// Apparently .m4v com.apple.protected-mpeg-4-video is also not known.
 		else if ([aUTI isEqualToString:@"com.apple.protected-mpeg-4-video"])
		{
			result = @"video/x-m4v";
		}
		else
		{
			result = @"application/octet-stream";
		}
	}
    
    OBPOSTCONDITION(result);
    return result;
}

- (NSString *)ks_OSTypeStringForType:(NSString *)aUTI
{
	NSString *result = NSMakeCollectable(UTTypeCopyPreferredTagWithClass(
																		 (CFStringRef)aUTI,
																		 kUTTagClassOSType
																		 ));
	result = [result autorelease];
	return result;
}

- (OSType)ks_OSTypeForType:(NSString *)aUTI
{
	return UTGetOSTypeFromString((CFStringRef)[self ks_OSTypeStringForType:aUTI]);
}

- (NSString *)ks_typeOfFileAtURL:(NSURL *)url;
{
	NSString *result = nil;
    FSRef fileRef;
    Boolean isDir;
    
    if (FSPathMakeRef((const UInt8 *)[[url path] fileSystemRepresentation], &fileRef, &isDir) == noErr)
    {
        // get the content type (UTI) of this file
		CFStringRef uti;
		if (LSCopyItemAttribute(&fileRef, kLSRolesViewer, kLSItemContentType, (CFTypeRef*)&uti)==noErr)
		{
			result = [NSMakeCollectable(uti) autorelease];	// I want an autoreleased copy of this.
		}
    }
	
	// check extension if we can't find the actual file
	if (nil == result)
	{
		NSString *extension = [url ks_pathExtension];
		if ( (nil != extension) && ![extension isEqualToString:@""] )
		{
			result = [self ks_typeForFilenameExtension:extension];
		}
	}
	
	// if no extension or no result, check file type
	if ( nil == result || [result isEqualToString:(NSString *)kUTTypeData])
	{
		NSString *fileType = NSHFSTypeOfFile([url path]);
		if (6 == [fileType length])
		{
			fileType = [fileType substringWithRange:NSMakeRange(1,4)];
		}
		result = [self ks_typeForOSTypeString:fileType];
		if ([result hasPrefix:@"dyn."])
		{
			result = nil;		// reject a dynamic type if it tries that.
		}
	}
    
	if (nil == result)	// not found, figure out if it's a directory or not
	{
        BOOL isDirectory;
        if ( [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory] )
		{
			result = isDirectory ? (NSString *)kUTTypeDirectory : (NSString *)kUTTypeData;
		}
	}
	
	// Will return nil if file doesn't exist.
	
	return result;
}

- (NSString *)ks_typeForFilenameExtension:(NSString *)anExtension;
{
	NSString *UTI = nil;
	
	if ([anExtension isEqualToString:@"m4v"])
	{
		// Hack, since we already have this UTI defined in the system, I don't think I can add it to the plist.
		UTI = (NSString *)kUTTypeMPEG4;
	}
	else
	{
		UTI = NSMakeCollectable(UTTypeCreatePreferredIdentifierForTag(
                                                                      kUTTagClassFilenameExtension,
                                                                      (CFStringRef)anExtension,
                                                                      NULL
                                                                      ));
		UTI = [UTI autorelease];
	}
    
	// If we don't find it, add an entry to the info.plist of the APP,
	// along the lines of what is documented here: 
	// http://developer.apple.com/documentation/Carbon/Conceptual/understanding_utis/understand_utis_conc/chapter_2_section_4.html
	// A good starting point for informal ones is:
	// http://www.huw.id.au/code/fileTypeIDs.html
    
	return UTI;
}

- (NSString *)ks_typeForMIMEType:(NSString *)aMIMEType
{
	if ([aMIMEType isEqualToString:@"image/vnd.microsoft.icon"])
	{
		return (NSString *)kUTTypeICO;
	}
	else
	{
		NSString *result = NSMakeCollectable(UTTypeCreatePreferredIdentifierForTag(
                                                                                   kUTTagClassMIMEType,
                                                                                   (CFStringRef)aMIMEType,
                                                                                   kUTTypeData 
                                                                                   ));
		result = [result autorelease];
		return result;
        
	}
}

- (NSString *)ks_typeForOSTypeString:(NSString *)aFileType;
{
	NSString *result = NSMakeCollectable(UTTypeCreatePreferredIdentifierForTag(
																			   kUTTagClassOSType,
																			   (CFStringRef)aFileType,
																			   NULL
																			   ));
	result = [result autorelease];
	return result;
}

- (NSString *)ks_typeForOSType:(OSType)anOSType;
{
	NSString *OSTypeAsString = NSMakeCollectable(UTCreateStringForOSType(anOSType));
	NSString *result = [self ks_typeForOSTypeString:OSTypeAsString];
	[OSTypeAsString release];
	return result;
}

- (BOOL)ks_type:(NSString *)type1 isEqualToType:(NSString *)anotherUTI;
{
	return UTTypeEqual (
						(CFStringRef)type1,
						(CFStringRef)anotherUTI
						);
}


- (BOOL)ks_type:(NSString *)type conformsToOneOfTypes:(NSArray *)types;
{
    for (NSString *aType in types)
    {
        if ([self type:type conformsToType:aType]) return YES;
    }
    
    return NO;
}

@end
