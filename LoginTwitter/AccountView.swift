import SwiftUI
import Sweet

struct AccountView: View {
  let user: Sweet.UserModel

  var body: some View {
    VStack {
      AsyncImage(url: user.profileImageURL) { image in
        image
          .resizable()
          .frame(width: 100, height: 100)
          .clipShape(Circle())
      } placeholder: {
        ProgressView()
      }

      HStack {
        Text("@\(user.userName)")

        Text(user.name)
      }

      if let description = user.description {
        Text(description)
      }

      if let createdAt = user.createdAt {
        Text(createdAt.formatted())
      }

      if let location = user.location {
        Text(location)
      }


      if let metrics = user.metrics {
        HStack {
          Text("Followers \(metrics.followersCount)")
          Text("Following \(metrics.followingCount)")
        }
      }
    }
  }
}

struct AccountView_Previews: PreviewProvider {
  static var previews: some View {
    AccountView(user: .init(id: "id", name: "name", userName: "userName"))
  }
}
