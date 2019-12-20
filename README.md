# JWTDecode.swift

[![CI Status](http://img.shields.io/travis/auth0/JWTDecode.swift.svg?style=flat-square)](https://travis-ci.org/auth0/JWTDecode.swift)
[![Coverage Status](https://img.shields.io/codecov/c/github/auth0/JWTDecode.swift/master.svg?style=flat-square)](https://codecov.io/github/auth0/JWTDecode.swift)
[![Version](https://img.shields.io/cocoapods/v/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![License](https://img.shields.io/cocoapods/l/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![Platform](https://img.shields.io/cocoapods/p/JWTDecode.svg?style=flat-square)](http://cocoadocs.org/docsets/JWTDecode)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat-square)

This library will help you check [JWT](http://jwt.io/) payload

> This library doesn't validate the token, any well formed JWT can be decoded from Base64Url.

## Requirements

- iOS 9+ / macOS 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 10.x
- Swift 4.x/5.x

## Installation

#### Carthage

If you are using Carthage, add the following lines to your `Cartfile`:

```ruby
github "auth0/JWTDecode.swift" ~> 2.4
```

Then run `carthage bootstrap`.

> For more information about Carthage usage, check [their official documentation](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

#### Cocoapods

If you are using [Cocoapods](https://cocoapods.org/), add these lines to your `Podfile`:

```ruby
use_frameworks!
pod 'JWTDecode', '~> 2.4'
```

Then, run `pod install`.

> For further reference on Cocoapods, check [their official documentation](http://guides.cocoapods.org/using/getting-started.html).

#### SPM (Xcode 11.2+)

If you are using the Swift Package Manager, open the following menu item in Xcode:

**File > Swift Packages > Add Package Dependency...**

In the **Choose Package Repository** prompt add this url: 

```
https://github.com/auth0/JWTDecode.swift.git
```

Then, press **Next** and complete the remaining steps.

> For further reference on SPM, check [its official documentation](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Usage

Import the framework

```swift
import JWTDecode
```

Decode the token

```swift
let jwt = try decode(jwt: token)    
```

### JWT parts

#### Header dictionary

```swift
jwt.header
```

#### Claims in token body

```swift
jwt.body
```

#### Token signature
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

You can easily add a convenience accessor for a custom claim by adding an extension:

```swift
extension JWT {
    var myClaim: String? {
        return claim(name: "my_claim").string
    }
}
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
