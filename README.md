# JWTDecode.swift

![CircleCI](https://img.shields.io/circleci/build/github/auth0/JWTDecode.swift?style=flat)
![Version](https://img.shields.io/cocoapods/v/JWTDecode.svg?style=flat)
![Coverage Status](https://img.shields.io/codecov/c/github/auth0/JWTDecode.swift/master.svg?style=flat)
![License](https://img.shields.io/github/license/Auth0/JWTDecode.swift.svg?style=flat)

Easily decode a [JWT](https://jwt.io/) and access the claims it contains.

> ⚠️ This library doesn't validate the JWT. Any well-formed JWT can be decoded from Base64URL.

**Migrating from v2? Check the [Migration Guide](V3_MIGRATION_GUIDE.md).**

---

## Table of Contents

- [**Requirements**](#requirements)
- [**Installation**](#installation)
  + [Swift Package Manager](#swift-package-manager)
  + [Cocoapods](#cocoapods)
  + [Carthage](#carthage)
- [**Usage**](#usage)
  + [JWT parts](#jwt-parts)
  + [Registered claims](#registered-claims)
  + [Custom claims](#custom-claims)
  + [Error handling](#error-handling)
- [**Support Policy**](#support-policy)
- [**Issue Reporting**](#issue-reporting)
- [**What is Auth0?**](#what-is-auth0)
- [**License**](#license)

## Requirements

- iOS 12+ / macOS 10.15+ / tvOS 12.0+ / watchOS 6.2+
- Xcode 13.x / 14.x
- Swift 5.5+

> ⚠️ Check the [Support Policy](#support-policy) to learn when dropping Xcode, Swift, and platform versions will not be considered a **breaking change**.

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

**See all the available features in the [API documentation ↗](https://auth0.github.io/JWTDecode.swift/documentation/jwtdecode/)**

1. Import the framework

```swift
import JWTDecode
```

2. Decode the token

```swift
let jwt = try decode(jwt: token)    
```

### JWT parts

| Part               | Property        |
|:-------------------|:----------------|
| Header dictionary  | `jwt.header`    |
| Claims in JWT body | `jwt.body`      |
| JWT signature      | `jwt.signature` |

### Registered claims

| Claim                   | Property         |
|:------------------------|:-----------------|
| **aud** Audience        | `jwt.audience`   |
| **sub** Subject         | `jwt.subject`    |
| **jti** JWT ID          | `jwt.identifier` |
| **iss** Issuer          | `jwt.issuer`     |
| **nbf** Not Before      | `jwt.notBefore`  |
| **iat** Issued At       | `jwt.issuedAt`   |
| **exp** Expiration Time | `jwt.expiresAt`  |

### Custom claims

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

### Error handling

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
- Catalyst **13**
- tvOS **12**
- watchOS **6.2**

Once a platform version becomes unsupported, dropping it from JWTDecode.swift **will not be considered a breaking change**, and will be done in a **minor** release. For example, iOS 12 will cease to be supported when iOS 16 gets released, and JWTDecode.swift will be able to drop it in a minor release.

In the case of macOS, the yearly named releases are considered a major platform version for the purposes of this Policy, regardless of the actual version numbers.

## Issue Reporting

For general support or usage questions, use the [Auth0 Community](https://community.auth0.com/c/sdks/5) forums or raise a [support ticket](https://support.auth0.com/). Only [raise an issue](https://github.com/auth0/JWTDecode.swift/issues) if you have found a bug or want to request a feature.

**Do not report security vulnerabilities on the public GitHub issue tracker.** The [Responsible Disclosure Program](https://auth0.com/responsible-disclosure-policy) details the procedure for disclosing security issues.

## What is Auth0?

Auth0 helps you to:

- Add authentication with [multiple sources](https://auth0.com/docs/authenticate/identity-providers), either social identity providers such as **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce** (amongst others), or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS, or any SAML identity provider**.
- Add authentication through more traditional **[username/password databases](https://auth0.com/docs/authenticate/database-connections/custom-db)**.
- Add support for **[linking different user accounts](https://auth0.com/docs/manage-users/user-accounts/user-account-linking)** with the same user.
- Support for generating signed [JSON web tokens](https://auth0.com/docs/secure/tokens/json-web-tokens) to call your APIs and **flow the user identity** securely.
- Analytics of how, when, and where users are logging in.
- Pull data from other sources and add it to the user profile through [JavaScript Actions](https://auth0.com/docs/customize/actions).

**Why Auth0?** Because you should save time, be happy, and focus on what really matters: building your product.

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE) file for more info.

---

[Go up ⤴](#table-of-contents)
