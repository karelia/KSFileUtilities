//
//  KSEncodeIDN.h
//  Sandvox
//
//  Created by Mike on 10/11/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//
//  Takes an internationalized domain name and encodes it in a NSURL-friendly manner. Based on http://www.vienna-rss.org/?p=215
//  Only safe to use on the main thread at present
//

#import <WebKit/WebKit.h>


@interface KSEncodeIDN : NSValueTransformer

@end
