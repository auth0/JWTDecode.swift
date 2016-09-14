// JWT.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

/**
*  Protocol that defines what a decoded JWT token should be.
*/
public protocol JWT {
    /// token header part contents
    var header: [String: Any] { get }
    /// token body part values or token claims
    var body: [String: Any] { get }
    /// token signature part
    var signature: String? { get }
    /// jwt string value
    var string: String { get }


    /// value of `exp` claim if available
    var expiresAt: Date? { get }
    /// value of `iss` claim if available
    var issuer: String? { get }
    /// value of `sub` claim if available
    var subject: String? { get }
    /// value of `aud` claim if available
    var audience: [String]? { get }
    /// value of `iat` claim if available
    var issuedAt: Date? { get }
    /// value of `nbf` claim if available
    var notBefore: Date? { get }
    /// value of `jti` claim if available
    var identifier: String? { get }

    /// Checks if the token is currently expired using the `exp` claim. If there is no claim present it will deem the token not expired
    var expired: Bool { get }
}

public extension JWT {

    /**
     Return a claim by it's name

     - parameter name: name of the claim in the JWT

     - returns: a claim of the JWT
     */
    public func claim(name: String) -> Claim {
        let value = self.body[name]
        return Claim(value: value)
    }
}
