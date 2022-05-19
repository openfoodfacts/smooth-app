#import "DataImporterPlugin.h"
#if __has_include(<data_importer/data_importer-Swift.h>)
#import <data_importer/data_importer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "data_importer-Swift.h"
#endif

@implementation DataImporterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDataImporterPlugin registerWithRegistrar:registrar];
}
@end
