// JWTDecode.swift
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
 Decodes a JWT token into an object that holds the decoded body (along with token header and signature parts).
 If the token cannot be decoded a `NSError` will be thrown.

 - parameter jwt: jwt string value to decode

 - throws: an error if the JWT cannot be decoded

 - returns: a decoded token as an instance of JWT
 */
public func decode(jwt: String) throws -> JWT {
    return try DecodedJWT(jwt: jwt)
}

struct DecodedJWT: JWT {

    let header: [String: AnyObject]
    let body: [String: AnyObject]
    let signature: String?
    let stringValue: String

    init(jwt: String) throws {
        let parts = jwt.componentsSeparatedByString(".")
        guard parts.count == 3 else {
            throw invalidPartCountInJWT(jwt, parts: parts.count)
        }

        self.header = try decodeJWTPart(parts[0])
        self.body = try decodeJWTPart(parts[1])
        self.signature = parts[2]
        self.stringValue = jwt
    }

    var expiresAt: NSDate? { return claim(name: "exp").date }
    var issuer: String? { return claim(name: "iss").string }
    var subject: String? { return claim(name: "sub").string }
    var audience: [String]? { return claim(name: "aud").array }
    var issuedAt: NSDate? { return claim(name: "iat").date }
    var notBefore: NSDate? { return claim(name: "nbf").date }
    var identifier: String? { return claim(name: "jti").string }

    var expired: Bool {
        guard let date = self.expiresAt else {
            return false
        }
        return date.compare(NSDate()) != NSComparisonResult.OrderedDescending
    }
}

/**
 *  JWT Claim
 */
public struct Claim {

        /// raw value of the claim
    let value: AnyObject?

        /// value of the claim as `String`
    public var string: String? {
        return self.value as? String
    }

        /// value of the claim as `Double`
    public var double: Double? {
        let double: Double?
        if let string = self.string {
            double = Double(string)
        } else {
            double = self.value as? Double
        }
        return double
    }

        /// value of the claim as `Int`
    public var integer: Int? {
        let integer: Int?
        if let string = self.string {
            integer = Int(string)
        } else {
            integer = self.value as? Int
        }
        return integer
    }

        /// value of the claim as `NSDate`
    public var date: NSDate? {
        guard let timestamp:NSTimeInterval = self.double else { return nil }
        return NSDate(timeIntervalSince1970: timestamp)
    }

        /// value of the claim as `[String]`
    public var array: [String]? {
        if let array = value as? [String] {
            return array
        }
        if let value = self.string {
            return [value]
        }
        return nil
    }
}

private func base64UrlDecode(value: String) -> NSData? {
    var base64 = value
        .stringByReplacingOccurrencesOfString("-", withString: "+")
        .stringByReplacingOccurrencesOfString("_", withString: "/")
    let length = Double(base64.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
        let padding = "".stringByPaddingToLength(Int(paddingLength), withString: "=", startingAtIndex: 0)
        base64 = base64.stringByAppendingString(padding)
    }
    return NSData(base64EncodedString: base64, options: .IgnoreUnknownCharacters)
}

private func decodeJWTPart(value: String) throws -> [String: AnyObject] {
    guard let bodyData = base64UrlDecode(value) else {
        throw invalidBase64UrlValue(value)
    }

    guard let json = try? NSJSONSerialization.JSONObjectWithData(bodyData, options: []), let payload = json as? [String: AnyObject] else {
        throw invalidJSONValue(value)
    }

    return payload
}