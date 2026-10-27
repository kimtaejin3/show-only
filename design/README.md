# ShowOnly 디자인 (A · Quiet Shield)

- 앱 이름: ShowOnly (영문 워드마크, "이것만 봐"는 사용 안 함)

- 원본: `show-only.pen` (Pen.app). 상단은 후보 A/B/C, 아래가 최종 A.
- 화면: Home / Empty, Home / Selected, Viewer, Lock / Default, Lock / Auth Failed, Protection Guide
- 컴포넌트: Button / Primary·Secondary·Text, Fact Row, Guide Step, Page Counter, Status Bar
- 레퍼런스: `references/overview.md`

## AI 티 제거 원칙
- 원형 배경 안 아이콘, 아이콘 불릿 리스트, 알약 배지, 그라디언트 썸네일 금지
- 위계는 타이포와 여백으로. 숫자는 모노(01·02·03, 2 / 3)로 정보처럼 보이게
- 잠금 화면은 가운데 정렬 아이콘 대신 좌측 정렬 큰 문장 + 상단 "보호 모드" 라벨
- 앱 아이콘·로고는 직접 그리지 않고 별도 제작(Codex 등)

## SwiftUI 토큰
| 토큰 | 값 |
|---|---|
| primary | #0F7C6F |
| accent-soft | #E3F2EF |
| bg / surface | #F4F6F6 / #FFFFFF |
| text / text-2 / text-3 | #111716 / #5C6A68 / #8A9694 |
| separator | #E2E8E7 |
| lock-bg / lock-text / lock-text-2 | #0B0F0F / #F1F5F4 / #97A6A3 |
| lock-primary / lock-on-primary | #3CC7AE / #04211C |
| danger | #D23B3B |
| radius | 10 / 14 / 20 |
| spacing | 4 / 8 / 12 / 16 / 24 / 32, 좌우 여백 20 (잠금 24) |
| 타이포 | Large 32–34 Bold(-0.8), Section 19 Bold, Body 16–17, Sub 15, Caption 13. 숫자 Mono 13 |
| 버튼 | 높이 54, radius 14, 라벨 17 Semibold |

시안 폰트는 IBM Plex Sans KR / IBM Plex Mono. 앱에서는 SF Pro + `.monospacedDigit()` 또는 SF Mono로 대체.

## Face ID 버튼 규칙
| 위치 | 버튼 | 의미 |
|---|---|---|
| 홈 / 선택됨 | CTA 위 힌트 "끝낼 때는 내 Face ID가 필요해요" | 시작 전에 종료 조건을 미리 알림 (시작 자체는 인증 없음) |
| 뷰어 상단 | Face ID 글리프 + "끝내기" (흐리게) | 받는 사람에게 "주인 인증이 필요한 버튼"임을 표시 |
| 뷰어 / 종료 시트 | "Face ID로 끝내기" + "계속 보여주기" | 누르면 시스템 Face ID 호출 |
| 잠금 | "Face ID로 다시 보기" / 실패 시 "Face ID 다시 시도" + "기기 암호 사용" | 재진입 인증 |

`Button / Auth` 컴포넌트는 기기에 따라 글리프·문구를 바꾼다: Face ID(`faceid`) / Touch ID(`touchid`) / 암호만(`key`). SwiftUI에서는 `LAContext.biometryType`으로 분기하고 SF Symbols `faceid`, `touchid`를 쓴다.
