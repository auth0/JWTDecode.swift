import Foundation

/// A decoding error due to a malformed JWT.
public enum JWTDecodeError: LocalizedError, CustomDebugStringConvertible, Sendable {
    /// When either the header or body parts cannot be Base64URL-decoded.
    case invalidBase64URL(String)

    /// When either the decoded header or body is not a valid JSON object.
    case invalidJSON(String)

    /// When the JWT doesn't have the required amount of parts (header, body, and signature).
    case invalidPartCount(String, Int)

    /// When a claim value cannot be decoded to the requested type.
    case claimDecodingFailed(String)

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
        case .invalidJSON:
            return "Failed to parse JSON from a Base64URL JWT part."
        case .invalidPartCount(_, let parts):
            return "The JWT has \(parts) parts when it should have 3 parts."
        case .invalidBase64URL:
            return "Failed to decode a Base64URL JWT part."
        case .claimDecodingFailed(let message):
            return "Failed to decode claim: \(message)"
        }
    }
}
