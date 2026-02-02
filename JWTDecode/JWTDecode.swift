import Foundation

/// Decodes a JWT into an object that holds the decoded body, along with the header and signature.
///
/// ```swift
/// let jwt = try decode(jwt: idToken)
/// ```
///
/// - Parameter jwt: JWT string value to decode.
/// - Throws: A ``JWTDecodeError`` error if the JWT cannot be decoded.
/// - Returns: A ``JWT`` value.
/// - Important: This method doesn't validate the JWT. Any well-formed JWT can be decoded from Base64URL.
///
/// ## See Also
///
/// - [JWT.io](https://jwt.io)
/// - [Validate JSON Web Tokens](https://auth0.com/docs/secure/tokens/json-web-tokens/validate-json-web-tokens)
/// - [Validate ID Tokens](https://auth0.com/docs/secure/tokens/id-tokens/validate-id-tokens)
public func decode(jwt: String) throws -> JWT {
    return try DecodedJWT(jwt: jwt)
}

struct DecodedJWT: JWT {

    let header: [String: any Sendable]
    let body: [String: any Sendable]
    let signature: String?
    let string: String

    init(jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw JWTDecodeError.invalidPartCount(jwt, parts.count)
        }

        self.header = try decodeJWTPart(parts[0])
        self.body = try decodeJWTPart(parts[1])
        self.signature = parts[2]
        self.string = jwt
    }

    var expiresAt: Date? { return claim(name: "exp").date }
    var issuer: String? { return claim(name: "iss").string }
    var subject: String? { return claim(name: "sub").string }
    var audience: [String]? { return claim(name: "aud").array }
    var issuedAt: Date? { return claim(name: "iat").date }
    var notBefore: Date? { return claim(name: "nbf").date }
    var identifier: String? { return claim(name: "jti").string }

    var expired: Bool {
        return self.expires(before: Date())
    }

    func expires(in seconds: Int) -> Bool {
        let expireDate = Date(timeIntervalSinceNow: TimeInterval(seconds))
        return self.expires(before: expireDate)
    }

    func expires(before expireDate: Date) -> Bool {
        guard let date = self.expiresAt else {
            return false
        }

        return date.compare(expireDate) != ComparisonResult.orderedDescending
    }

}

/// A JWT claim.
public struct Claim: Sendable {

    /// Raw claim value.
    let value: (any Sendable)?

    /// Original claim value.
    public var rawValue: (any Sendable)? {
        return self.value
    }

    /// Value of the claim as `String`.
    public var string: String? {
        return self.value as? String
    }

     /// Value of the claim as `Bool`.
    public var boolean: Bool? {
        // This is necessary because Core Foundation's JSON deserialization turns JSON booleans into CFBoolean values,
        // which get wrapped in NSNumber –a Foundation type. But integers and floats also get wrapped in NSNumber, and
        // thus Swift will happily bridge a NSNumber containing a '1' or '1.0' to a 'true' Bool, and a '0' or '0.0' to
        // a 'false' Bool.
        // So, to find out if the deserialized claim value is really a CFBoolean or not, we need to bypass its NSNumber
        // wrapper and check its Core Foundation type directly. We do so by comparing its Core Foundation type ID to
        // that of CFBoolean.
        if let value = self.value as CFTypeRef?, CFGetTypeID(value) == CFBooleanGetTypeID() {
            return self.value as? Bool
        }
        return nil
    }

    /// Value of the claim as `Double`.
    public var double: Double? {
        var double: Double?
        if let string = self.string {
            double = Double(string)
        } else if self.boolean == nil {
            double = self.value as? Double
        }
        return double
    }

    /// Value of the claim as `Int`.
    public var integer: Int? {
        var integer: Int?
        if let string = self.string {
            integer = Int(string)
        } else if let double = self.double {
            integer = Int(double)
        } else if self.boolean == nil {
            integer = self.value as? Int
        }
        return integer
    }

    /// Value of the claim as `Date`.
    public var date: Date? {
        guard let timestamp: TimeInterval = self.double else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    /// Value of the claim as `[String]`.
    public var array: [String]? {
        if let array = self.value as? [String] {
            return array
        }
        if let value = self.string {
            return [value]
        }
        return nil
    }

    /// Value of the claim as `Data`.
    /// Useful for decoding complex claims with `JSONDecoder`.
    /// Returns `nil` for primitive values (use `.string`, `.integer`, etc. instead).
    ///
    /// ```swift
    /// if let data = jwt["custom_claim"].data {
    ///     let myObject = try? JSONDecoder().decode(MyType.self, from: data)
    /// }
    /// ```
    public var data: Data? {
        guard let value = self.value else { return nil }
        // Only serialize arrays and dictionaries
        // Primitives should use typed accessors (.string, .integer, etc.)
        guard value is [Any] || value is [String: Any] else {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: value, options: [])
    }

    /// Decodes the claim value to a `Decodable` type using the provided `JSONDecoder`.
    ///
    /// ```swift
    /// struct Address: Decodable {
    ///     let street: String
    ///     let city: String
    /// }
    ///
    /// if let address = try? jwt["address"].decode(Address.self) {
    ///     print(address.street)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to decode to.
    ///   - decoder: The `JSONDecoder` to use. Defaults to a new instance.
    /// - Returns: The decoded value.
    /// - Throws: `JWTDecodeError.claimDecodingFailed` if the claim cannot be decoded.
    public func decode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let value = self.value else {
            throw JWTDecodeError.claimDecodingFailed("Claim not found or has nil value")
        }
        guard value is [Any] || value is [String: Any] else {
            throw JWTDecodeError.claimDecodingFailed("Claim value must be an object or array. Use .string, .integer, .boolean, etc. for primitive values")
        }
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            throw JWTDecodeError.claimDecodingFailed("Failed to serialize claim value to JSON data")
        }
        return try decoder.decode(type, from: data)
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

private func decodeJWTPart(_ value: String) throws -> [String: any Sendable] {
    guard let bodyData = base64UrlDecode(value) else {
        throw JWTDecodeError.invalidBase64URL(value)
    }

    guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
          let payload = json as? [String: any Sendable] else {
        throw JWTDecodeError.invalidJSON(value)
    }

    return payload
}
