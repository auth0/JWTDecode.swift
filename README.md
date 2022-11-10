![JWTDecode.swift](https://cdn.auth0.com/website/sdks/banners/jwtdecode-swift-banner.png)

![Version](https://img.shields.io/cocoapods/v/JWTDecode.svg?style=flat)
[![CircleCI](https://img.shields.io/circleci/build/github/auth0/JWTDecode.swift?style=flat)](https://circleci.com/gh/auth0/JWTDecode.swift/tree/master)
[![Coverage Status](https://img.shields.io/codecov/c/github/auth0/JWTDecode.swift/master.svg?style=flat)](https://codecov.io/github/auth0/JWTDecode.swift)
![License](https://img.shields.io/github/license/auth0/JWTDecode.swift.svg?style=flat)

📚 [**Documentation**](#documentation) • 🚀 [**Getting Started**](#getting-started) • 📃 [**Support Policy**](#support-policy) • 💬 [**Feedback**](#feedback)

**This library doesn't validate the JWT. Any well-formed JWT can be decoded from Base64URL.**

Migrating from v2? Check the [Migration Guide](V3_MIGRATION_GUIDE.md).

## Documentation

- [**API Documentation**](https://auth0.github.io/JWTDecode.swift/documentation/jwtdecode) - documentation auto-generated from the code comments that explains all the available features.
  + [JWT](https://auth0.github.io/JWTDecode.swift/documentation/jwtdecode/jwt)
  + [Claim](https://auth0.github.io/JWTDecode.swift/documentation/jwtdecode/claim)
  + [JWTDecodeError](https://auth0.github.io/JWTDecode.swift/documentation/jwtdecode/jwtdecodeerror)
- [**Auth0 Documentation**](https://auth0.com/docs) - explore our docs site and learn more about Auth0.

> **Note**
> Check the [Support Policy](#support-policy) to learn when dropping Xcode, Swift, and platform versions will not be considered a **breaking change**.

## Getting Started

### Requirements

- iOS 12.0+ / macOS 10.15+ / tvOS 12.0+ / watchOS 6.2+
- Xcode 13.x / 14.x
- Swift 5.5+

### Installation

#### Swift Package Manager

Open the following menu item in Xcode:

**File > Add Packages...**

In the **Search or Enter Package URL** search box enter this URL: 

```text
https://github.com/auth0/JWTDecode.swift
```

Then, select the dependency rule and press **Add Package**.

#### Cocoapods

Add the following line to your `Podfile`:

```ruby
pod 'JWTDecode', '~> 3.0'
```

Then, run `pod install`.

#### Carthage

Add the following line to your `Cartfile`:

```text
github "auth0/JWTDecode.swift" ~> 3.0
```

Then, run `carthage bootstrap --use-xcframeworks`.

### Usage

**See all the available features in the [API documentation ↗](https://auth0.github.io/JWTDecode.swift/documentation/jwtdecode)**

1. Import the framework

```swift
import JWTDecode
```

2. Decode the token

```swift
let jwt = try decode(jwt: token)    
```

#### JWT parts

| Part               | Property        |
|:-------------------|:----------------|
| Header dictionary  | `jwt.header`    |
| Claims in JWT body | `jwt.body`      |
| JWT signature      | `jwt.signature` |

#### Registered claims

| Claim                   | Property         |
|:------------------------|:-----------------|
| **aud** Audience        | `jwt.audience`   |
| **sub** Subject         | `jwt.subject`    |
| **jti** JWT ID          | `jwt.identifier` |
| **iss** Issuer          | `jwt.issuer`     |
| **nbf** Not Before      | `jwt.notBefore`  |
| **iat** Issued At       | `jwt.issuedAt`   |
| **exp** Expiration Time | `jwt.expiresAt`  |

#### Custom claims

You can retrieve a custom claim through a subscript and then attempt to convert the value to a specific type.

```swift
if let email = jwt["email"].string {
    print("Email is \(email)")
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
        return self["my_claim"].string
    }
}
```

#### Error handling

If the JWT is malformed the `decode(jwt:)` function will throw a `JWTDecodeError`.

```swift
catch let error as JWTDecodeError {
    print(error)
}
```

## Support Policy

This Policy defines the extent of the support for Xcode, Swift, and platform (iOS, macOS, tvOS, and watchOS) versions in JWTDecode.swift.

### Xcode

The only supported versions of Xcode are those that can be currently used to submit apps to the App Store. Once a Xcode version becomes unsupported, dropping it from JWTDecode.swift **will not be considered a breaking change**, and will be done in a **minor** release.

### Swift

The minimum supported Swift minor version is the one released with the oldest-supported Xcode version. Once a Swift minor becomes unsupported, dropping it from JWTDecode.swift **will not be considered a breaking change**, and will be done in a **minor** release.

### Platforms

Only the last 4 major platform versions are supported, starting from:

- iOS **12**
- macOS **10.15**
- macCatalyst **13**
- tvOS **12**
- watchOS **6.2**

Once a platform version becomes unsupported, dropping it from JWTDecode.swift **will not be considered a breaking change**, and will be done in a **minor** release. For example, iOS 13 will cease to be supported when iOS 17 gets released, and JWTDecode.swift will be able to drop it in a minor release.

In the case of macOS, the yearly named releases are considered a major platform version for the purposes of this Policy, regardless of the actual version numbers.

## Feedback

### Contributing

We appreciate feedback and contribution to this repo! Before you get started, please see the following:

- [Auth0's general contribution guidelines](https://github.com/auth0/open-source-template/blob/master/GENERAL-CONTRIBUTING.md)
- [Auth0's code of conduct guidelines](https://github.com/auth0/open-source-template/blob/master/CODE-OF-CONDUCT.md)
- [JWTDecode.swift's contribution guide](CONTRIBUTING.md)

### Raise an issue

To provide feedback or report a bug, please [raise an issue on our issue tracker](https://github.com/auth0/JWTDecode.swift/issues).

### Vulnerability reporting

Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

---

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
    <source media="(prefers-color-scheme: dark)" srcset="https://cdn.auth0.com/website/sdks/logos/auth0_dark_mode.png" width="150">
    <img alt="Auth0 Logo" src="https://cdn.auth0.com/website/sdks/logos/auth0_light_mode.png" width="150">
  </picture>
</p>

<p align="center">Auth0 is an easy to implement, adaptable authentication and authorization platform. To learn more checkout <a href="https://auth0.com/why-auth0">Why Auth0?</a></p>

<p align="center">This project is licensed under the MIT license. See the <a href="./LICENSE"> LICENSE</a> file for more info.</p>
