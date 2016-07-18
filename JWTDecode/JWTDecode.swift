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

:param: jwt string value to decode

:returns: a decoded token as an instance of JWT
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
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw invalidPartCountInJWT(jwt: jwt, parts: parts.count)
        }

        self.header = try decodeJWTPart(value: parts[0])
        self.body = try decodeJWTPart(value: parts[1])
        self.signature = parts[2]
        self.stringValue = jwt
    }

    var expiresAt: NSDate? { return claim(name: "exp") }
    var issuer: String? { return claim(name: "iss") }
    var subject: String? { return claim(name: "sub") }
    var audience: [String]? {
        guard let aud: String = claim(name: "aud") else {
            return claim(name: "aud")
        }
        return [aud]
    }
    var issuedAt: NSDate? { return claim(name: "iat") }
    var notBefore: NSDate? { return claim(name: "nbf") }
    var identifier: String? { return claim(name: "jti") }

    private func claim(name: String) -> NSDate? {
        guard let timestamp:Double = claim(name: name) else {
            return nil
        }
        return NSDate(timeIntervalSince1970: timestamp)
    }

    var expired: Bool {
        guard let date = self.expiresAt else {
            return false
        }
        return date.compare(Date()) != ComparisonResult.orderedDescending
    }
}

private func base64UrlDecode(value: String) -> Data? {
    var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
        let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
        base64 = base64.appending(padding)
    }
    return Data(base64Encoded: base64)
}

private func decodeJWTPart(value: String) throws -> [String: AnyObject] {
    guard let bodyData = base64UrlDecode(value: value) else {
        throw invalidBase64UrlValue(value: value)
    }

    do {
        guard let json = try JSONSerialization.jsonObject(with: bodyData, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
            throw invalidJSONValue(value: value)
        }
        return json
    } catch {
        throw invalidJSONValue(value: value)
    }
}
