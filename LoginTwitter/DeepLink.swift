import Foundation
import Sweet

struct DeepLink {
  func loginTwitter(_ url: URL) async throws {
    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

    guard let queryItems = components.queryItems,
      let savedState = Secret.state
    else { return }

    if let state = queryItems.first(where: { $0.name == "state" })?.value,
      let code = queryItems.first(where: { $0.name == "code" })?.value,
      state == savedState {
      try await saveOAuthData(code: code)
    }
  }

  private func saveOAuthData(code: String) async throws {
    guard let challenge = Secret.challenge else {
      return
    }

    let response = try await Sweet.OAuth2().getUserBearerToken(code: code, callBackURL: Secret.callBackURL, challenge: challenge)

    Secret.userBearerToken = response.bearerToken
    Secret.refreshToken = response.refreshToken

    var dateComponent = DateComponents()
    dateComponent.second = response.expiredSeconds

    let expireDate = Calendar.current.date(byAdding: dateComponent, to: Date())!
    Secret.expireDate = expireDate

    try Secret.removeState()
    try Secret.removeChallenge()
  }
}
