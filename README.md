# JWTDecode.swift

[![CI Status](http://img.shields.io/travis/auth0/JWTDecode.swift.svg?style=flat-square)](https://travis-ci.org/auth0/JWTDecode.swift)
[![Coverage Status](https://img.shields.io/codecov/c/github/auth0/JWTDecode.swift/master.svg?style=flat-square)](https://codecov.io/github/auth0/JWTDecode.swift)
[![Version](https://img.shields.io/cocoapods/v/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![License](https://img.shields.io/cocoapods/l/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![Platform](https://img.shields.io/cocoapods/p/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
![Swift 3.0.x](https://img.shields.io/badge/Swift-3.0.x-orange.svg)

This library will help you check [JWT](http://jwt.io/) payload

> This library doesn't validate the token, any well formed JWT can be decoded from Base64Url.

## Requirements

iOS 8+ and Xcode 8 (for Swift 3.0).

## Installation

###CocoaPods

JWTDecode is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JWTDecode"
```

###Carthage

In your Cartfile add this line

```
github "auth0/JWTDecode.swift"
```

###Manual installation

Download `JWTDecode.framework` from Releases and add it to your project in Xcode.


##Usage

Just import the framework

```swift
import JWTDecode
```

and decode the token

```swift
let jwt = try decode(jwt: token)    
```

### JWT parts

####Header dictionary
```swift
jwt.header
```

####Claims in token body
```swift
jwt.body
```

####Token signature
```swift
jwt.signature
```

### Registered Claims

* "aud" (Audience)
```swift
jwt.audience
```
* "sub" (Subject)
```swift
jwt.subject
```
* "jti" (JWT ID)
```swift
jwt.identifier
```
* "iss" (Issuer)
```swift
jwt.issuer
```
* "nbf" (Not Before)
```swift
jwt.notBefore
```
* "iat" (Issued At)
```swift
jwt.issuedAt
```
* "exp" (Expiration Time)
```swift
jwt.expiresAt
```

### Custom Claims
If we also have our custom claims we can retrive them calling `claim(name: String) -> Claim` then you can try converting the value like

```swift
let claim = jwt.claim(name: "email")
if let email = claim.string {
    print("Email in jwt was \(email)")
}
```

The supported conversions are:

```swift
var string: String?
var integer: Int?
var double: Double?
var date: NSDate?
var array: [String]?
```

### Error Handling
If the token is invalid an `NSError` will be thrown from the `decode(token)` function.
```swift
catch let error as NSError {
    error.localizedDescription
}
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
