# ShowOnly(이것만 봐) UI/UX 레퍼런스 & 비주얼 방향 제안

- 작성: 2026-10-27 · design-researcher
- 근거: `PRD.md` 5~7장, `ShowOnly/Features/Home/HomeView.swift`, `Viewer/HandoffViewer.swift`, `Settings/ProtectionGuideView.swift`
- 범위: Home / Handoff Viewer / Privacy Lock / Protection Guide + 전체 비주얼 방향(컬러·타이포·컴포넌트)
- 무드보드(pen.dev)는 이번 작업에서 생략.

> 정직성 메모: 경쟁 앱(App Store) 스크린샷은 직접 열람하지 못했다. 아래 경쟁 앱 항목은 공개 설명문/도움말 기준이며,
> 화면 디테일을 추측해 묘사하지 않았다. Apple HIG 페이지는 WebFetch로 본문이 렌더링되지 않아(제목만 반환) 공식 URL과
> 일반적으로 알려진 원칙만 적었다. 디자이너가 링크를 직접 열어 확인할 것.

---

## 0. 현재 상태 진단 (코드 기준)

| 화면 | 현재 | 문제/기회 |
|---|---|---|
| Home | 청록 `#1FA18C` 아이콘 + rounded 36 Bold 타이틀, thinMaterial 카드에 3개 Label, borderedProminent 2개 + bordered 1개 | 1차 CTA가 상태에 따라 2개(사진 선택 / N장 보여주기)로 쌓여 위계가 흐림. 선택한 사진 미리보기 없음. 보호 설정 버튼이 CTA와 같은 무게 |
| Viewer | 검정 배경, 좌상단 `1 / N`, 우상단 캡슐 "보여주기 종료"(black 55%) | 기본은 좋음. 종료 버튼이 상대방(게스트)에게도 너무 눈에 띔 → 소유자만 아는 "조용한" 버튼이 나음 |
| Lock | `lock.shield.fill` 54pt + "사진을 가려뒀어요" + 기본 파란 borderedProminent | 버튼 tint가 앱 포인트 컬러와 불일치(시스템 블루). PRD 문구 '화면이 보호되고 있어요'와 상이 |
| Guide | 두 섹션, 번호 텍스트 + 회색 주의 박스 | 단계가 시각적으로 구분 약함. "설정 열기" 같은 행동 버튼 없음. 한계 문구는 정확하고 좋음 |

---

## 1. 화면별 레퍼런스

### 1-1. Home (가치 설명 · 사진 선택 · 시작)

| # | 레퍼런스 | 무엇이 좋은가 | ShowOnly 적용 |
|---|---|---|---|
| H1 | Ente Photos — Guest View 블로그 https://ente.com/blog/guest-view · 도움말 https://ente.com/help/photos/features/utilities/guest-view | 기능을 "고른 것만 넘겨보게, 나가려면 인증"이라는 한 문장 모델로 설명. 카피 톤이 따뜻하고 통제감("내가 보여줄 것을 정한다")을 강조 | 홈 상단 가치 문장을 한 줄 약속 + 3개 보장 항목으로 유지하되, "~를 막아요" 대신 "~만 보여줘요"처럼 긍정형으로 |
| H2 | JustShowPhotos (App Store) https://apps.apple.com/us/app/-/id6758265732 | 같은 문제를 푸는 iPhone 앱. 설명이 "선택 → Face ID/암호로 잠금 해제" 2단계로 단순 | 경쟁 앱 대비 차별점(한국어, 알림·이탈 보호 분리 가이드)을 홈 하단 "보호 설정" 진입점으로 드러낼 것. UI는 복제 금지 |
| H3 | Apple HIG — Onboarding https://developer.apple.com/design/human-interface-guidelines/onboarding | 가입 없이 바로 쓰게 하고, 설명은 짧게, 필요한 순간에 권한을 요청 | 별도 온보딩 페이지 없이 홈 1화면이 곧 온보딩. PhotosPicker는 권한 요청이 없다는 점을 "갤러리 전체 접근을 요청하지 않아요" 문구로 신뢰 포인트화 |
| H4 | Apple HIG — Buttons https://developer.apple.com/design/human-interface-guidelines/buttons | 화면당 prominent 버튼 1개 원칙 | 상태 머신: 비어 있음 = "사진 선택하기"(primary) / 선택됨 = "N장 보여주기"(primary) + "다시 고르기"(secondary 텍스트). 두 primary를 동시에 두지 않음 |
| H5 | Toss 디자인 시스템(TDS) https://developers-apps-in-toss.toss.im/design/components | 한국 사용자에게 익숙한 금융앱 수준의 단정한 위계: 큰 타이틀, 넓은 여백, 하단 고정 풀폭 CTA, 그림자 대신 면 색 차이 | 하단 고정 CTA(safe area 위 16pt), 섹션 구분은 그림자 없이 surface 색 차이로 |

