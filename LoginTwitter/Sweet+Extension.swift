import Foundation
import Sweet

extension Sweet {
  static func updateUserBearerToken() async throws {
    let refreshToken = Secret.refreshToken!
    let response = try await TwitterOAuth2().getRefreshUserBearerToken(refreshToken: refreshToken)

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

    let userBearerToken = Secret.userBearerToken!

    let appBearerToken = ""

    self.init(app: appBearerToken, user: userBearerToken, session: .shared)
    self.tweetFields = Sweet.TweetField.allCases.filter { $0 != .privateMetrics && $0 != .promotedMetrics && $0 != .organicMetrics }
    self.mediaFields = Sweet.MediaField.allCases.filter { $0 != .privateMetrics && $0 != .promotedMetrics && $0 != .organicMetrics}
  }
}
