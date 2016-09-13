// Errors.swift
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
JWT decode error codes

- InvalidBase64UrlValue: when either the header or body parts cannot be base64 decoded
- InvalidJSONValue:      when either the header or body decoded values is not a valid JSON object
- InvalidPartCount:      when the token doesnt have the required amount of parts (header, body and signature)
*/
public enum DecodeErrorCode: Int {
    case invalidBase64UrlValue
    case invalidJSONValue
    case invalidPartCount
}

private let ErrorDomain = "com.auth0.JWTDecode"

private func error(withCode code: DecodeErrorCode, description: String) -> NSError {
    return NSError(domain: ErrorDomain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: description])
}

func invalidPartCount(inJWT jwt: String, parts: Int) -> Error {
    return error(withCode: .invalidPartCount, description: NSLocalizedString("Malformed jwt token \(jwt) has \(parts) parts when it should have 3 parts", comment: "Invalid amount of jwt parts"))
}

func invalidBase64Url(value: String) -> Error {
    return error(withCode: .invalidBase64UrlValue, description: NSLocalizedString("Malformed jwt token, failed to decode base64Url value \(value)", comment: "Invalid JWT token base64Url value"))
}

func invalidJSON(value: String) -> Error {
    return error(withCode: .invalidJSONValue, description: NSLocalizedString("Malformed jwt token, failed to parse JSON value from base64Url \(value)", comment: "Invalid JSON value inside base64Url"))
}
