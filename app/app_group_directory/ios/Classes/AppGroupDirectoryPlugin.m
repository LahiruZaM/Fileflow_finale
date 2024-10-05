#import "AppGroupDirectoryPlugin.h"

@implementation AppGroupDirectoryPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"me.wolszon.app_group_directory/channel"
            binaryMessenger:[registrar messenger]];
  AppGroupDirectoryPlugin* instance = [[AppGroupDirectoryPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getAppGroupDirectory" isEqualToString:call.method]) {
    result([self getAppGroupDirectoryWithId:call.arguments]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString*)getAppGroupDirectoryWithId:(NSString*)groupId {
  NSFileManager* fileManager = [NSFileManager defaultManager];

  // A URL indicating the location of the group's shared directory in the file system.
  // In iOS, the value is nil when the group identifier is invalid.
  NSURL *groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:groupId];
  return [groupURL path];
}

@end
