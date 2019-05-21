
Pod::Spec.new do |s|
  s.name             = 'TextAnnotation'
  s.version          = '0.1.1'
  s.summary          = 'Swift text annotation component for macOS.'
  s.description      = <<-DESC
Text component that behaves like typical drawing or annotation apps require.
                       DESC

  s.homepage         = 'https://github.com/blackbeltlabs/TextAnnotation'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mirko Kiefer' => 'mail@mirkokiefer.com' }
  s.source           = { :git => 'https://github.com/blackbeltlabs/TextAnnotation.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform = :osx
  s.osx.deployment_target = "10.13"
  s.swift_version = "4.2"

  s.source_files = 'TextAnnotation/Classes/**/*'
  s.resources = 'TextAnnotation/Assets/**/*'
end
