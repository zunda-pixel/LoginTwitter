## LoginTwitter

Login Twitter for Twitter API v2 (Oauth2)

This is Sample for Twitter API Library([Sweet](https://github.com/zunda-pixel/Sweet))

## Set up

### 1. Get Client ID

[Developer Portal](https://developer.twitter.com/en/portal/) > Products & Apps > Keys and token

<img width="300" alt="スクリーンショット 2022-06-27 14 28 24" src="https://user-images.githubusercontent.com/47569369/175866252-ff1d9d1d-c80e-4d7a-ab41-0fb8355d5625.png">

### 2. Set Client ID

open Secret.swift and type your Client ID

```swift
struct Secret {
  static let clientID = ""
  static let clientSecretKey = ""
  ...
}
```

### 3. Set CallBackURL(= URLScheme)

Add `loginTwitter://`

<img width="300" alt="スクリーンショット 2022-06-27 14 33 56" src="https://user-images.githubusercontent.com/47569369/175866766-bb5b278f-74e2-4ad7-8e9c-a81e5cd509cb.png">

