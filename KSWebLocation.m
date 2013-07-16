//
//  KSWebLocation.m
//
//  Created by Mike Abdullah
//  Copyright © 2007 Karelia Software
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

#import "KSWebLocation.h"

#import "KSURLFormatter.h"


@implementation KSWebLocation

+ (instancetype)webLocationWithURL:(NSURL *)URL;
{
    return [self webLocationWithURL:URL title:nil];
}

+ (instancetype)webLocationWithURL:(NSURL *)URL title:(NSString *)title
{
	return [[[self alloc] initWithURL:URL title:title] autorelease];
}

#pragma mark Init & Dealloc

- (id)initWithURL:(NSURL *)URL title:(NSString *)name
{
	NSParameterAssert(URL);
	
	if ((self = [super init]))
	{
		_URL = [URL copy];
		_title = [name copy];
	}
	
	return self;
}

- (id)initWithURL:(NSURL *)URL;
{
    return [self initWithURL:URL title:nil];
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

- (NSString *)description;
{
    return [NSString stringWithFormat:
            @"%@ %@ %@",
            [super description],
            [[self URL] absoluteString],
            [self title]];
}

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
	if ((self = [super init]))
	{
		_URL = [[decoder decodeObjectForKey:@"URL"] retain];
		_title = [[decoder decodeObjectForKey:@"name"] retain];
	}
	
	return self;
}

#pragma mark Support

// Pass in nil for aName if we want to use ID
+ (NSData *)readFromResourceFileAtPath:(NSString *)aPath type:(ResType) aType named:(NSString *)aName id:(NSInteger)anID
{
	ResFileRefNum fileRef = 0;
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
				ResFileRefNum	thePreviousRefNum = CurResFile();	// save current resource
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

+ (instancetype)webLocationWithContentsOfWeblocFile:(NSURL *)weblocURL
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
	NSURL *URL = [KSURLFormatter URLFromString:URLString];
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

