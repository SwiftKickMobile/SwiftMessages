Pod::Spec.new do |spec|
    spec.name             = 'SwiftMessages'
    spec.version          = '6.0.2'
    spec.license          = { :type => 'MIT' }
    spec.homepage         = 'https://github.com/SwiftKickMobile/SwiftMessages'
    spec.authors          = { 'Timothy Moose' => 'tim@swiftkick.it' }
    spec.summary          = 'A very flexible message bar for iOS and tvOS written in Swift.'
    spec.source           = {:git => 'https://github.com/SwiftKickMobile/SwiftMessages.git', :tag => spec.version}
    spec.swift_version    = '4.2'
    spec.ios.deployment_target = '9.0'
    spec.tvos.deployment_target = '9.0'
    spec.framework        = 'UIKit'
    spec.default_subspec  = 'App'

    spec.subspec 'App' do |app|
        app.source_files = 'SwiftMessages/**/*.swift'
        app.ios.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*', 'SwiftMessages/ResourcesIOS/**/*']}
        app.tvos.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*', 'SwiftMessages/ResourcesTvOS/**/*']}
    end

    spec.subspec 'AppExtension' do |ext|
        ext.source_files  = 'SwiftMessages/**/*.swift'
        ext.exclude_files = 'SwiftMessages/**/SegueConvenienceClasses.swift'
        ext.ios.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*', 'SwiftMessages/ResourcesIOS/**/*']}
        ext.tvos.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*', 'SwiftMessages/ResourcesTvOS/**/*']}

        # For app extensions, disabling code paths using unavailable API
        ext.pod_target_xcconfig = {
            'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'SWIFTMESSAGES_APP_EXTENSIONS',
            'GCC_PREPROCESSOR_DEFINITIONS' => 'SWIFTMESSAGES_APP_EXTENSIONS=1'
        }
    end
end
