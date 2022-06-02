import Foundation

/// IDTokenValidation will validate claims
public struct IDTokenValidation: ValidatorJWT {

    /// `iss` claim value
    public let issuer: String

    /// `aud` claim value
    public let audience: String

    /// Initialiser
    ///
    /// - Parameters:
    ///   - issuer: Expected `iss` claim value
    ///   - audience: Expected `aud` claim value
    public init(issuer: String, audience: String) {
        self.issuer = issuer
        self.audience = audience
    }

    /// Validate a JWT
    ///
    /// - Parameters:
    ///   - jwt: The JWT to validate
    ///   - nonce: (Optional) nonce value
    /// - Returns: Outcome
    public func validate(_ jwt: JWT, nonce: String? = nil) -> ValidationError? {
        guard let jwtAudience = jwt.audience else { return .invalidClaim("aud") }
        if !jwtAudience.contains(audience) { return .invalidClaim("aud")  }
        if issuer != jwt.issuer { return .invalidClaim("iss") }
        if jwt.expired { return .expired }
        if let jwtNonce = jwt.claim(name: "nonce").string {
            guard let nonce = nonce, nonce == jwtNonce else { return .nonce }
        }
        return nil
    }
}
