//
//  KSWebLocation.m
//
//  Copyright (c) 2007-2010, Mike Abdullah, Dan Wood and Karelia Software
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
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH, DAN WOOD OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "KSWebLocation.h"


@implementation KSWebLocation

+ (id)webLocationWithURL:(NSURL *)URL;
{
    return [self webLocationWithURL:URL title:nil];
}

+ (id)webLocationWithURL:(NSURL *)URL title:(NSString *)title
{
	return [[[self alloc] initWithURL:URL title:title] autorelease];
}

#pragma mark Init & Dealloc

- (id)initWithURL:(NSURL *)URL title:(NSString *)name
{
	NSParameterAssert(URL);
	
	if (self = [super init])
	{
		_URL = [URL copy];
		_title = [name copy];
	}
	
	return self;
}

- (id)init
{
	return [self initWithURL:nil title:nil];
}

- (void)dealloc
{
	[_URL release];
	[_title release];
	
	[super dealloc];
}

#pragma mark Accessors

- (NSURL *)URL { return _URL; }

- (NSString *)title { return _title; }

#pragma mark Equality

- (NSUInteger)hash
{
	NSUInteger result = [[self URL] hash] | [[self title] hash];
	return result;
}

- (BOOL)isEqual:(id)anObject
{
	if (self == anObject)
	{
		return YES;
	}
	else if ([anObject isKindOfClass:[KSWebLocation class]])
	{
		return [self isEqualToWebLocation:anObject];
	}
	else
	{
		return NO;
	}
}

- (BOOL)isEqualToWebLocation:(KSWebLocation *)aWebLocation
{
	BOOL result = [[aWebLocation URL] isEqual:[self URL]] && [[aWebLocation title] isEqualToString:[self title]];
	return result;
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
	// KSWebLocations are effectively immutable (could add a mutable subclass if needed in the future) so retain
	return [self retain];
}

#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:[self URL] forKey:@"URL"];
	[encoder encodeObject:[self title] forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super init])
	{
		_URL = [[decoder decodeObjectForKey:@"URL"] retain];
		_title = [[decoder decodeObjectForKey:@"name"] retain];
	}
	
	return self;
}

#pragma mark Support

+ (NSURL *)URLWithString:(NSString *)string;
{
    // Encode the URL string
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)string,
                                                                        (CFStringRef)@"%+#",
                                                                        NULL,
                                                                        encoding);
    
    
    // If we're still left with a valid string, turn it into a URL
    NSURL *result = nil;
    if (escapedString)
    {
        result = [NSURL URLWithString:string];
        CFRelease(escapedString);
    }
    
    return result;
}

// Pass in nil for aName if we want to use ID
+ (NSData *)readFromResourceFileAtPath:(NSString *)aPath type:(ResType) aType named:(NSString *)aName id:(NSInteger)anID
{
	NSInteger	fileRef = 0;
	NSData *result = nil;
	@try
	{
		FSRef theFSRef;
		if (noErr == FSPathMakeRef((const UInt8 *)[aPath UTF8String], &theFSRef, NULL ))
		{
			fileRef = FSOpenResFile(&theFSRef, fsRdPerm);
			if (noErr == ResError())
			{
				Handle		theResHandle = NULL;
				NSInteger	thePreviousRefNum = CurResFile();	// save current resource
				Str255		thePName;
				
				UseResFile(fileRef);    		// set this resource to be current
				
				if (noErr ==  ResError())
				{
					if (aName)	// use name
					{
						Str255 pString;
						// Create pascal string -- assume MacRoman encoding for resource names?
						BOOL success = CFStringGetPascalString((CFStringRef)aName,
															   pString,
															   [aName length],
															   kCFStringEncodingMacRomanLatin1);
						if (success)
						{
							theResHandle = Get1NamedResource( aType, thePName );
						}
					}
					else	// use ID
					{
						theResHandle = Get1Resource( aType, anID );
					}	
					
					if (theResHandle && noErr == ResError())
					{
						// Wow, this is a trip down memory lane for Dan!
						HLock(theResHandle);
						result = [NSData dataWithBytes:*theResHandle length:GetHandleSize(theResHandle)];
						HUnlock(theResHandle);
						ReleaseResource(theResHandle);
					}
				}
				UseResFile( thePreviousRefNum );     		// reset back to resource previously set
			}
		}
	}
	@finally
	{
		if( fileRef > 0)
		{
			CloseResFile(fileRef);
		}
	}
	return result;
}

@end


#pragma mark -


@implementation KSWebLocation (WeblocFiles)

+ (id)webLocationWithContentsOfWeblocFile:(NSURL *)weblocURL
{
	return [[[self alloc] initWithContentsOfWeblocFile:weblocURL] autorelease];
}

- (id)initWithContentsOfWeblocFile:(NSURL *)weblocURL
{
	NSString *weblocPath = [weblocURL path];
	
	// Use the Carbon Resource Manager to read 'url ' resource #256.
	// String sems to be pre ASCII, with 2-bytes converted to % escapes
	NSData *urlData = [[self class] readFromResourceFileAtPath:weblocPath
                                                          type:'url '
                                                         named:nil
                                                            id:256];
	
	NSString *URLString = [[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding];
	NSURL *URL = [[self class] URLWithString:URLString];
    [URLString release];
	
	
	// Use the Carbon Resource Manager to read 'urln' resource #256.
	// empirically, this seems to be UTF8 encoded.
	NSData *nameData = [[self class] readFromResourceFileAtPath:weblocPath
                                                           type:'urln'
                                                          named:nil
                                                             id:256];
	
	NSString *nameString = [[NSString alloc] initWithData:nameData
                                                 encoding:NSUTF8StringEncoding];
	
	self = [self initWithURL:URL title:nameString];
    
    [nameString release];
    return self;
}

@end

