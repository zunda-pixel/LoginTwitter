import SwiftUI
import Sweet

struct LoginView: View {
  @Environment(\.openURL) var openURL
  @State var userBearerToken: String?
  @State var refreshToken: String?
  @State var expireDate: Date?
  @State var me: Sweet.UserModel?

  func getRandomString() -> String {
    let challenge = SecurityRandom.secureRandomBytes(count: 10)
    return challenge.reduce(into: "") { $0 = $0 + "\($1)" }
  }

  func getAuthorizeURL() -> URL {
    let challenge = getRandomString()
    Secret.challenge = challenge

    let state = getRandomString()
    Secret.state = state

    let url = TwitterOAuth2().getAuthorizeURL(
      scopes: TwitterScope.allCases,
      callBackURL: Secret.callBackURL,
      challenge: challenge,
      state: state
    )

    return url
  }

  func callBackURL(url: URL) async {
    try? await DeepLink().loginTwitter(url)
    getSecureData()

  }

  func getSecureData() {
    self.userBearerToken = Secret.userBearerToken
    self.refreshToken = Secret.refreshToken
    self.expireDate = Secret.expireDate
  }

  func getMe() async {
    do {
      let response = try await Sweet().lookUpMe()
      me = response.user
    } catch {
      print(error)
    }
  }

  var body: some View {
    VStack {
      Button("Login") {
        let url = getAuthorizeURL()
        openURL(url)
      }

      if userBearerToken != nil && refreshToken != nil && expireDate != nil {
        Button("Get Me") {
          Task {
            await getMe()
          }
        }
      }
    }

    .onOpenURL { url in
      Task {
        await callBackURL(url: url)
      }
    }
  }
}
