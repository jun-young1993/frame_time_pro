# Frame Time Pro

SMPTE Timecode / Drop-Frame Calculator — 방송 현장 전문가를 위한 타임코드 변환 앱

---

## 기능

### 변환 모드 (6가지)
| 모드 | 설명 |
|------|------|
| Frame → TC | 프레임 번호를 타임코드로 변환 |
| TC → Frame | 타임코드를 프레임 번호로 변환 |
| TC → Sec | 타임코드를 초(seconds)로 변환 |
| Sec → TC | 초를 타임코드로 변환 |
| Sec → Frame | 초를 프레임 번호로 변환 |
| Frame → Sec | 프레임 번호를 초로 변환 |

### 지원 FPS
`23.976` · `23.98` · `24` · `25` · `29.97` · `30` · `50` · `59.94` · `60` · `1000`

Drop-Frame(DF) 모드: **29.97**, **59.94** 지원

### 타임코드 키패드
- 세그먼트별 포커스 입력 (HH / MM / SS / FF)
- `-1F` / `+1F` — long-press 연속 입력 지원
- `-10F` / `+10F` / `-1S` / `+1S` — 빠른 이동
- 숫자 패드 직접 입력 + 백스페이스

### 히스토리
- 수동 저장 (결과 화면 북마크 아이콘)
- 검색 (입력값 / 출력값 기준)
- 히스토리 항목 탭 → 계산기에 즉시 로드
- 최대 200건 유지 (초과 시 오래된 항목 자동 삭제)

### 설정 영속화
앱 재시작 후에도 마지막으로 사용한 **FPS 모드**, **Drop-Frame 설정**, **변환 모드**가 유지됩니다.

---

## 아키텍처

```
lib/
├── main.dart
├── core/
│   ├── constants/        # AppSpacing, AppBreakpoints
│   ├── theme/            # AppTheme (Material 3, dark, Indigo seed)
│   └── widgets/          # AppSectionContainer
└── features/
    ├── timecode_calculator/
    │   ├── domain/       # Timecode, FpsMode, TimecodeValidation, TimecodeMath
    │   ├── application/  # TimecodeCalculatorNotifier (Riverpod StateNotifier)
    │   ├── data/         # CalculatorSettingsRepository (Hive)
    │   └── presentation/ # Screen, Sections, TimecodeKeypadBottomSheet
    ├── history/
    │   ├── domain/       # ConversionRecord (Hive HiveObject)
    │   ├── data/         # HistoryRepository
    │   ├── application/  # HistoryNotifier
    │   └── presentation/ # HistoryScreen
    └── setting/          # AppSettingScreen (테마/브랜드)
```

**상태 관리:** `flutter_riverpod` (StateNotifier)  
**로컬 저장:** `hive_flutter` — 히스토리 및 설정 영속화  
**반응형:** 세로(portrait) / 가로·태블릿(≥600dp 2-column)

---

## 개발 명령어

```bash
flutter pub get          # 의존성 설치
flutter run              # 연결된 기기/에뮬레이터에서 실행
flutter run -d <device>  # 특정 기기 지정
flutter test             # 전체 테스트
flutter test test/features/timecode_calculator/domain/timecode_test.dart  # 도메인 단위 테스트
flutter analyze          # 정적 분석
flutter build apk        # Android 빌드
flutter build ios        # iOS 빌드
```

---

## SMPTE Drop-Frame 규칙

29.97 / 59.94 DF 모드에서 다음 타임코드 레이블은 **불법(illegal)** 입니다:

- 매 분 시작점(`SS=00`)에서 `FF=00` 또는 `FF=01`
- **단, 10분 단위(`MM % 10 == 0`)는 예외**

예시 (29.97 DF):
| 타임코드 | 유효 여부 |
|---------|----------|
| `00:01:00;00` | ❌ illegal |
| `00:01:00;02` | ✅ valid |
| `00:10:00;00` | ✅ valid (10분 단위) |

---

## 변경 이력

### v1.0.4 → 보완 (2026-04)
- **설정 영속화**: FPS 모드 / Drop-Frame / 변환 모드가 앱 재시작 후에도 유지
- **HH 범위 검증**: 시간(HH) 입력값 음수 시 에러 표시 (영상 타임코드 특성상 23 초과 허용)
- **키패드 개선**: `-10F` / `-1S` 역방향 스텝 버튼 추가
- **히스토리 로드**: 히스토리 항목의 ↑ 아이콘으로 계산기에 값 즉시 로드
- **히스토리 한도**: 최대 200건 유지 (성능 보호)
- **도메인 테스트**: `validateTimecode` 단위 테스트 19개 추가
- **코드 정리**: 프로덕션 `print()` 디버그 문 제거
