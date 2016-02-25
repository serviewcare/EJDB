#import "ejdb_private.h"
#import <Foundation/Foundation.h>

@implementation EJDB

- (void)init:(CDVInvokedUrlCommand*)command
{

    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];

    #if TARGET_IPHONE_SIMULATOR
    #else
    #endif

    [self success:result callbackId:callbackId];
}

@end
