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
    var header: [String: AnyObject] { get }
    /// token body part values or token claims
    var body: [String: AnyObject] { get }
    /// token signature part
    var signature: String? { get }

    /// value of `exp` claim if available
    var expiresAt: NSDate? { get }
    /// value of `iss` claim if available
    var issuer: String? { get }
    /// value of `sub` claim if available
    var subject: String? { get }
    /// value of `aud` claim if available
    var audience: [String]? { get }
    /// value of `iat` claim if available
    var issuedAt: NSDate? { get }
    /// value of `nbf` claim if available
    var notBefore: NSDate? { get }
    /// value of `jti` claim if available
    var identifier: String? { get }

    /// Checks if the token is currently expired using the `exp` claim. If there is no claim present it will deem the token not expired
    var expired: Bool { get }
}

public extension JWT {
    /**
    Returns a specific claim by its name whose value if of type `T`.

    :param: name of the claim to return

    :returns: the value of the claim as the generic type `T` if available
    */
    public func claim<T>(name: String) -> T? {
        return self.body[name] as? T
    }
}