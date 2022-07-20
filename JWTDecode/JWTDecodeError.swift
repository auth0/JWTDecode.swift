import Foundation

/// A decoding error due to a malformed JWT.
public enum JWTDecodeError: LocalizedError, CustomDebugStringConvertible {
    /// When either the header or body parts cannot be Base64URL-decoded.
    case invalidBase64URL(String)

    /// When either the decoded header or body is not a valid JSON object.
    case invalidJSON(String)

    /// When the JWT doesn't have the required amount of parts (header, body, and signature).
    case invalidPartCount(String, Int)

    /// Description of the error.
    ///
    /// - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
    public var localizedDescription: String { return self.debugDescription }

    /// Description of the error.
    ///
    /// - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
    public var errorDescription: String? { return self.debugDescription }

    /// Description of the error.
    ///
    /// - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
    public var debugDescription: String {
        switch self {
        case .invalidJSON(let value):
            return "Failed to parse JSON from Base64URL value \(value)."
        case .invalidPartCount(let jwt, let parts):
            return "The JWT \(jwt) has \(parts) parts when it should have 3 parts."
        case .invalidBase64URL(let value):
            return "Failed to decode Base64URL value \(value)."
        }
    }
}
