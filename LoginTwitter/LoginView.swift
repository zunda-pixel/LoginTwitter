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

    let url = Sweet.OAuth2().getAuthorizeURL(
      scopes: Sweet.AccessScope.allCases,
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
      let response = try await Sweet().me()
      me = response.user
      updateSecretData()
    } catch {
      print(error)
    }
  }

  func logout() {
    Secret.userBearerToken = nil
    Secret.refreshToken = nil
    Secret.expireDate = nil

    updateSecretData()
    
    me = nil
  }

  func updateSecretData() {
    userBearerToken = Secret.userBearerToken
    refreshToken = Secret.refreshToken
    expireDate = Secret.expireDate
  }

  var body: some View {
    VStack {
      if let me {
        AccountView(user: me)
          .padding()
          .border(.cyan, width: 10)
      }

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

        Button("Get My Profile") {
          Task {
            await getMe()
          }
        }
        .padding()
      }

      if let userBearerToken {
        Text("userBearerToken")
        Text(userBearerToken)
          .font(.system(size: 10))
      }

      if let refreshToken {
        Text("refreshToken")
        Text(refreshToken)
          .font(.system(size: 10))
      }

      if let expireDate {
        Text("expire Date")
        Text(expireDate, format: .iso8601)

        Text("now Date")
        TimelineView(.periodic(from: .now, by: 1)) { context in
          Text(context.date, format: .iso8601)
        }
      }
    }
    .onAppear {
      Task {
        if userBearerToken != nil && refreshToken != nil && expireDate != nil {
          await getMe()
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
