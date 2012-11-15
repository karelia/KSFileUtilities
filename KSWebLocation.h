//
//  KSWebLocation.h
//
//  Copyright (c) 2008-2012 Mike Abdullah and Karelia Software
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


#import <Foundation/Foundation.h>


// Compatibility with old compilers
#if !__has_feature(objc_instancetype)
#define instancetype id
#endif


/* The NSPasteboardReading protocol enables instances of a class to be created from pasteboard data by using the -readObjectsForClasses:options: method of NSPasteboard.  The Cocoa framework classes NSString, NSAttributedString, NSURL, NSColor, NSSound, NSImage, and NSPasteboardItem implement this protocol.  The protocol can also be implemented by custom application classes for use with -readObjectsForClasses:options:
 */ 


@interface KSWebLocation : NSObject <NSCopying, NSCoding>
{
  @private
	NSURL		*_URL;
	NSString	*_title;
}

#pragma mark Init
+ (instancetype)webLocationWithURL:(NSURL *)URL;
+ (instancetype)webLocationWithURL:(NSURL *)URL title:(NSString *)title;
- (id)initWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL title:(NSString *)title;	// Designated initializer


#pragma mark Accessors
@property(nonatomic, copy, readonly) NSURL *URL;
@property(nonatomic, copy, readonly) NSString *title;


#pragma mark Equality
- (BOOL)isEqualToWebLocation:(KSWebLocation *)aWebLocation;


@end


#pragma mark -


@interface KSWebLocation (WeblocFiles)
+ (instancetype)webLocationWithContentsOfWeblocFile:(NSURL *)weblocURL;
- (id)initWithContentsOfWeblocFile:(NSURL *)weblocURL;
@end
