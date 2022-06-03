# JWTDecode.swift (First Availability)

[![CircleCI](https://img.shields.io/circleci/build/github/auth0/JWTDecode.swift?style=flat-square)](https://circleci.com/gh/auth0/JWTDecode.swift)
[![Coverage Status](https://img.shields.io/codecov/c/github/auth0/JWTDecode.swift/master.svg?style=flat-square)](https://codecov.io/github/auth0/JWTDecode.swift)
[![Version](https://img.shields.io/cocoapods/v/JWTDecode.svg?style=flat-square)](https://cocoadocs.org/docsets/JWTDecode)
[![License](https://img.shields.io/cocoapods/l/JWTDecode.svg?style=flat-square)](https://cocoadocs.org/docsets/JWTDecode)
[![Platform](https://img.shields.io/cocoapods/p/JWTDecode.svg?style=flat-square)](https://cocoadocs.org/docsets/JWTDecode)

Helps you decode a [JWT](https://jwt.io/) and access its payload.

> ⚠️ This library doesn't validate the JWT. Any well formed JWT can be decoded from Base64Url.

> ⚠️ This library is currently in **First Availability**. We do not recommend using this library in production yet. As we move towards General Availability, please be aware that releases may contain breaking changes.

**Migrating from v2? Check the [Migration Guide](V3_MIGRATION_GUIDE.md).**

---

## Table of Contents

- [**Requirements**](#requirements)
- [**Installation**](#installation)
  + [Swift Package Manager](#swift-package-manager)
  + [Cocoapods](#cocoapods)
  + [Carthage](#carthage)
- [**Usage**](#usage)
  + [JWT Parts](#jwt-parts)
  + [Registered Claims](#registered-claims)
  + [Custom Claims](#custom-claims)
  + [Error Handling](#error-handling)
- [**Issue Reporting**](#issue-reporting)
- [**What is Auth0?**](#what-is-auth0)
- [**License**](#license)

## Requirements

- iOS 12+ / macOS 10.15+ / tvOS 12.0+ / watchOS 6.2+
- Xcode 13.x
- Swift 5.5+

## Installation

### Swift Package Manager

Open the following menu item in Xcode:

**File > Add Packages...**

In the **Search or Enter Package URL** search box enter this URL: 

```text
https://github.com/auth0/JWTDecode.swift
```

Then, select the dependency rule and press **Add Package**.

> 💡 For further reference on SPM, check its [official documentation](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app).

### Cocoapods

Add the following line to your `Podfile`:

```ruby
pod 'JWTDecode', '~> 3.0'
```

Then, run `pod install`.

> 💡 For further reference on Cocoapods, check their [official documentation](https://guides.cocoapods.org/using/getting-started.html).

### Carthage

Add the following line to your `Cartfile`:

```text
github "auth0/JWTDecode.swift" ~> 3.0
```

Then, run `carthage bootstrap --use-xcframeworks`.

> 💡 For further reference on Carthage, check their [official documentation](https://github.com/Carthage/Carthage#getting-started).

## Usage

1. Import the framework:

```swift
import JWTDecode
```

2. Decode the token:

```swift
let jwt = try decode(jwt: token)    
```

### JWT Parts

| Part               | Property        |
|:-------------------|:----------------|
| Header dictionary  | `jwt.header`    |
| Claims in JWT body | `jwt.body`      |
| JWT signature      | `jwt.signature` |

### Registered Claims

| Claim                     | Property         |
|:--------------------------|:-----------------|
| **aud** (Audience)        | `jwt.audience`   |
| **sub** (Subject)         | `jwt.subject`    |
| **jti** (JWT ID)          | `jwt.identifier` |
| **iss** (Issuer)          | `jwt.issuer`     |
| **nbf** (Not Before)      | `jwt.notBefore`  |
| **iat** (Issued At)       | `jwt.issuedAt`   |
| **exp** (Expiration Time) | `jwt.expiresAt`  |

### Custom Claims

If you have a custom claim you can retrieve it by calling `claim(name:)`. Then you can attempt to convert the value to a specific type.

```swift
let claim = jwt.claim(name: "email")
if let email = claim.string {
    print("Email in jwt was \(email)")
}
```

The supported conversions are:

```swift
var string: String?
var boolean: Bool?
var integer: Int?
var double: Double?
var date: Date?
var array: [String]?
```

You can easily add a convenience accessor for a custom claim in an extension.

```swift
extension JWT {
    var myClaim: String? {
        return claim(name: "my_claim").string
    }
}
```

### Error Handling

If the token is malformed the `decode(jwt:)` function will throw a `DecodeError`.

```swift
catch let error {
    error.localizedDescription
}
```

## Issue Reporting

For general support or usage questions, use the [Auth0 Community](https://community.auth0.com/c/sdks/5) forums or raise a [support ticket](https://support.auth0.com/). Only [raise an issue](https://github.com/auth0/JWTDecode.swift/issues) if you have found a bug or want to request a feature.

**Do not report security vulnerabilities on the public GitHub issue tracker.** The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

## What is Auth0?

Auth0 helps you to:

- Add authentication with [multiple sources](https://auth0.com/docs/authenticate/identity-providers), either social identity providers such as **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce** (amongst others), or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS, or any SAML Identity Provider**.
- Add authentication through more traditional **[username/password databases](https://auth0.com/docs/authenticate/database-connections/custom-db)**.
- Add support for **[linking different user accounts](https://auth0.com/docs/manage-users/user-accounts/user-account-linking)** with the same user.
- Support for generating signed [JSON Web Tokens](https://auth0.com/docs/secure/tokens/json-web-tokens) to call your APIs and **flow the user identity** securely.
- Analytics of how, when, and where users are logging in.
- Pull data from other sources and add it to the user profile through [JavaScript Actions](https://auth0.com/docs/customize/actions).

**Why Auth0?** Because you should save time, be happy, and focus on what really matters: building your product.

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

[Go up ⤴](#table-of-contents)
