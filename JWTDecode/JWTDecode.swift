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

    let header: [String: Any]
    let body: [String: Any]
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
        guard let date = self.expiresAt else {
            return false
        }
        return date.compare(Date()) != ComparisonResult.orderedDescending
    }
}

/// A JWT claim.
public struct Claim {

    /// Raw claim value.
    let value: Any?

    /// Original claim value.
    public var rawValue: Any? {
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
        throw JWTDecodeError.invalidBase64URL(value)
    }

    guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
          let payload = json as? [String: Any] else {
        throw JWTDecodeError.invalidJSON(value)
    }

    return payload
}
