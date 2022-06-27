import Foundation
import HTTPClient
import Sweet



struct TwitterOAuth2 {
  private let clientID: String
  private let clientSecretKey: String

  init(clientID: String, clientSecretKey: String) {
    self.clientID = clientID
    self.clientSecretKey = clientSecretKey
  }

  func getAuthorizeURL(scopes: [TwitterScope], callBackURL: URL, challenge: String, state: String) -> URL {
    // https://developer.twitter.com/en/docs/authentication/oauth-2-0/user-access-token

    let joinedScope = scopes.map(\.rawValue).joined(separator: " ")

    let queries = [
      "response_type": "code",
      "client_id": clientID,
      "redirect_uri": callBackURL.absoluteString,
      "scope": joinedScope,
      "state": state,
      "code_challenge": challenge,
      "code_challenge_method": "plain",
    ]

    let authorizationURL: URL = .init(string: "https://twitter.com/i/oauth2/authorize")!
    var urlComponents: URLComponents = .init(url: authorizationURL, resolvingAgainstBaseURL: true)!
    urlComponents.queryItems = queries.map { .init(name: $0, value: $1) }

    return urlComponents.url!
  }

  func getUserBearerToken(code: String, callBackURL: URL, challenge: String) async throws -> OAuth2ModelResponse {
    // https://developer.twitter.com/en/docs/authentication/oauth-2-0/user-access-token

    let basicAuthorization = getBasicAuthorization(user: clientID, password: clientSecretKey)

    let headers = [
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Basic \(basicAuthorization)",
    ]

    let queries = [
      "code": code,
      "grant_type": "authorization_code",
      "client_id": clientID,
      "redirect_uri": callBackURL.absoluteString,
      "code_verifier": challenge,
    ]

    let url: URL = .init(string: "https://api.twitter.com/2/oauth2/token")!

    let (data, urlResponse) = try await HTTPClient.post(
      url: url, headers: headers, queries: queries)

    if let response = try? JSONDecoder().decode(OAuth2ModelResponse.self, from: data) {
      return response
    }

    if let response = try? JSONDecoder().decode(Sweet.ResponseErrorModel.self, from: data) {
      throw Sweet.TwitterError.invalidRequest(error: response)
    }

    throw Sweet.TwitterError.unknown(data: data, response: urlResponse)
  }

  func getRefreshUserBearerToken(refreshToken: String) async throws -> OAuth2ModelResponse {
    // https://developer.twitter.com/en/docs/authentication/oauth-2-0/authorization-code

    let url: URL = .init(string: "https://api.twitter.com/2/oauth2/token")!

    let queries = [
      "refresh_token": refreshToken,
      "grant_type": "refresh_token",
      "client_id": clientID,
    ]

    let (data, urlResponse) = try await HTTPClient.post(url: url, queries: queries)

    if let response = try? JSONDecoder().decode(OAuth2ModelResponse.self, from: data) {
      return response
    }

    if let response = try? JSONDecoder().decode(Sweet.ResponseErrorModel.self, from: data) {
      throw Sweet.TwitterError.invalidRequest(error: response)
    }

    throw Sweet.TwitterError.unknown(data: data, response: urlResponse)
  }

  func getBasicAuthorization(user: String, password: String) -> String {
    let value = "\(user):\(password)"
    let encodedValue = value.data(using: .utf8)!
    let encoded64Value = encodedValue.base64EncodedString()
    return encoded64Value
  }
}

extension TwitterOAuth2 {
  init() {
    self.init(clientID: Secret.clientID, clientSecretKey: Secret.clientSecretKey)
  }
}
