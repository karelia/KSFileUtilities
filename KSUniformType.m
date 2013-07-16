//
//  KSUniformType.m
//  Sandvox
//
//  Created by Mike Abdullah on 01/04/2012.
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

#import "KSUniformType.h"

@implementation KSUniformType

+ (NSString *)MIMETypeForType:(NSString *)aUTI;
{
	NSString *result = NSMakeCollectable(UTTypeCopyPreferredTagWithClass((CFStringRef)aUTI, kUTTagClassMIMEType));
	[result autorelease];
    
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
    
    NSAssert(result, @"Should always fall back to raw data MIME type at the least");
    return result;
}

+ (NSString *)OSTypeStringForType:(NSString *)aUTI
{
	NSString *result = NSMakeCollectable(UTTypeCopyPreferredTagWithClass(
																		 (CFStringRef)aUTI,
																		 kUTTagClassOSType
																		 ));
	return [result autorelease];
}

+ (OSType)OSTypeForType:(NSString *)aUTI
{
	return UTGetOSTypeFromString((CFStringRef)[self OSTypeStringForType:aUTI]);
}

+ (NSString *)typeOfFileAtURL:(NSURL *)url;
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
		NSString *extension = [url pathExtension];
		if ( (nil != extension) && ![extension isEqualToString:@""] )
		{
			result = [self typeForFilenameExtension:extension];
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
		result = [self typeForOSTypeString:fileType];
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

+ (NSString *)typeForFilenameExtension:(NSString *)anExtension;
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
		[UTI autorelease];
	}
    
	// If we don't find it, add an entry to the info.plist of the APP,
	// along the lines of what is documented here: 
	// http://developer.apple.com/documentation/Carbon/Conceptual/understanding_utis/understand_utis_conc/chapter_2_section_4.html
	// A good starting point for informal ones is:
	// http://www.huw.id.au/code/fileTypeIDs.html
    
	return UTI;
}

+ (NSString *)typeForMIMEType:(NSString *)aMIMEType
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
		return [result autorelease];
	}
}

+ (NSString *)typeForOSTypeString:(NSString *)aFileType;
{
	NSString *result = NSMakeCollectable(UTTypeCreatePreferredIdentifierForTag(
																			   kUTTagClassOSType,
																			   (CFStringRef)aFileType,
																			   NULL
																			   ));
	return [result autorelease];
}

+ (NSString *)typeForOSType:(OSType)anOSType;
{
	NSString *OSTypeAsString = NSMakeCollectable(UTCreateStringForOSType(anOSType));
	NSString *result = [self typeForOSTypeString:OSTypeAsString];
	[OSTypeAsString release];
	return result;
}

#pragma mark Creating a KSUniformType Instance

+ (instancetype)uniformTypeWithFilenameExtension:(NSString *)extension;
{
    return [[[self alloc] initWithIdentifier:[self typeForFilenameExtension:extension]] autorelease];
}

+ (instancetype)uniformTypeWithIdentifier:(NSString *)identifier;
{
    if (!identifier) return nil;
    return [[[self alloc] initWithIdentifier:identifier] autorelease];
}

+ (instancetype)bestGuessUniformTypeForURL:(NSURL *)url;
{
    return [self uniformTypeWithIdentifier:[self typeOfFileAtURL:url]];
}

- (id)initWithIdentifier:(NSString *)uti;
{
    NSParameterAssert(uti);
    if (self = [self init])
    {
        _identifier = [uti copy];
    }
    
    return self;
}

- (void)dealloc;
{
    [_identifier release];
    [super dealloc];
}

#pragma mark Properties

@synthesize identifier = _identifier;

- (NSString *)MIMEType; { return [[self class] MIMETypeForType:[self identifier]]; }

#pragma mark Testing Uniform Type Identifiers

- (BOOL)isEqualToType:(NSString *)type; { return [[self class] type:[self identifier] isEqualToType:type]; }

- (BOOL)isEqual:(id)object;
{
    if (self == object) return YES;
    if (![object isKindOfClass:[KSUniformType class]]) return NO;
    
    return [self isEqualToType:[object identifier]];
}

- (NSUInteger)hash; { return 0; }   // see header

- (BOOL)conformsToType:(NSString *)type;
{
    return [[NSWorkspace sharedWorkspace] type:[self identifier] conformsToType:type];
}

+ (BOOL)type:(NSString *)type1 isEqualToType:(NSString *)anotherUTI;
{
	return UTTypeEqual((CFStringRef)type1, (CFStringRef)anotherUTI);
}

+ (BOOL)type:(NSString *)type conformsToOneOfTypes:(NSArray *)types;
{
    for (NSString *aType in types)
    {
        if ([[NSWorkspace sharedWorkspace] type:type conformsToType:aType]) return YES;
    }
    
    return NO;
}

@end