**추천 패턴:** 상단 가치(아이콘+타이틀+한 문장) → 중앙 "선택한 사진" 썸네일 스트립(최대 10, 선택 전엔 점선 빈 상태 카드) → 보장 3항목 → 하단 고정 primary CTA 1개 + 보조 링크 "알림·앱 이동 보호 설정".

### 1-2. Handoff Viewer

| # | 레퍼런스 | 무엇이 좋은가 | 적용 |
|---|---|---|---|
| V1 | iOS 사진 앱 전체화면 뷰어 (HIG Images/Photos 관례) https://developer.apple.com/design/human-interface-guidelines/images | 검정 배경, 탭 시 크롬 숨김/표시, 핀치·더블탭 확대 | 탭 시 상단 오버레이 토글(기본 3초 후 페이드). 더블탭 2x 확대 |
| V2 | Ente Guest View 도움말(H1) | 단일 사진 "swipe lock", 고른 항목끼리만 넘김 | 마지막 장에서 고무줄(rubber-band) 바운스로 "끝"을 명확히. 끝에 다른 콘텐츠 없음 |
| V3 | Apple HIG — Materials https://developer.apple.com/design/human-interface-guidelines/materials | 사진 위 컨트롤은 ultraThin/dark material로 가독성 확보 | 페이지 표시·종료 버튼을 `.ultraThinMaterial` + dark 캡슐로. 종료는 아이콘(`xmark` 또는 `lock`) 위주로 덜 눈에 띄게, 길게 누르기(0.6s)로 인증 트리거 고려 |

**추천 패턴:** 상단 좌 `3 / 10`(monospaced), 상단 우 작은 잠금 아이콘 캡슐("종료"). 하단에는 아무것도 두지 않음(게스트 시선 분산 방지). 공유·삭제·앨범 UI 절대 없음.

### 1-3. Privacy Lock

| # | 레퍼런스 | 무엇이 좋은가 | 적용 |
|---|---|---|---|
| L1 | Signal — Screen Security https://support.signal.org/hc/en-us/articles/360043469312-Screen-Security | 블러 대신 **브랜드 단색 커버 + 로고**로 앱 스위처를 가림(블러는 누출·성능 우려) | 잠금 화면은 블러가 아닌 **불투명 단색 배경**. 사진 흔적 0 |
| L2 | Monzo 커뮤니티 — 앱 스위처 블러 논의 https://community.monzo.com/t/screen-blurring-when-switching-apps/4148 | 블러가 버벅이고 어색하다는 실사용 피드백 | 블러 사용 금지 근거로 기록 |
| L3 | Apple — Face ID & Privacy https://www.apple.com/legal/privacy/data/en/face-id/ · HIG Privacy https://developer.apple.com/design/human-interface-guidelines/privacy | 앱은 인증 성공/실패만 알 수 있음. 암호 fallback 제공 | 하단 보조 문구 "얼굴 정보와 암호는 앱이 알 수 없어요". 버튼 라벨은 기기 상태에 따라 "Face ID로 계속" / "기기 암호로 계속" |
| L4 | 1Password 커뮤니티 — 앱 스위처 가림 이슈 https://www.1password.community/1password-at-home-31/bug-report-app-content-not-obscured-in-ios-app-switcher-when-lock-immediately-is-enabled-23323 | 보안 앱도 스위처 누출 버그가 있음 → 실기기 검증 필요(PRD 6-4와 일치) | 디자인상 잠금 뷰는 첫 프레임부터 전체를 덮는 단순 레이아웃(애니메이션 진입 금지) |

**상태 분해:** 기본 / 인증 중(버튼 로딩) / 실패·취소(인라인 메시지 "사진은 계속 가려져 있어요", alert 대신 버튼 위 캡션) / 인증 불가 기기(세션 시작 자체를 홈에서 차단, PRD 6-6).

### 1-4. Protection Guide

| # | 레퍼런스 | 무엇이 좋은가 | 적용 |
|---|---|---|---|
| G1 | Apple 지원 — 사용법 유도 https://support.apple.com/ko-kr/111795 · 집중 모드 https://support.apple.com/ko-kr/guide/iphone/iphd6288a67f/ios | 공식 한국어 메뉴 명칭·경로 | 단계 문구의 메뉴 경로를 공식 명칭과 정확히 일치시키고 "자세히 보기"로 링크 |
| G2 | Apple HIG — Settings https://developer.apple.com/design/human-interface-guidelines/settings | 앱이 시스템 설정을 대신 바꾸지 않고 안내만 | "설정 열기" 버튼은 앱 설정만 열 수 있으므로 문구는 "설정 앱에서 직접 해주세요"로 정직하게 |
| G3 | Toss 류 단계 안내(번호 원형 배지 + 세로 연결선) — H5 링크 | 단계가 많아도 진행감이 있음 | 번호 원형 배지(24pt) + 세로 라인, 섹션 카드 2개(알림 숨기기 / 앱 이동 제한) 분리, 주의 박스는 info 톤(경고 빨강 X) |

