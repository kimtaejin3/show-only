# 릴스 홍보 영상

- `reels_v1.mp4`: 1080×1920, 약 36초, 소리 없음(인스타그램에서 음악을 얹는다)
- 흐름: 사진 앱에서 넘기다 다른 사진이 보임(훅) → 사진 고르기 → 고른 사진만 넘기기 → 앱을 나갔다 오면 잠금, Face ID로 다시 보기 → 끝낼 때 Face ID → 앱 아이콘
- 보호 가이드(알림·앱 이동 막는 법)는 넣지 않았다
- 자막: 검은 둥근 상자 + 흰 글씨, Pretendard Bold (SIL OFL)
- 사진: picsum.photos(Unsplash 라이선스, 상업적 사용 가능) 샘플 36장을 iPhone 16 시뮬레이터(iOS 18.4, 한국어)에 넣어 찍었다

## 다시 만들기

1. `driver/`: XcodeGen으로 만드는 UI 테스트 프로젝트. 테스트가 화면을 누르고 `markers.txt`에 시각을 남기면 `watch.py`가 Face ID 일치를 보낸다. 경로는 스크래치 폴더 기준이라 쓸 때 고친다.
2. `driver/record.sh take.mov`: 녹화 + 자동 조작 (처음 한 번은 `TEST=testWarmupFaceID driver/record.sh`로 Face ID 권한을 먼저 허용)
3. `python3 captions.py <Pretendard 폴더> <cap 폴더>`: 자막·마스크·마지막 카드 PNG
4. `python3 edit.py take.mov <cap 폴더> <테스트 앱 없는 홈 화면.png> reels.mp4`: 자르기·배속·자막 합성. 홈 화면 장면의 테스트 실행기 아이콘은 깨끗한 홈 화면 조각으로 덮는다
