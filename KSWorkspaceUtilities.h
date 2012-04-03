//
//  KSWorkspaceUtilities.h
//  Sandvox
//
//  Created by Mike on 28/04/2011.
//  Copyright 2005-2012 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#define KSWORKSPACE [NSWorkspace sharedWorkspace]


@interface NSWorkspace (KSWorkspaceUtilities)

#pragma mark Requesting Information
- (NSImage *)ks_iconForType:(NSString *)aUTI;


#pragma mark Bundle Bit
- (void)ks_setBundleBit:(BOOL)flag forFileAtURL:(NSURL *)url;


@end
