#import <Cordova/CDV.h>

@interface EJDBPlugin : CDVPlugin

- (CDVPluginResult*) ejdbnew:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) ejdbcreatecoll:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) ejdbsavejson:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*) ejdbqryexecute:(CDVInvokedUrlCommand*)command;

@end
