import Foundation

public enum ValidationError: Error {
    case invalidClaim(String)
    case expired
    case nonce
}
