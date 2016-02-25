#import "AgentSDK.h"
#import "MobiControl.h"
#import <Foundation/Foundation.h>

#include "TargetConditionals.h"

@implementation MobiControl

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
       AgentSdkCore *agentSdkCore;

       // Create SDK instance. AgentSdkCore is a singleton.
       agentSdkCore = [AgentSdkCore getInstance];

       [agentSdkCore connectToDSUsingAppConfig];

       // Register self to receive notifications from SDK
       //[self.agentSdkCore registerDelegate:self];
       #endif
    [self success:result callbackId:callbackId];
}

@end
