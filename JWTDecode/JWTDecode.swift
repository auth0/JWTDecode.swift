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

    init(jwt: String) throws {
        let parts = jwt.componentsSeparatedByString(".")
        guard parts.count == 3 else {
            throw invalidPartCountInJWT(jwt, parts: parts.count)
        }

        self.header = try decodeJWTPart(parts[0])
        self.body = try decodeJWTPart(parts[1])
        self.signature = parts[2]
    }

    var expiresAt: NSDate? { return claim("exp") }
    var issuer: String? { return claim("iss") }
    var subject: String? { return claim("sub") }
    var audience: [String]? {
        guard let aud: String = claim("aud") else {
            return claim("aud")
        }
        return [aud]
    }
    var issuedAt: NSDate? { return claim("iat") }
    var notBefore: NSDate? { return claim("nbf") }
    var identifier: String? { return claim("jti") }

    private func claim(name: String) -> NSDate? {
        guard let timestamp:Double = claim(name) else {
            return nil
        }
        return NSDate(timeIntervalSince1970: timestamp)
    }

    var expired: Bool {
        guard let date = self.expiresAt else {
            return false
        }
        return date.compare(NSDate()) != NSComparisonResult.OrderedDescending
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

    do {
        guard let json = try NSJSONSerialization.JSONObjectWithData(bodyData, options: NSJSONReadingOptions()) as? [String: AnyObject] else {
            throw invalidJSONValue(value)
        }
        return json
    } catch {
        throw invalidJSONValue(value)
    }
}