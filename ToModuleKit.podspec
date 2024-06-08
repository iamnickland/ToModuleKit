Pod::Spec.new do |s|
  s.name             = 'ToModuleKit'
  s.version          = "1.0.0"
  s.summary          = 'ToModuleKit 模块抽象类，可以提供模块生命周期回调.'
  s.description      = <<-DESC
  ToModuleKit 模块抽象类，可以提供模块生命周期回调，无感知集成模块.
                       DESC

  s.homepage         = 'https://github.com/iamnickland/ToModuleKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xxx' => 'xxx@gmail.com' }
  s.source           = { :git => 'https://github.com/iamnickland/ToModuleKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/**/*.{h,m}'
  s.public_header_files = ['Sources/TOModuleKit.h', 'Sources/TOModule.h']
end
