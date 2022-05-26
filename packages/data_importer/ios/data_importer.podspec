#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint data_importer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'data_importer'
  s.version          = '0.0.1'
  s.summary          = 'Data importer from V1'
  s.description      = <<-DESC
Data importer from V1
                       DESC
  s.homepage         = 'https://openfoodfacts.org/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'OpenFoodFacts' => 'contact@openfoodfacts.org' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'KeychainAccess'
  s.dependency 'RealmSwift'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
