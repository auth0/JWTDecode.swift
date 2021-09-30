Pod::Spec.new do |s|
  s.name             = "JWTDecode"
  s.version          = '2.6.3'
  s.summary          = "A JSON Web Token decoder for iOS, macOS, tvOS"
  s.description      = <<-DESC
                        Decode a JWT to retrieve it's payload and also check for its expiration. 
                        > This library does not perform any validation of the JWT signature, it only decodes the token from Base64
                        DESC
  s.homepage         = "https://github.com/auth0/JWTDecode.swift"
  s.license          = 'MIT'
  s.author           = { "Auth0" => "support@auth0.com", "Hernan Zalazar" => "hernan@auth0.com", "Martin Walsh" => "martin.walsh@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/JWTDecode.swift.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = "10.11"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"
  s.requires_arc = true

  s.source_files = 'JWTDecode/*.swift'

  s.swift_versions = ['4.0', '4.1', '4.2', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5']
end
