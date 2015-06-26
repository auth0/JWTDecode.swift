# JWTDecode

[![CI Status](http://img.shields.io/travis/auth0/JWTDecode.swift.svg?style=flat-square)](https://travis-ci.org/auth0/JWTDecode.swift)
[![Version](https://img.shields.io/cocoapods/v/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![License](https://img.shields.io/cocoapods/l/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![Platform](https://img.shields.io/cocoapods/p/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)

This library will help you check [JWT](http://jwt.io/) payload

> This library doesn't validate the token, any well formed JWT can be decoded from Base64.

## Requirements

iOS 8+

## Installation

###CocoaPods

JWTDecode is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JWTDecode", '~> 0.3'
```

###Carthage

In your Cartfile add this line

```
github "auth0/JWTDecode.swift"
```

###Manual installation

Download and add `JWTDecode.swift` to your project in Xcode.

##JWTDecoder

###Decoding JWT token

```objc
@import JWTDecode;

NSString *jwt = ...; //Your JWT to decode
NSError *error;
JWTDecoder *decoder = [[JWTDecoder alloc] initWithJwt:jwt];
NSDictionary *payload = [decoder payloadWithError:&error]];
NSLog(@"JWT payload is %@", payload);
```

```swift
import JWTDecode

let jwt = ... //Your JWT to decode
let payload = A0JWTDecode.payload(jwt: jwt)
println("JWT payload is \(payload)")
```

###Get JWT token expiration date

```objc
@import JWTDecode;

NSString *jwt = ...; //Your JWT to decode
JWTDecoder *decoder = [[JWTDecoder alloc] initWithJwt:jwt];
NSLog(@"JWT expire date is %@", decoder.expireDate);
```

```swift
import JWTDecode

let jwt = ... //Your JWT to decode
let expireDate = JWTDecode.expireDate(jwt: jwt)
println("JWT expire date is \(expireDate)")
```

###Check if JWT token is expired

```objc
@import JWTDecode;

NSString *jwt = ...; //Your JWT to decode
JWTDecoder *decoder = [[JWTDecoder alloc] initWithJwt:jwt];
BOOL expired = decoder.expired;
```

```swift
import JWTDecode

let jwt = ... //Your JWT to decode
let expired = A0JWTDecode.expired(jwt: jwt)
```

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce, amont others**, or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS or any SAML Identity Provider**.
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [Json Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
* Analytics of how, when and where users are logging in.
* Pull data from other sources and add it to the user profile, through [JavaScript rules](https://docs.auth0.com/rules).

## Create a free Auth0 Account

1. Go to [Auth0](https://auth0.com) and click Sign Up.
2. Use Google, GitHub or Microsoft Account to login.

## Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

## Author

[Auth0](auth0.com)

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE.txt) file for more info.