**카피 원칙:** "100% 차단" 금지. "할 수 있는 것 / 할 수 없는 것" 2열 요약을 상단에 두면 한계 이해도가 올라간다.

---

## 2. 안티패턴 (피할 것)

1. 잠금/백그라운드에 블러 사용(누출·성능) — 불투명 단색 커버로.
2. 뷰어에 눈에 띄는 빨간 "종료" 버튼 — 게스트에게 조작 유도.
3. "완벽 보호", "알림 100% 차단" 등 과장 카피.
4. 홈에 prominent 버튼 2개 이상.
5. 경쟁 앱 아이콘(손바닥+자물쇠 조합 등)·레이아웃 그대로 차용(App Store 4.1).
6. 잠금 화면 버튼만 시스템 블루로 튀는 포인트 컬러 불일치.

---

## 3. 비주얼 방향 3안

공통 규칙: iOS 16+, Dynamic Type 대응(아래 크기는 Large 기준), 터치 타깃 ≥44pt, 본문 대비 ≥4.5:1, 뷰어는 세 안 모두 `#000000`.

### A안. Quiet Shield — 차분한 신뢰 미니멀 (추천)

- **컨셉:** 시스템 앱처럼 조용하고 단정해서 "믿고 건넬 수 있는" 앱.
- **무드:** 차분함, 신뢰, 네이티브, 여백, 정직.

| 토큰 | Light | Dark |
|---|---|---|
| background | `#F4F6F6` | `#0B0F0F` |
| surface | `#FFFFFF` | `#161C1C` |
| primary | `#0F7C6F` (흰 글자 ~5:1) | `#3CC7AE` (검정 글자) |
| onPrimary | `#FFFFFF` | `#04211C` |
| text primary | `#111716` | `#F1F5F4` |
| text secondary | `#5C6A68` | `#97A6A3` |
| accent (tint bg/칩) | `#E3F2EF` | `#173A34` |
| danger | `#D23B3B` | `#FF6B6B` |
| separator | `#E2E8E7` | `#26302F` |

- **타이포:** SF Pro (기본). Large Title 34 Bold(홈 타이틀만), Title 22 Bold, Headline 17 Semibold, Body 17 Regular, Subhead 15 Regular, Caption 13 Regular. 숫자 카운터는 `.monospacedDigit()`.
- **라운드:** sm 10 / md 14 / lg 20, 버튼 14(풀폭), 뷰어 오버레이만 capsule. continuous corner.
- **스페이싱:** 4 · 8 · 12 · 16 · 24 · 32 · 48. 화면 좌우 20.
- **버튼:** Primary 풀폭 높이 54, 채움 primary. Secondary = accent 배경 + primary 글자. Tertiary = 텍스트 버튼.
- **카드:** surface, 그림자 없음(라이트는 1px separator 대신 bg와 surface 색 차이), padding 16.
- **Home:** 회색 bg 위 흰 카드들. 상단 아이콘(`hand.raised` 계열 대체 자체 심볼) 32pt primary → 34 Bold 타이틀 → secondary 본문. 썸네일 스트립 카드 → 보장 3항목 리스트(아이콘 원형 accent 배경) → 하단 고정 CTA.
- **Viewer:** 검정, 상단 ultraThinMaterial(dark) 캡슐 2개, 흰 글자.
- **Lock:** 배경 `#0B0F0F` 단색, 중앙 `lock.shield` 56pt primary(dark값), "화면이 보호되고 있어요" Title 22 Bold, secondary 설명, primary 버튼 "Face ID로 계속"(max 280).

### B안. Friendly Pocket — 따뜻하고 친근한 라운드

- **컨셉:** 친구에게 사진 보여주는 즐거운 순간에 맞춘, 말랑하고 따뜻한 앱.
- **무드:** 따뜻함, 다정함, 둥글둥글, 가벼움, 일상.

| 토큰 | Light | Dark |
|---|---|---|
| background | `#FFF7EF` | `#1A1512` |
| surface | `#FFFFFF` | `#27201C` |
| primary | `#C9521F` (흰 글자 ~4.6:1) | `#FF8A5B` (검정 글자) |
| onPrimary | `#FFFFFF` | `#2A1206` |
| text primary | `#2B211C` | `#FFF3E8` |
| text secondary | `#7A6A60` | `#BBAA9E` |
| accent (하이라이트/칩) | `#FFD66B` | `#FFD36B` |
| accent soft | `#FFEBDD` | `#3A2A20` |
| danger | `#D13A3A` | `#FF6E6E` |

