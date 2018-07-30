// JWTValidate.swift
//
// Copyright (c) 2018 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol ValidatorJWT {
    var issuer: String { get }
    var audience: String { get }
    var leeWay: UInt { get }
    var jwksURI: String { get }
    var jwksCache: UInt { get }

    func validate(_ jwt: JWT, nonce: String?, callback: (ValidationError?) -> Void)
}

public struct IDTokenValidation: ValidatorJWT {
    /// Name of the issuer of the token that should match the `iss` claim
    public var issuer: String

    /// Identifies the recipients that the JWT is intended for and should match the `aud` claim
    public var audience: String

    /// Number of seconds that the clock can be out of sync while validating expiration
    public var leeWay: UInt

    /// Direct URI to fetch the JSON Web Key Set (JWKS).
    public var jwksURI: String

    /// Cache for JSON Web Token Keys for given minutes. By default it has no cache
    public var jwksCache: UInt

    public func validate(_ jwt: JWT, nonce: String?, callback: (ValidationError?) -> Void) {
        // Create Key
    }

}

public enum ValidationError {
    case signature
    case issuer
    case audience
    case expired
    case notBefore
}
