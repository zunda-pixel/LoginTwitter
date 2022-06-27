import Foundation
import KeychainAccess
import Sweet

struct Secret {
  
  static let callBackURL: URL = .init(string: "tuna://")!

  private static let expireDateKey = "expireDate"
  private static let refreshTokenKey = "refreshToken"
  private static let userBearerTokenKey = "userBearerToken"
  private static let challengeKey = "challenge"
  private static let stateKey = "state"

  private static let dateFormatter = Sweet.TwitterDateFormatter()

  private static let userDefaults = UserDefaults()
  private static let keychain = Keychain()

  static func removeChallenge() throws {
    try keychain.remove(challengeKey)
  }

  static func removeState() throws {
    try keychain.remove(stateKey)
  }

  static var challenge: String? {
    get {
      let challenge = keychain[challengeKey]
      return challenge
    }
    set {
      keychain[challengeKey] = newValue
    }
  }

  static var state: String? {
    get {
      let state = keychain[stateKey]
      return state
    }
    set {
      keychain[stateKey] = newValue
    }
  }

  static var userBearerToken: String? {
    get { keychain[userBearerTokenKey] }
    set { keychain[userBearerTokenKey] = newValue }
  }

  static var refreshToken: String? {
    get { keychain[refreshTokenKey] }
    set { keychain[refreshTokenKey] = newValue }
  }

  static var expireDate: Date? {
    get {
      guard let expireDateString = userDefaults.string(forKey: expireDateKey) else { return nil }

      let expireDate = dateFormatter.date(from: expireDateString)!

      return expireDate
    }
    set {
      guard let newValue else { return }
      let expireDateString = dateFormatter.string(from: newValue)
      userDefaults.set(expireDateString, forKey: expireDateKey)
    }
  }
}
