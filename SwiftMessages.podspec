Pod::Spec.new do |spec|
    spec.name             = 'SwiftMessages'
    spec.version          = '10.0.1'
    spec.license          = { :type => 'MIT' }
    spec.homepage         = 'https://github.com/SwiftKickMobile/SwiftMessages'
    spec.authors          = { 'Timothy Moose' => 'tim@swiftkickmobile.com' }
    spec.summary          = 'A very flexible message bar for iOS written in Swift.'
    spec.source           = {:git => 'https://github.com/SwiftKickMobile/SwiftMessages.git', :tag => spec.version}
    spec.platform         = :ios, '13.0'
    spec.swift_version    = '5.0'
    spec.ios.deployment_target = '13.0'
    spec.framework        = 'UIKit'
    spec.requires_arc     = true
    spec.default_subspec  = 'App'

    spec.subspec 'App' do |app|
        app.source_files = 'SwiftMessages/**/*.swift'
        app.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/*.*']}
    end

    spec.subspec 'AppExtension' do |ext|
        ext.source_files  = 'SwiftMessages/**/*.swift'
        ext.exclude_files = 'SwiftMessages/**/SegueConvenienceClasses.swift'
        ext.resource_bundles = {'SwiftMessages_SwiftMessages' => ['SwiftMessages/Resources/**/*.*']}

        # For app extensions, disabling code paths using unavailable API
        ext.pod_target_xcconfig = {
            'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'SWIFTMESSAGES_APP_EXTENSIONS',
            'GCC_PREPROCESSOR_DEFINITIONS' => 'SWIFTMESSAGES_APP_EXTENSIONS=1'
        }
    end
end
