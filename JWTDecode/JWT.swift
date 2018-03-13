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

@available(*, deprecated, message: "Will be removed in a future version", renamed: "JWT()")
public func decode(jwt: String) throws -> JWT {
    return try JWT(jwt)
}

public struct JWT: Codable, CustomStringConvertible {
    /// token header part contents
    public let header: [String: Any]
    /// token body part values or token claims
    public let body: [String: Any]
    /// token signature part
    public let signature: String?
    /// jwt string value
    public let string: String
    /**
     Decodes a JWT token into an object that holds the decoded body (along with token header and signature parts).
     If the token cannot be decoded a `NSError` will be thrown.
     
     - parameter jwt: jwt string value to decode
     
     - throws: an error if the JWT cannot be decoded
     */
    public init(_ jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw DecodeError.invalidPartCount(jwt, parts.count)
        }

        self.header = try decodeJWTPart(parts[0])
        self.body = try decodeJWTPart(parts[1])
        self.signature = parts[2]
        self.string = jwt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let jwt = try container.decode(String.self)
        try self.init(jwt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }

    /// value of `exp` claim if available
    public var expiresAt: Date? { return claim(name: "exp").date }
    /// value of `iss` claim if available
    public var issuer: String? { return claim(name: "iss").string }
    /// value of `sub` claim if available
    public var subject: String? { return claim(name: "sub").string }
    /// value of `aud` claim if available
    public var audience: [String]? { return claim(name: "aud").array }
    /// value of `iat` claim if available
    public var issuedAt: Date? { return claim(name: "iat").date }
    /// value of `nbf` claim if available
    public var notBefore: Date? { return claim(name: "nbf").date }
    /// value of `jti` claim if available
    public var identifier: String? { return claim(name: "jti").string }
    /// Checks if the token is currently expired using the `exp` claim. If there is no claim present it will deem the token not expired
    public var expired: Bool {
        guard let date = self.expiresAt else {
            return false
        }
        return date.compare(Date()) != ComparisonResult.orderedDescending
    }

    /**
     Return a claim by it's name
     
     - parameter name: name of the claim in the JWT
     
     - returns: a claim of the JWT
     */
    public func claim(name: String) -> Claim {
        let value = self.body[name]
        return Claim(value: value)
    }

    public var description: String {
        return string
    }
}

/**
 *  JWT Claim
 */
public struct Claim {

    /// raw value of the claim
    let value: Any?

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
        } else if let double = self.value as? Double {
            integer = Int(double)
        } else {
            integer = self.value as? Int
        }
        return integer
    }

    /// value of the claim as `NSDate`
    public var date: Date? {
        guard let timestamp: TimeInterval = self.double else { return nil }
        return Date(timeIntervalSince1970: timestamp)
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

private func base64UrlDecode(_ value: String) -> Data? {
    var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
        let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
        base64 += padding
    }
    return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
}

private func decodeJWTPart(_ value: String) throws -> [String: Any] {
    guard let bodyData = base64UrlDecode(value) else {
        throw DecodeError.invalidBase64Url(value)
    }

    guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
        throw DecodeError.invalidJSON(value)
    }

    return payload
}
