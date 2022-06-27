import Foundation

struct OAuth2ModelResponse: Decodable {
  let bearerToken: String
  let refreshToken: String
  let expiredSeconds: Int

  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiredSeconds = "expires_in"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.bearerToken = try values.decode(String.self, forKey: .accessToken)
    self.refreshToken = try values.decode(String.self, forKey: .refreshToken)
    self.expiredSeconds = try values.decode(Int.self, forKey: .expiredSeconds)
  }
}
