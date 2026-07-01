# LucyPlanner

**하루의 목표 · 시간표 · 할 일 · 습관** 네 가지를 한 화면에 놓는 macOS 데일리
플래너입니다. 탭 전환도, 창 여러 개도 없이 하루 전체가 창 하나에 담깁니다.

**SwiftUI**와 **SwiftData**로 만들었고, **EventKit**을 통해 Apple 캘린더
(그리고 Apple 캘린더에 연동된 Google 캘린더 등)와 통합됩니다.

> English docs: [README.md](README.md)

---

## 화면 구성

```
┌─────────────────────────────────────────────────────────────────────┐
│  ‹  2026-07-01  ›  [Today]         Today's goal…              ⚙︎    │
├──────────────────────────────────┬──────────────────────────────────┤
│  Time table                      │  Todos       ┌───────┬───────┐   │
│                                  │              │ List  │Matrix │   │
│   6:00                           │  Brain-dump anything…   [Add] │  │
│   6:30  ▓ 아침 러닝              │                                │  │
│   7:00                           │  Today · 3                     │  │
│   ...                            │   ○ 논문 Section 3 작성        │  │
│  10:00  ▓ 랩 미팅                │   ● 지도교수님께 답장          │  │
│  10:30  ▓ 랩 미팅                │   ○ 브랜치 푸시                │  │
│  11:00                           │                                │  │
│   ...                            │  Inbox · 2                     │  │
│                                  │   ○ 신규 논문 읽기             │  │
│                                  │   ○ 러닝화 사기                │  │
├──────────────────────────────────┴──────────────────────────────────┤
│  Habits                                                             │
│  독서 30분     ▓ ▓ · ▓ ▓ ▓ · · ▓ ▓ ▓ ▓ · · ▓                        │
│  러닝          · ▓ · · ▓ · · · ▓ · · ▓ · ·                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 주요 기능

### 🎯 오늘의 목표를 가장 잘 보이는 곳에
상단 바에 항상 **"Today's goal"** 한 줄이 있습니다. 날짜별로 저장되므로
어제의 목표가 남아 있지도, 오늘의 목표가 내일까지 새어나가지도 않습니다.

### 🗓️ 진짜 캘린더 이벤트를 보여주는 시간표
- 오전 6시 ~ 다음 날 오전 2시까지 30분 단위 그리드.
- 권한을 허용한 Apple 캘린더의 이벤트를 그대로 표시합니다 (Google, iCloud,
  회사 캘린더 등 Apple 캘린더가 동기화하는 모든 소스).
- **⚙︎ → Calendars…** 시트에서 표시할 캘린더를 골라낼 수 있습니다.
- 오른쪽 todo를 **드래그**해서 시간표 슬롯에 놓으면 그 시간에 블록됩니다.
- 시간표의 블록을 **탭**하면 캘린더 이벤트 자체를 삭제할 수 있습니다 (실수
  방지용 확인 대화상자가 뜹니다).

### ✅ Inbox와 오늘로 나뉜 할 일 관리
- todo 패널 상단의 입력창에 뭐든 brain-dump 하세요.
- 새로 만든 todo는 일단 **Inbox**로 들어갑니다 (날짜 미배정 상태).
- 각 행의 ⋯ 메뉴에서 특정 날짜로 예약하거나, 내일로 미루거나, Inbox로
  돌려보낼 수 있습니다.
- 두 가지 보기 모드: **List**와 **Matrix**.

### 🧭 아이젠하워 매트릭스 뷰
Matrix 뷰로 전환하면 todo가 네 사분면(**Do Now / Decide / Delegate /
Delete**)으로 정리됩니다.

제목에 담긴 키워드(`deadline`, `today`, `asap` → 긴급 / `paper`, `research`,
`review` → 중요 등)를 보고 자동으로 사분면을 추천합니다. 신호가 명확할
때만 추천이 뜨고, 그 외에는 직접 배치합니다. 사용자가 직접 지정한 사분면은
언제나 추천을 덮어씁니다.

### 📈 월 단위 습관 트래커
- 하단에 습관 × 그 달의 일자 그리드가 놓입니다.
- 한 번 탭하면 그날의 완료 여부가 토글됩니다. 월 단위로 이동 가능.
- 습관은 한 행씩 작게 유지해서 시선을 분산시키지 않습니다.

### 💾 로컬 우선 저장
모든 데이터는 앱 컨테이너 안의 SwiftData 로컬 저장소에 있습니다. 어디로도
업로드되지 않습니다. CloudKit 동기화는 iPhone 버전이 나올 때 함께 켤 예정.

---

## 시스템 요구 사항

- macOS 15 Sequoia 이상
- 캘린더 접근 권한 (첫 실행 시 요청)
- **소스에서 직접 빌드할 때만** Xcode 16 이상

---

## 설치 (권장)

1. [Releases 페이지](https://github.com/yahyunee/LucyPlanner/releases)로 이동.
2. 최신 릴리스의 `LucyPlanner.zip`을 내려받습니다.
3. zip을 더블클릭해 압축을 풀고, `LucyPlanner.app`을 `/Applications`
   폴더로 드래그.
4. **첫 실행**: 아직 Apple 공증(notarization)을 거치지 않았기 때문에
   그냥 더블클릭하면 Gatekeeper가 실행을 막습니다. 아래 중 하나로 해결:
   - `LucyPlanner.app`을 **우클릭 → 열기** → 대화상자에서 다시 **열기**
     클릭. 한 번 허용하면 이후부터는 그냥 더블클릭으로 실행됩니다.
   - 혹은 터미널에서:
     ```bash
     xattr -dr com.apple.quarantine /Applications/LucyPlanner.app
     ```
5. 첫 실행 시 macOS가 **캘린더** 권한을 물어봅니다. 시간표에 기존 캘린더
   이벤트를 띄우고 싶다면 허용하세요 (거절해도 앱은 정상 동작하며,
   시간표만 이벤트 없이 비어 보일 뿐입니다).

> 아직 릴리스가 없다면 아래 [소스에서 빌드하기](#소스에서-빌드하기) 참조.

---

## 소스에서 빌드하기

직접 빌드하거나 앱을 수정해 보고 싶다면 무료 Apple ID만 있으면 충분합니다.
유료 Apple Developer Program 가입은 로컬 빌드에는 필요 없습니다.

```bash
git clone https://github.com/yahyunee/LucyPlanner.git
cd LucyPlanner
open LucyPlanner.xcodeproj
```

Xcode에서:

1. **LucyPlanner** scheme + **My Mac** 실행 대상 선택.
2. **LucyPlanner** 타깃 → **Signing & Capabilities** 탭.
3. **Team**을 본인의 Personal Team으로 변경. 목록이 비어 있다면
   **Add an Account…**로 아무 Apple ID나 로그인하면 무료 개인 팀이
   자동 생성됩니다.
4. 만약 Xcode가 bundle identifier 충돌을 알리면, **Bundle Identifier**를
   `com.lucy.LucyPlanner` → `com.<본인이름>.LucyPlanner` 같은 고유한 값으로
   바꿔 주세요.
5. `⌘R`로 빌드 및 실행.
6. 첫 실행 시 macOS가 캘린더 접근 권한을 물어봅니다. 기존 이벤트를 시간표에
   보고 싶다면 **허용**을 선택하세요.

---

## 활용 예시

**아침 루틴**

1. LucyPlanner를 켭니다. 오늘 날짜로 열립니다.
2. 상단 바에 오늘의 목표를 씁니다 — 예: *"Section 3 초안 마무리."*
3. 시간표를 봅니다. 캘린더에 잡혀 있던 회의가 이미 표시되어 있습니다.
4. todo 패널에 머릿속에 떠도는 걸 다 쏟아내세요. 전부 **Inbox**로 들어갑니다.
5. Inbox의 *"Section 3 작성"*을 시간표의 9:00–11:00 슬롯에 드래그합니다. 실제
   캘린더 이벤트로 변합니다.
6. 하루 동안 하단의 습관을 하나씩 체크해 나갑니다.

**아이젠하워 매트릭스로 분류하기**

1. todo 패널을 **Matrix**로 전환합니다.
2. 긴급하거나 중요해 보이는 항목에는 자동으로 사분면이 추천됩니다.
3. 나머지는 본인 판단대로 사분면에 넣습니다.
4. **Do Now**부터 처리하고, **Decide**는 나중 일정으로 예약, **Delegate**는
   위임, 나머지는 삭제.

**내일 계획**

1. 날짜 옆의 `›` 버튼으로 내일로 이동합니다.
2. 내일의 목표를 씁니다.
3. Inbox의 todo에서 ⋯ → **Plan for this day**로 내일에 배정.
4. 시간이 정해진 일은 내일의 시간표에 드래그해 둡니다.

---

## 문제 해결 (Troubleshooting)

### 앱에서 캘린더 일정이 안 보여요

LucyPlanner는 Apple의 EventKit을 통해 이벤트를 읽기 때문에, **macOS 기본
캘린더(Apple Calendar) 앱에서 보이는 것만** 볼 수 있습니다. 순서대로
체크해 보세요:

1. **Apple Calendar 앱에서는 그 일정이 보이나요?**
   같은 날짜로 Apple Calendar 앱을 열어 확인하세요. 거기서 안 보이면
   LucyPlanner도 볼 수 없습니다. Google/Outlook 등을 쓰신다면 먼저
   **Apple Calendar → 설정 → 계정**에서 해당 계정을 추가해 Apple Calendar가
   동기화하도록 만들어야 합니다.

2. **LucyPlanner에 캘린더 권한이 켜져 있나요?**
   **시스템 설정 → 개인 정보 보호 및 보안 → 캘린더**에서 **LucyPlanner**가
   켜져 있는지 확인. 만약 목록에 아예 없다면 앱을 완전히 종료 후 다시
   실행해 주세요. 첫 실행이 권한 요청 지점까지 도달해야 macOS가 앱을
   등록합니다.

3. **LucyPlanner 안에서 그 캘린더를 숨긴 상태는 아닌가요?**
   상단바 **⚙︎** → **Calendars…** 시트에서 해당 캘린더가 체크되어 있는지
   확인. 여기서 끈 캘린더는 재실행해도 계속 숨겨진 상태로 유지됩니다.

4. **일정이 시간표 밖 시간대인가요?**
   시간표는 **오전 6시 ~ 다음 날 오전 2시**만 표시합니다. 이 범위 바깥의
   이벤트나 종일 이벤트는 블록으로 뜨지 않습니다.

5. **올바른 날짜를 보고 있나요?**
   창 상단의 날짜 선택기가 기준입니다. 다른 날로 스크롤됐다면 **Today**
   버튼으로 오늘로 돌아오세요.

6. **방금 동기화된 일정을 강제로 새로 고치고 싶다면**
   **⚙︎ → Calendars…** 시트에서 아무 캘린더나 껐다 켜 보거나, 날짜를
   다른 날로 옮겼다가 돌아오면 다시 로드됩니다. 그래도 안 되면 앱을
   완전히 종료 후 재실행 — 전체 EventKit 상태를 새로 조회합니다.

### "LucyPlanner를 열 수 없습니다. Apple에서 악성 소프트웨어가 있는지 확인할 수 없기 때문입니다"

공증(notarization)을 거치지 않은 빌드에서 뜨는 표준 Gatekeeper 경고입니다.
`LucyPlanner.app`을 **우클릭 → 열기** → 대화상자에서 다시 **열기**를
선택하거나, 터미널에서 다음 한 줄을 실행하세요:
```bash
xattr -dr com.apple.quarantine /Applications/LucyPlanner.app
```

### 실수로 캘린더 권한을 거부했어요

macOS는 자동으로 다시 묻지 않습니다. **시스템 설정 → 개인 정보 보호 및
보안 → 캘린더 → LucyPlanner** 토글을 켜고, 앱을 재실행하세요.

---

## 프로젝트 구조

```
LucyPlanner/
├── LucyPlannerApp.swift       // @main + SwiftData ModelContainer 초기화
├── ContentView.swift           // 상단바 / 시간표 / todo / 습관 루트 레이아웃
├── LucyPlanner.entitlements    // 샌드박스 + 캘린더 권한
├── Models/                     // @Model 타입: Todo, Habit, TimeBlock, DailyEntry, ...
├── Services/
│   └── CalendarService.swift   // EventKit 접근·로딩·삭제
└── Views/                      // TopBar, TimeTablePanel, TodoListPanel, HabitTrackerPanel, ...
```

데이터 저장 위치:
`~/Library/Containers/com.<your-team>.LucyPlanner/Data/Library/Application Support/default.store`

---

## 로드맵

- **iPhone 컴패니언 앱** — 동일 스키마의 iOS SwiftUI 버전
- **CloudKit 동기화** — iPhone 타깃 붙는 시점에 `ModelConfiguration`에서 활성화
- **습관 통계 강화** — 연속 일수, 완료율, 월별 요약
- **더 나은 아이젠하워 추천** — 키워드 규칙이 아니라 사용자가 직접 배정한
  결과를 학습

---

## 기여

지극히 개인적인 데일리 루틴에 맞춰 만든 앱이라, 워크플로 자체를 크게 바꾸는
PR은 반영이 어렵습니다. 버그 수정, 다듬기, 소소한 QoL 개선, 로컬라이제이션은
환영합니다.

파일 여러 개를 건드릴 변경이라면 먼저 이슈부터 열어 주세요.

---

## 라이선스

[GPL-3.0](LICENSE) © 2026 yahyunee

카피레프트 라이선스입니다. 자유롭게 사용·연구·수정·재배포할 수 있지만,
배포되는 파생 저작물은 반드시 소스 코드를 공개하고 동일하게 GPL-3.0으로
공개해야 합니다. 다른 라이선스 조건으로 재사용하고 싶다면 이슈를 열어 주세요.
