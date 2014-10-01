Pod::Spec.new do |s|
  s.name             = "JWTDecode"
  s.version          = "0.1.0"
  s.summary          = "A JSON Web Token decoder for iOS"
  s.description      = <<-DESC
                        A Simple JSON Web Token decoder for iOS.
                        DESC
  s.homepage         = "https://github.com/auth0/JWTDecode.iOS"
  s.license          = 'MIT'
  s.author           = { "Hernan Zalazar" => "hernan@auth0.com" }
  s.source           = { :git => "https://github.com/auth0/JWTDecode.iOS.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/auth0'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
end
