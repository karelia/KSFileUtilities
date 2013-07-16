//
//  KSWebLocation.h
//
//  Created by Mike Abdullah
//  Copyright © 2008 Karelia Software
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

#import <Foundation/Foundation.h>


// Compatibility with old compilers. Partly copied straight from Clang docs
#ifndef __has_feature         // Optional of course.
#define __has_feature(x) 0  // Compatibility with non-clang compilers.
#endif
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
