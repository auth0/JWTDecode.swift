import Foundation

/// A decoded JWT.
///
/// ## See Also
///
/// - [JWT.io](https://jwt.io)
/// - [Validate JSON Web Tokens](https://auth0.com/docs/secure/tokens/json-web-tokens/validate-json-web-tokens)
/// - [Validate ID Tokens](https://auth0.com/docs/secure/tokens/id-tokens/validate-id-tokens)
public protocol JWT {

    /// Contents of the header part.
    var header: [String: Any] { get }

    /// Contents of the body part (claims).
    var body: [String: Any] { get }

    /// Signature part.
    var signature: String? { get }

    /// JWT string value.
    var string: String { get }

    /// Value of the `exp` claim, if available.
    var expiresAt: Date? { get }

    /// Value of the `iss` claim, if available.
    var issuer: String? { get }

    /// Value of the `sub` claim, if available.
    var subject: String? { get }

    /// Value of the `aud` claim, if available.
    var audience: [String]? { get }

    /// Value of the `iat` claim, if available.
    var issuedAt: Date? { get }

    /// Value of the `nbf` claim, if available.
    var notBefore: Date? { get }

    /// Value of the `jti` claim, if available.
    var identifier: String? { get }

    /// Checks if the JWT is currently expired using the `exp` claim. If the claim is not present the JWT will be
    /// deemed unexpired.
    var expired: Bool { get }

}

public extension JWT {

    /// Returns a claim by its name.
    ///
    /// ```swift
    /// if let email = jwt.claim(name: "email").string {
    ///     print("Email is \(email)")
    /// }
    /// ```
    ///
    /// - Parameter name: Name of the claim in the JWT.
    /// - Returns: A ``Claim`` instance.
    func claim(name: String) -> Claim {
        let value = self.body[name]
        return Claim(value: value)
    }

    /// Returns a claim by its name.
    ///
    /// ```swift
    /// if let email = jwt["email"].string {
    ///     print("Email is \(email)")
    /// }
    /// ```
    ///
    /// - Parameter claim: Name of the claim in the JWT.
    /// - Returns: A ``Claim`` instance.
    subscript(claim: String) -> Claim {
        return self.claim(name: claim)
    }

}
