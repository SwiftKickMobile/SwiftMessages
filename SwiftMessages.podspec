Pod::Spec.new do |spec|
    spec.name             = 'SwiftMessages'
    spec.version          = '0.0.1'
    spec.license          = { :type => 'MIT' }
    spec.homepage         = 'https://github.com/SwiftKickMobile/swift-messages-ios'
    spec.authors          = { 'Timothy Moose' => 'tim@swiftkick.it' }
    spec.summary          = 'A designer-friendly iOS message bar written in Swift.'
    spec.source           = {:git => 'https://github.com/SwiftKickMobile/swift-messages-ios.git', :tag => 'v0.0.1'}
    spec.platform         = :ios, '8.0'
    spec.ios.deployment_target = '8.0'
    spec.source_files     = 'SwiftMessages/**/*.swift'
    spec.resource_bundles = {'SwiftMessages' => ['SwiftMessages/Resources/**/*']}
    spec.framework        = 'UIKit'
    spec.requires_arc     = true
end