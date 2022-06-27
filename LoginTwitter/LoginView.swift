import SwiftUI
import Sweet

struct LoginView: View {
  @Environment(\.openURL) var openURL
  @State var userBearerToken: String? = Secret.userBearerToken
  @State var refreshToken: String? = Secret.refreshToken
  @State var expireDate: Date? = Secret.expireDate
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
    do {
      try await DeepLink().loginTwitter(url)
      getSecureData()
    } catch {
      print(error)
    }
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

  func logout() {
    Secret.userBearerToken = nil
    Secret.refreshToken = nil
    Secret.expireDate = nil

    userBearerToken = nil
    refreshToken = nil
    expireDate = nil

    me = nil
  }

  var body: some View {
    VStack {

      Button("Login") {
        let url = getAuthorizeURL()
        openURL(url)
      }
      .padding()

      if userBearerToken != nil && refreshToken != nil && expireDate != nil {
        Button("Logout") {
          logout()
        }
        .padding()

        Button("Get Me") {
          Task {
            await getMe()
          }
        }
        .padding()
      }

      if let me {
        Text("id: \(me.id)")
        Text("@\(me.userName)")
        Text(me.name)
       }
    }

    .onOpenURL { url in
      Task {
        await callBackURL(url: url)
      }
    }
  }
}
