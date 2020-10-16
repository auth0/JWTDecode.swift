# JWTDecode.swift

[![CircleCI](https://img.shields.io/circleci/build/github/auth0/JWTDecode.swift?style=flat-square)](https://circleci.com/gh/auth0/JWTDecode.swift)
[![Coverage Status](https://img.shields.io/codecov/c/github/auth0/JWTDecode.swift/master.svg?style=flat-square)](https://codecov.io/github/auth0/JWTDecode.swift)
[![Version](https://img.shields.io/cocoapods/v/JWTDecode.svg?style=flat-square)](https://cocoadocs.org/docsets/JWTDecode)
[![License](https://img.shields.io/cocoapods/l/JWTDecode.svg?style=flat-square)](https://cocoadocs.org/docsets/JWTDecode)
[![Platform](https://img.shields.io/cocoapods/p/JWTDecode.svg?style=flat-square)](https://cocoadocs.org/docsets/JWTDecode)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
![Swift 5.3](https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat-square)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fauth0%2FJWTDecode.swift.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fauth0%2FJWTDecode.swift?ref=badge_shield)

This library will help you check [JWT](https://jwt.io/) payload

> This library doesn't validate the token, any well formed JWT can be decoded from Base64Url.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [What is Auth0?](#what-is-auth0)
- [Create a Free Auth0 Account](#create-a-free-auth0-account)
- [Issue Reporting](#issue-reporting)
- [Author](#author)
- [License](#license)

## Requirements

- iOS 9+ / macOS 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 11.4+ / 12.x
- Swift 4.x/5.x

## Installation

#### Cocoapods

If you are using [Cocoapods](https://cocoapods.org), add this line to your `Podfile`:

```ruby
pod 'JWTDecode', '~> 2.4'
```

Then run `pod install`.

> For more information on Cocoapods, check [their official documentation](https://guides.cocoapods.org/using/getting-started.html).

#### Carthage

If you are using [Carthage](https://github.com/Carthage/Carthage), add the following line to your `Cartfile`:

```ruby
github "auth0/JWTDecode.swift" ~> 2.4
```

Then run `carthage bootstrap`.

> For more information about Carthage usage, check [their official documentation](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

#### SPM (Xcode 11.2+)

If you are using the Swift Package Manager, open the following menu item in Xcode:

**File > Swift Packages > Add Package Dependency...**

In the **Choose Package Repository** prompt add this url: 

```
https://github.com/auth0/JWTDecode.swift.git
```

Then press **Next** and complete the remaining steps.

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

### JWT Parts

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

If we also have our custom claims we can retrive them calling `claim(name: String) -> Claim` then you can try converting the value like:

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

If the token is invalid an `NSError` will be thrown from the `decode(token)` function:

```swift
catch let error as NSError {
    error.localizedDescription
}
```

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple sources](https://auth0.com/docs/identityproviders), either social identity providers such as **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce** (amongst others), or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS, or any SAML Identity Provider**.
* Add authentication through more traditional **[username/password databases](https://auth0.com/docs/connections/database/custom-db)**.
* Add support for **[linking different user accounts](https://auth0.com/docs/link-accounts)** with the same user.
* Support for generating signed [JSON Web Tokens](https://auth0.com/docs/tokens/concepts/jwts) to call your APIs and **flow the user identity** securely.
* Analytics of how, when, and where users are logging in.
* Pull data from other sources and add it to the user profile through [JavaScript rules](https://auth0.com/docs/rules).

## Create a Free Auth0 Account

1. Go to [Auth0](https://auth0.com) and click **Sign Up**.
2. Use Google, GitHub, or Microsoft Account to login.

## Issue Reporting

If you have found a bug or to request a feature, please [raise an issue](https://github.com/auth0/JWTDecode.swift/issues). Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

## Author

[Auth0](https://auth0.com)

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE.txt) file for more info.


[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fauth0%2FJWTDecode.swift.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fauth0%2FJWTDecode.swift?ref=badge_large)
