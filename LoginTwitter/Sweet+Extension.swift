import Foundation
import Sweet

extension Sweet {
  static func updateUserBearerToken() async throws {
    let refreshToken = Secret.refreshToken!
    let response = try await TwitterOAuth2().getRefreshUserBearerToken(refreshToken: refreshToken)

    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds

    let expireDate = Calendar.current.date(byAdding: dateComponent, to: Date())!

    Secret.refreshToken = response.refreshToken
    Secret.userBearerToken = response.bearerToken
    Secret.expireDate = expireDate
  }

  init() async throws {
    let expireDate = Secret.expireDate!

    if expireDate < Date() {
      try await Sweet.updateUserBearerToken()
    }

    let userBearerToken = Secret.userBearerToken!

    let appBearerToken = ""

    self.init(app: appBearerToken, user: userBearerToken, session: .shared)
    self.tweetFields = [.id, .text, .attachments, .authorID, .contextAnnotations, .createdAt, .entities, .geo, .replyToUserID, .lang, .possiblySensitive, .referencedTweets, .replySettings, .source, .withheld, .publicMetrics]

    self.mediaFields = [.mediaKey, .type, .height, .publicMetrics, .duration_ms, .previewImageURL, .url, .width, .altText]
  }
}