- **타이포:** SF Pro Rounded 전체. Large Title 32 Heavy, Title 22 Bold, Headline 17 Bold, Body 17 Medium, Subhead 15 Medium, Caption 13 Medium.
- **라운드:** sm 14 / md 20 / lg 28, 버튼 capsule, 썸네일 18.
- **스페이싱:** 4 · 8 · 12 · 20 · 28 · 40. 좌우 20.
- **버튼:** Primary capsule 높이 56, 살짝 그림자(`#C9521F` 25%, y4 blur12). Secondary = accent soft 배경 capsule.
- **카드:** surface, radius 24, 부드러운 그림자(검정 6%, y6 blur20). 단계 배지는 노란 원.
- **Home:** 크림 배경, 상단에 겹친 폴라로이드 3장 일러스트(자체 제작), "이것만 봐" 32 Heavy Rounded, 썸네일은 살짝 회전된 카드 스택, 하단 주황 capsule CTA.
- **Viewer:** 검정, 오버레이 캡슐은 동일하되 라운드 폰트.
- **Lock:** 배경 `#1A1512`(따뜻한 거의-검정), 둥근 사각 아이콘 컨테이너(80pt, accent soft) 안 자물쇠, "화면이 보호되고 있어요" 22 Bold Rounded, 주황 capsule 버튼.

### C안. Blackout — 대담한 고대비 다크 퍼스트

- **컨셉:** 뷰어의 검정을 앱 전체 정체성으로 — "검은 화면 = 보호 중".
- **무드:** 대담함, 고대비, 테크, 단호함, 미니멀 그래픽.

| 토큰 | Dark (기본) | Light |
|---|---|---|
| background | `#000000` | `#F2F2EE` |
| surface | `#141414` | `#FFFFFF` |
| primary | `#D4FF3F` (라임, 검정 글자) | `#111111` (흰 글자) |
| onPrimary | `#0A0A0A` | `#FFFFFF` |
| text primary | `#FFFFFF` | `#0A0A0A` |
| text secondary | `#9E9E9E` | `#5A5A5A` |
| accent | `#D4FF3F` 하이라이트 / `#7C5CFF` 보조 | `#9CCB00`(면 전용) / `#5B3DF5` |
| border | `#2A2A2A` | `#DADAD4` |
| danger | `#FF453A` | `#E0312B` |

- **타이포:** SF Pro Display(Expanded 폭 가능 시 iOS 16 `.width(.expanded)`), Large Title 40 Heavy(트래킹 -0.5), Title 24 Bold, Headline 17 Semibold, Body 17 Regular, Caption 12 Semibold(자간 +0.3). 카운터·장수는 SF Mono 15 Medium.
- **라운드:** sm 6 / md 10 / lg 16, 버튼 12. 각진 쪽.
- **스페이싱:** 4 · 8 · 16 · 24 · 40 · 64(큰 점프로 긴장감). 좌우 20.
- **버튼:** Primary 라임 채움 높이 56, 검정 글자. Secondary = 1px border + 흰 글자. 그림자 없음.
- **카드:** surface + 1px border, 내부 라벨은 Caption 대문자 톤의 작은 태그(`SAFE`, `10장 한도` 등은 한국어 태그로).
- **Home:** 검정 바탕에 초대형 타이틀 "이것만 봐", 라임 언더라인, 선택 장수 `03 / 10` SF Mono 대형 표시, 하단 라임 CTA.
- **Viewer:** 홈과 연속(전환 시 이질감 0). 카운터 SF Mono.
- **Lock:** 순검정, 라임 자물쇠 라인 아이콘, 40 Heavy "보호 중", 서브 "화면이 보호되고 있어요", 라임 버튼.

### 추천: A안 Quiet Shield

- 보안·프라이버시 앱의 1순위 가치는 **신뢰**. 시스템 앱과 닮은 단정함이 "이 앱이 뭔가 숨기지 않는다"는 인상을 준다.
- 현재 청록 포인트를 다듬은 것이라 코드 변경 비용이 가장 적고, Dynamic Type·다크 모드·VoiceOver 대응이 쉽다.
- 잠금/가이드처럼 한계를 정직하게 말해야 하는 화면과 톤이 가장 잘 맞는다.
- 보완: B안의 따뜻함 일부(홈 썸네일 스트립의 부드러운 라운드, 친근한 카피)를 차용해 차갑지 않게. C안은 App Store 스크린샷 차별화가 강해 2차 브랜딩 실험 후보로 보관.
