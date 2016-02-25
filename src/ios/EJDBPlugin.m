#import "ejdb.h"
#import "EJDBPlugin.h"
#import <Foundation/Foundation.h>

@implementation EJDBPlugin

static EJDB *jb;

- (CDVPluginResult*) ejdbnew:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    
    jb = ejdbnew();
    
    CDVPluginResult* result = NULL;
    
    if (!ejdbopen(jb, "addressbook", JBOWRITER | JBOCREAT | JBOTRUNC)) {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK];
    }
    
    
    
    [self success:result callbackId:callbackId];
}
- (CDVPluginResult*) ejdbcreatecoll:(CDVInvokedUrlCommand*)command {
    
}
- (CDVPluginResult*) ejdbsavejson:(CDVInvokedUrlCommand*)command {
    
}
- (CDVPluginResult*) ejdbqryexecute:(CDVInvokedUrlCommand*)command {
    
}

/*
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
 */

@end
