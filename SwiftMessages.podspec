Pod::Spec.new do |spec|
    spec.name             = 'SwiftMessages'
    spec.version          = '4.1.3'
    spec.license          = { :type => 'MIT' }
    spec.homepage         = 'https://github.com/SwiftKickMobile/SwiftMessages'
    spec.authors          = { 'Timothy Moose' => 'tim@swiftkick.it' }
    spec.summary          = 'A very flexible message bar for iOS written in Swift.'
    spec.source           = {:git => 'https://github.com/SwiftKickMobile/SwiftMessages.git', :tag => '4.1.3'}
    spec.platform         = :ios, '8.0'
    spec.ios.deployment_target = '8.0'
    spec.framework        = 'UIKit'
    spec.requires_arc     = true
    spec.default_subspec  = 'Core'

    spec.subspec 'Core' do |core|
        core.source_files = 'SwiftMessages/**/*.swift'
        core.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*']}
    end
    
    spec.subspec 'AppExtension' do |ext|
        ext.source_files  = 'SwiftMessages/**/*.swift'
        ext.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*']}

        # For app extensions, disabling code paths using unavailable API
        ext.pod_target_xcconfig = {
            'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'SWIFTMESSAGES_APP_EXTENSIONS',
            'GCC_PREPROCESSOR_DEFINITIONS' => 'SWIFTMESSAGES_APP_EXTENSIONS=1'
        }
    end
end
