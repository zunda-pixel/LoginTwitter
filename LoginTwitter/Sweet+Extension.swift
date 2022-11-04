import Foundation
import Sweet

extension Sweet {
  static func updateUserBearerToken() async throws {
    let refreshToken = Secret.refreshToken!
    let response = try await Sweet.OAuth2().refreshUserBearerToken(with: refreshToken)

    let expireDate = Date.now.addingTimeInterval(TimeInterval(response.expiredSeconds))

    Secret.refreshToken = response.refreshToken
    Secret.userBearerToken = response.bearerToken
    Secret.expireDate = expireDate
  }

  init() async throws {
    let expireDate = Secret.expireDate!

    if expireDate < .now {
      try await Sweet.updateUserBearerToken()
    }

    let token: Sweet.AuthorizationType = .oAuth2user(token: Secret.userBearerToken!)

    self.init(token: token, config: .default)
    self.tweetFields = Sweet.TweetField.allCases.filter { $0 != .privateMetrics && $0 != .promotedMetrics && $0 != .organicMetrics }
    self.mediaFields = Sweet.MediaField.allCases.filter { $0 != .privateMetrics && $0 != .promotedMetrics && $0 != .organicMetrics}
  }
}

extension Sweet.OAuth2 {
  init() {
    self.init(clientID: Secret.clientID, clientSecret: Secret.clientSecretKey)
  }
}
