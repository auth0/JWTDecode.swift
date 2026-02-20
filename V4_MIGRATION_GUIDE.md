# v4 Migration Guide

As expected with a major release, JWTDecode.swift v4 contains breaking changes. Please review this guide thoroughly to understand the changes required to migrate your application to v4.

## Table of Contents

- [**Swift Concurrency Support**](#swift-concurrency-support)
- [**Types Changed**](#types-changed)
- [**Properties Changed**](#properties-changed)
- [**New Features**](#new-features)
- [**Error Types**](#error-types)

## Swift Concurrency Support

All public types now conform to `Sendable` for full Swift 6 concurrency compatibility. This ensures safe usage across concurrency boundaries, actors, and async contexts.

## Types Changed

### JWT Protocol

The `JWT` protocol now requires `Sendable` conformance.

**Before (v3):**
```swift
public protocol JWT {
    var header: [String: Any] { get }
    var body: [String: Any] { get }
    // ...
}
```

**After (v4):**
```swift
public protocol JWT: Sendable {
    var header: [String: any Sendable] { get }
    var body: [String: any Sendable] { get }
    // ...
}
```

### Claim Struct

The `Claim` struct now conforms to `Sendable` and uses `any Sendable` for value types.

**Before (v3):**
```swift
public struct Claim {
    let value: Any?
    public var rawValue: Any? { /* ... */ }
}
```

**After (v4):**
```swift
public struct Claim: Sendable {
    let value: (any Sendable)?
    public var rawValue: (any Sendable)? { /* ... */ }
}
```

## Properties Changed

### JWT Header and Body

If you directly access `header` or `body` properties, update the type annotations:

**Before (v3):**
```swift
let header: [String: Any] = jwt.header
let body: [String: Any] = jwt.body
```

**After (v4):**
```swift
let header: [String: any Sendable] = jwt.header
let body: [String: any Sendable] = jwt.body
```

### Claim Raw Value

If you directly access `rawValue`, update the type annotation:

**Before (v3):**
```swift
let customClaim: Any? = jwt["custom"].rawValue
```

**After (v4):**
```swift
let customClaim: (any Sendable)? = jwt["custom"].rawValue
```

### Most Common Usage (No Changes Required)

For most users, no changes are needed:

```swift
//  These continue to work without changes
let jwt = try decode(jwt: token)
let email = jwt["email"].string
let userId = jwt["sub"].string
let exp = jwt.expiresAt
let isExpired = jwt.expired
```

## New Features

### Claim Data Property

A new `data` property is available for complex claims (arrays and dictionaries only):

```swift
// Returns Data for arrays and dictionaries
let data = jwt["custom_object"].data

// Returns nil for primitives (use .string, .integer, etc. instead)
let primitiveData = jwt["email"].data // nil
```

### Claim Decode Method

Decode complex claims directly to `Decodable` types:

```swift
struct Address: Decodable {
    let street: String
    let city: String
}

// Decode a custom claim
let address = try jwt["address"].decode(Address.self)

// With custom decoder configuration
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let userInfo = try jwt["user_info"].decode(UserInfo.self, using: decoder)
```

## Error Types

### New Error Case

A new error case `claimDecodingFailed` has been added for claim decoding failures:

```swift
public enum JWTDecodeError: LocalizedError, CustomDebugStringConvertible, Sendable {
    case invalidBase64URL(String)
    case invalidJSON(String)
    case invalidPartCount(String, Int)
    case claimDecodingFailed(String) // New in v4
}
```

This error is thrown by the `Claim.decode<T: Decodable>()` method when:
- A claim is not found or has a nil value
- A claim value is a primitive type when an object/array is expected (use `.string`, `.integer`, `.boolean`, etc. instead)
- Claim serialization to JSON data fails

**Example:**
```swift
do {
    let address = try jwt["address"].decode(Address.self)
} catch JWTDecodeError.claimDecodingFailed(let message) {
    print("Decoding failed: \(message)")
}
