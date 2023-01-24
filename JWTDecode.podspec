Pod::Spec.new do |s|
  s.name             = 'JWTDecode'
  s.version          = '3.0.1'
  s.summary          = 'A JWT decoder for iOS, macOS, tvOS, and watchOS'
  s.description      = <<-DESC
                        Easily decode a JWT and access the claims it contains. 
                        > This library doesn't validate the JWT. Any well-formed JWT can be decoded from Base64URL.
                        DESC
  s.homepage         = 'https://github.com/auth0/JWTDecode.swift'
  s.license          = 'MIT'
  s.author           = { 'Auth0' => 'support@auth0.com', 'Rita Zerrizuela' => 'rita.zerrizuela@auth0.com' }
  s.source           = { :git => 'https://github.com/auth0/JWTDecode.swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '6.2'

  s.source_files = 'JWTDecode/*.swift'
  s.swift_versions = ['5.5', '5.6']
end
