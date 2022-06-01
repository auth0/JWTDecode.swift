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

    let header: [String: Any]
    let body: [String: Any]
    let signature: String?
    let string: String

    init(jwt: String) throws {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw DecodeError.invalidPartCount(jwt, parts.count)
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

/**
 *  JWT Claim
 */
public struct Claim {

    /// raw value of the claim
    let value: Any?

    /// original claim value
    public var rawValue: Any? {
        return self.value
    }

    /// value of the claim as `String`
    public var string: String? {
        return self.value as? String
    }

     /// value of the claim as `Bool`
    public var boolean: Bool? {
        return self.value as? Bool
    }

    /// value of the claim as `Double`
    public var double: Double? {
        var double: Double?
        if let string = self.string {
            double = Double(string)
        } else if self.boolean == nil {
            double = self.value as? Double
        }
        return double
    }

    /// value of the claim as `Int`
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

    /// value of the claim as `NSDate`
    public var date: Date? {
        guard let timestamp: TimeInterval = self.double else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }

    /// value of the claim as `[String]`
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
        throw DecodeError.invalidBase64Url(value)
    }

    guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
        throw DecodeError.invalidJSON(value)
    }

    return payload
}
