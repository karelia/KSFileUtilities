//
//  KSFileWrapperExtensions.h
//  Sandvox
//
//  Created by Mike Abdullah on 09/09/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileWrapper (KSFileWrapperExtensions)

- (NSString *)addFileWrapper:(NSFileWrapper *)wrapper subdirectory:(NSString *)subpath;

@end
