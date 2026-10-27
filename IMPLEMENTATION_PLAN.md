# 구현 계획 — ShowOnly

> 이 문서는 개발 순서와 검증 단계를 설명한다. 초기 코드가 있다고 해서 모든 기능이 실기기에서 검증된 것은 아니다.

## Phase 0 — 프로젝트 기반 (이 패키지)

- [x] `PRD.md`, `README.md`, `IMPLEMENTATION_PLAN.md`
- [x] `ShowOnly.xcodeproj` 및 SwiftUI 소스 구조
- [x] 선택 사진 뷰어/보호 모델/인증 서비스의 초기 구현
- [x] 집중 모드와 사용법 유도 수동 설정 안내
- [ ] 실제 Mac의 Xcode에서 빌드 확인 (현재 실행 환경은 Linux)
- [ ] iPhone에 배포 및 수동 테스트

## Phase 1 — MVP 기능 검증

1. Xcode로 프로젝트 열기, 번들 ID와 Team 설정.
2. PhotosPicker 1~10장 선택·로딩·취소와 오류 처리 확인.
3. 전체 화면에서 좌우 이동·핀치 확대와 터치 충돌 테스트.
4. Face ID / 기기 암호 성공, 취소, 실패, 미등록 상태 확인.
5. 비활성화/재활성화 시 사진 숨김과 인증 상태 확인.

## Phase 2 — 안전성 강화

1. 앱 스위처의 미리보기에서 사진이 실제로 보이지 않는지 iPhone에서 반복 확인.
2. 필요할 경우 UIViewController/UIWindow 기반 프라이버시 오버레이를 앱 생명주기에 추가.
3. 메모리 경고·대형 이미지·다중 선택에서 다운샘플링 및 캐시 해제.
4. Guided Access 설정 흐름 확인, 사용자가 기능 수준을 오해하지 않도록 문구 조정.
5. iOS 집중 모드에서 카카오톡/다른 메신저 알림 배너 숨김이 올바르게 동작하는지 테스트.

## Phase 3 — UX 및 배포

1. 독자적인 앱 이름/아이콘/온보딩/앱스토어 스크린샷 작성.
2. 한국어 카피 검토 및 접근성 향상.
3. Guest View, ShowSafe, No Peeking과 사용성 비교.
4. 앱 심사 4.1/4.2/4.3와 개인 정보 보호 정책 검토.
5. TestFlight를 통한 실제 사용자 피드백 수집.

## 코드 구조

```
ShowOnly/
├── App/ShowOnlyApp.swift
├── Models/PhotoSessionStore.swift
├── Services/AuthenticationService.swift
├── Features/Home/HomeView.swift
├── Features/Viewer/HandoffViewer.swift
├── Features/Viewer/ZoomableImageView.swift
├── Features/Settings/ProtectionGuideView.swift
└── Resources/Assets.xcassets/
```

## 기술적 주의사항

- 홈 스와이프와 시스템 앱 전환은 앱 단독으로 막지 못한다.
- 재진입 인증은 `deviceOwnerAuthentication`을 사용하므로 Face ID 외에도 기기 암호가 제공될 수 있다.
- 최초 설정 없이 앱이 임의로 집중 모드를 바꾸지 않는다.
- 앱 스위처 스냅샷 보안은 SwiftUI 상태 전환만으로 100% 보장할 수 없으므로 기기 테스트가 중요하다.
- 현재 iOS 프로젝트는 기본적인 초기 구조이며, Mac/Xcode에서 직접 빌드하지 못했다.
