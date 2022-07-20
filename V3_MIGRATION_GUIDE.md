# v3 Migration Guide

As expected with a major release, JWTDecode.swift v3 contains breaking changes. Please review this guide thorougly to understand the changes required to migrate your application to v3.

## Table of Contents

- [**Supported Languages**](#supported-languages)
  + [Swift](#swift)
  + [Objective-C](#objective-c)
- [**Supported Platform Versions**](#supported-platform-versions)
- [**Types Removed**](#types-removed)
- [**Types Changed**](#types-changed)
- [**Properties Changed**](#properties-changed)

## Supported Languages

### Swift

The minimum supported Swift version is now **5.5**.

### Objective-C

JWTDecode.swift no longer supports Objective-C.

## Supported Platform Versions

The deployment targets for each platform were raised to:

- iOS **12.0**
- macOS **10.15**
- tvOS **12.0**
- watchOS **6.2**

## Types Removed

The built-in ID token validator was removed:

- `ValidatorJWT` protocol
- `ValidationError` enum
- `IDTokenValidation` struct

## Types Changed

The `DecodeError` enum was renamed to `JWTDecodeError`.

## Properties Changed

The `JWTDecodeError.invalidBase64Url` enum case was renamed to `JWTDecodeError.invalidBase64URL`.
