#import "VpCustomPlugin.h"
#if __has_include(<vp_custom/vp_custom-Swift.h>)
#import <vp_custom/vp_custom-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vp_custom-Swift.h"
#endif

@implementation VpCustomPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVpCustomPlugin registerWithRegistrar:registrar];
}
@end
