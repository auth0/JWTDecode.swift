// A0JWT.swift
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

/// Decodes a JWT
@objc(A0JWT)
public class _JWT: NSObject {

    var jwt: JWT

    init(jwt: JWT) {
        self.jwt = jwt
    }

    /// token header part
    @objc public var header: [String: Any] {
        return self.jwt.header
    }

    /// token body part or claims
    @objc public var body: [String: Any] {
        return self.jwt.body
    }

    /// token signature part
    @objc public var signature: String? {
        return self.jwt.signature
    }

    /// value of the `exp` claim
    @objc public var expiresAt: Date? {
        return self.jwt.expiresAt as Date?
    }

    /// value of the `expired` field
    @objc public var expired: Bool {
        return self.jwt.expired
    }

    /**
    Creates a new instance of `A0JWT` and decodes the given jwt token.

    :param: jwtValue of the token to decode

    :returns: a new instance of `A0JWT` that holds the decode token
    */
    @objc public class func decode(jwt jwtValue: String) throws -> _JWT {
        let jwt = try DecodedJWT(jwt: jwtValue)
        return _JWT(jwt: jwt)
    }
}
