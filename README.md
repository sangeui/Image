# Image
이미지를 검색하고 그 결과를 화면에 노출합니다.

---

⚠️ 빌드를 위해 `KakaoImageProvider.swift`의 `private extension String` 선언된 static 프로퍼티 `APIKEY`를 입력하셔야 합니다.


```swift
//
//  KakaoImageProvider.swift
//  Image
//
//  Created by 서상의 on 2021/11/16.
//

import Foundation

class KakaoImageProvider: UseCaseImageSearchProtocol {
   ...
}

private extension String {
    static let APIKEY = <#Kakao API Key#> // 카카오 API KEY
}


```

---

다음과 같은 기능을 포함합니다.

- 이미지를 검색합니다.
  - 사용자로부터 입력을 받아 1초과 경과하면 검색을 시작합니다.
  - 결과가 없을 때, 화면에 메시지를 노출합니다.
- 이미지 검색 결과를 3 * N 그리드로 노출합니다.
- 스크롤 할 수 있으며, 가장자리에 도달할 때마다 새로운 페이지를 요청합니다.
  - 이때 요청되는 페이지당 이미지 개수는 30개로 제한됩니다.
- 이미지를 터치하면 전체화면으로 해당 이미지를 보여줍니다.

---

크게 [**User Interface Adapter**]와 [**Application Specific Business Rule (Use Case)**], [**Image Provider**]로 구성했습니다.

---

![Image](https://user-images.githubusercontent.com/34618339/142434142-72f3f66f-7c94-41e7-9b09-f158f5483ba0.png)
