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
