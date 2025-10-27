# TDD 워크플로우 자동화 시스템

클로드 CLI를 활용한 자동화된 TDD(Test-Driven Development) 워크플로우 시스템입니다.

## 🚀 빠른 시작

### 1. Claude CLI 설치 (선택사항)

```bash
npm install -g @anthropic-ai/claude-cli
```

### 2. 명세 파일 작성

```bash
# specs/your-feature.md 파일 생성
```

### 3. TDD 워크플로우 실행

```bash
# 자동 모드 (Claude CLI 사용) - 추천! ⭐
./agents/orchestrator.sh specs/your-feature.md --auto

# 대화형 모드 (단계별 확인)
./agents/orchestrator.sh specs/your-feature.md --interactive

# 수동 모드 (프롬프트만 생성)
./agents/orchestrator.sh specs/your-feature.md --manual
```

## 시스템 구조

```
agents/
├── orchestrator.sh          # 전체 워크플로우 오케스트레이터
├── run-agent.sh            # 개별 에이전트 실행기
├── logs/                   # 생성된 프롬프트 저장
├── results/                # Claude CLI 응답 저장 (자동 모드)
├── orchestrator/
│   └── orchestrator.md     # 오케스트레이터 명세
├── spec-validator/
│   └── prompt.md           # 명세 검증 에이전트
├── test-designer/
│   └── prompt.md           # 테스트 설계 에이전트
└── tdd-cycle/
    ├── red.md              # RED 단계 에이전트
    ├── green.md            # GREEN 단계 에이전트
    └── refactor.md         # REFACTOR 단계 에이전트
```

## 에이전트 소개

### 0. 오케스트레이터

전체 TDD 워크플로우를 조율하고 각 단계를 순차적으로 실행합니다.

**역할:**

- 워크플로우 전체 관리
- 각 에이전트 순차 실행
- 로그 및 결과 기록

### 1. 명세 검증 에이전트 (Spec Validator)

요구사항 명세를 검증하고 개선합니다.

**검증 항목:**

- ✓ 명확성: 모호하지 않은 요구사항
- ✓ 완전성: 모든 시나리오 포함
- ✓ 테스트 가능성: 검증 가능한 조건
- ✓ 일관성: 요구사항 간 충돌 없음

### 2. 테스트 설계 에이전트 (Test Designer)

검증된 명세를 기반으로 체계적인 테스트 케이스를 설계합니다.

**설계 원칙:**

- AAA 패턴 (Arrange-Act-Assert)
- 테스트 독립성
- 명확한 의도
- 경계 테스트 포함

### 3. RED 단계 에이전트

실패하는 테스트를 먼저 작성합니다.

**원칙:**

- 구현 전 테스트 작성
- 명확한 실패 메시지
- 하나씩 추가

### 4. GREEN 단계 에이전트

테스트를 통과시키는 최소 구현을 작성합니다.

**원칙:**

- 최소한의 코드
- 빠른 피드백
- 하드코딩 허용

### 5. REFACTOR 단계 에이전트

테스트를 유지하면서 코드를 개선합니다.

**개선 항목:**

- 중복 제거
- 명명 개선
- 함수 분리
- 복잡도 감소

## 사용 방법

### 🤖 방법 1: 자동 모드 (Claude CLI) - 추천!

Claude CLI가 설치되어 있으면 **완전 자동화**로 실행됩니다:

```bash
./agents/orchestrator.sh specs/example-feature.md --auto
```

**동작:**

1. ✅ 각 단계의 프롬프트를 자동으로 Claude CLI에 전달
2. ✅ Claude의 응답을 `agents/results/` 에 자동 저장
3. ✅ 각 단계 결과를 터미널에 출력
4. ⏸️ 코드 적용 후 다음 단계로 진행

**예시 출력:**

```
[ORCHESTRATOR] Claude CLI로 명세 검증 실행 중...
✓ Claude 응답 저장됨: agents/results/step1_validation_20231027_143022.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 Claude 응답:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## 검증 결과

### 명확성
- 평가: 통과
- 의견: 입력/출력이 명확하게 정의되어 있습니다.
...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 👥 방법 2: 대화형 모드 (Interactive)

각 단계마다 실행 여부를 선택할 수 있습니다:

```bash
./agents/orchestrator.sh specs/example-feature.md --interactive
```

**동작:**

- 각 단계마다 "Claude CLI로 실행하시겠습니까? (y/n):" 프롬프트 표시
- `y`: Claude CLI로 자동 실행
- `n`: 프롬프트 파일 경로만 표시 (수동 복사)

### 📝 방법 3: 수동 모드 (Manual)

프롬프트 파일만 생성하고 직접 복사/붙여넣기:

```bash
./agents/orchestrator.sh specs/example-feature.md --manual
# 또는 모드 생략 (기본값)
./agents/orchestrator.sh specs/example-feature.md
```

**동작:**

- `agents/logs/` 에 5개의 프롬프트 파일 생성
- 각 파일을 복사하여 Claude (또는 Copilot)에게 전달

### 🔧 방법 4: 개별 에이전트 실행

특정 단계만 실행하려면:

```bash
# 명세 검증만
./agents/run-agent.sh spec-validator specs/example-feature.md

# 테스트 설계만
./agents/run-agent.sh test-designer specs/example-feature.md

# RED 단계만
./agents/run-agent.sh red specs/test-design.md
```

## 워크플로우 예시

### 1단계: 명세 검증

```bash
./agents/run-agent.sh spec-validator specs/example-feature.md
```

**출력:** 검증 결과 및 개선된 명세

### 2단계: 테스트 설계

```bash
./agents/run-agent.sh test-designer specs/example-feature.md
```

**출력:** 테스트 케이스 설계 (Given-When-Then)

### 3단계: RED - 테스트 작성

Claude에게 테스트 설계를 전달하고 테스트 코드 생성

```bash
# 테스트 실패 확인
pnpm test src/__tests__/your-feature.spec.ts
```

### 4단계: GREEN - 구현

Claude에게 실패하는 테스트를 전달하고 구현 코드 생성

```bash
# 테스트 통과 확인
pnpm test src/__tests__/your-feature.spec.ts
```

### 5단계: REFACTOR - 개선

Claude에게 구현 코드를 전달하고 리팩토링

```bash
# 테스트 여전히 통과 확인
pnpm test
```

### 자동 모드 전체 실행

```bash
# 1. 오케스트레이터 실행
./agents/orchestrator.sh specs/example-feature.md --auto

# 출력:
# ======================================
# 1단계: 명세 검증
# ======================================
#
# [ORCHESTRATOR] Claude CLI로 명세 검증 실행 중...
# ✓ Claude 응답 저장됨: agents/results/step1_validation_20231027_143022.md
#
# [Claude의 검증 결과가 표시됨]
#
# ✓ 1단계 완료
#
# ======================================
# 2단계: 테스트 설계
# ======================================
#
# [ORCHESTRATOR] Claude CLI로 테스트 설계 실행 중...
# ...

# 2. RED 단계에서 생성된 테스트 코드를 프로젝트에 추가
# agents/results/step3_red_*.md 파일의 코드를 복사
# src/__tests__/unit/dateRangeValidator.spec.ts 생성

# 3. 테스트 실패 확인
pnpm test src/__tests__/unit/dateRangeValidator.spec.ts
# ❌ FAIL - Expected: 구현이 없어서 실패

# 4. Enter를 눌러 다음 단계(GREEN)로 진행

# 5. GREEN 단계에서 생성된 구현 코드를 프로젝트에 추가
# agents/results/step4_green_*.md 파일의 코드를 복사
# src/utils/dateRangeValidator.ts 생성

# 6. 테스트 통과 확인
pnpm test src/__tests__/unit/dateRangeValidator.spec.ts
# ✅ PASS

# 7. Enter를 눌러 REFACTOR 단계로 진행

# 8. 개선된 코드로 교체하고 최종 검증
pnpm test
# ✅ All tests passed
```

## Claude CLI와 함께 사용

Claude CLI가 설치되어 있다면:

```bash
# 프롬프트 직접 실행
cat agents/logs/step1_spec_validation.prompt | claude

# 또는 파일로 저장
cat agents/logs/step1_spec_validation.prompt | claude > results/step1_result.md
```

## 로그 및 결과

모든 프롬프트와 결과는 `agents/logs/` 디렉토리에 저장됩니다:

```
agents/logs/
├── workflow_20251027_143022.log
├── step1_spec_validation.prompt
├── step2_test_design.prompt
├── step3_red.prompt
├── step4_green.prompt
└── step5_refactor.prompt
```

### 프롬프트 파일 (`agents/logs/`)

각 단계의 프롬프트가 저장됩니다:

- `step1_spec_validation.prompt` - 명세 검증 프롬프트
- `step2_test_design.prompt` - 테스트 설계 프롬프트
- `step3_red.prompt` - RED 단계 프롬프트
- `step4_green.prompt` - GREEN 단계 프롬프트
- `step5_refactor.prompt` - REFACTOR 단계 프롬프트

### Claude 응답 (`agents/results/`)

자동 모드 실행 시 Claude의 응답이 저장됩니다:

- `step1_validation_20231027_143022.md` - 명세 검증 결과
- `step2_design_20231027_143022.md` - 테스트 설계
- `step3_red_20231027_143022.md` - 테스트 코드
- `step4_green_20231027_143022.md` - 구현 코드
- `step5_refactor_20231027_143022.md` - 리팩토링 코드

## 베스트 프랙티스

### 1. 명세 작성

- 구체적이고 측정 가능한 요구사항
- 입력/출력 명확히 정의
- 엣지 케이스 포함

### 2. 테스트 작성

- 테스트 이름에 의도 명확히
- Given-When-Then 패턴 사용
- 독립적인 테스트

### 3. 구현

- RED: 테스트부터 작성
- GREEN: 최소 구현
- REFACTOR: 점진적 개선

### 4. 모드 선택 가이드

| 상황              | 추천 모드       | 이유                         |
| ----------------- | --------------- | ---------------------------- |
| 빠른 프로토타이핑 | `--auto`        | 완전 자동화로 빠른 진행      |
| 학습/이해 중심    | `--interactive` | 각 단계를 확인하며 학습      |
| Claude CLI 없음   | `--manual`      | Copilot 등 다른 AI 도구 사용 |
| 특정 단계만       | `run-agent.sh`  | 필요한 부분만 실행           |

### 5. 커밋 전략

```bash
# RED 단계
git add src/__tests__/feature.spec.ts
git commit -m "test: add failing tests for feature"

# GREEN 단계
git add src/feature.ts
git commit -m "feat: implement feature to pass tests"

# REFACTOR 단계
git add src/feature.ts
git commit -m "refactor: improve feature implementation"
```

## 문제 해결

### Claude CLI 설치 확인

```bash
# Claude CLI 설치 여부 확인
which claude

# 없으면 설치
npm install -g @anthropic-ai/claude-cli

# 또는 yarn
yarn global add @anthropic-ai/claude-cli
```

### Claude CLI 인증

```bash
# API 키 설정
claude configure

# 또는 환경 변수
export ANTHROPIC_API_KEY="your-api-key"
```

### 자동 모드가 수동으로 전환되는 경우

```
[ORCHESTRATOR] Claude CLI로 명세 검증 실행 중...
✗ Claude CLI가 설치되지 않았습니다
⚠ 수동 모드로 전환합니다
```

**해결:**

1. Claude CLI 설치: `npm install -g @anthropic-ai/claude-cli`
2. 또는 `--manual` 모드 사용

### 테스트가 실행되지 않음

```bash
# Vitest 설치 확인
pnpm install

# 테스트 파일 경로 확인
pnpm test --reporter=verbose
```

### 프롬프트가 생성되지 않음

```bash
# 스크립트 실행 권한 확인
chmod +x agents/*.sh

# 디렉토리 생성
mkdir -p agents/logs agents/results
```

## 확장 가능성

새로운 에이전트 추가:

1. `agents/new-agent/prompt.md` 생성
2. `run-agent.sh`에 케이스 추가
3. `orchestrator.sh`에 단계 추가

## 기여

이 시스템을 개선하기 위한 제안:

- 더 나은 프롬프트 엔지니어링
- 자동화 스크립트 개선
- 새로운 에이전트 추가
- VS Code Extension 개발
- MCP 서버 통합

## FAQ

### Q: Claude CLI 없이도 사용 가능한가요?

A: 네! `--manual` 모드로 프롬프트를 생성하고 Copilot이나 다른 AI에게 전달할 수 있습니다.

### Q: 어떤 모드를 사용해야 하나요?

A:

- Claude CLI 있음 → `--auto` (완전 자동화)
- 학습 목적 → `--interactive` (단계별 확인)
- Copilot 사용 → `--manual` (프롬프트 복사)

### Q: 중간에 멈춰도 되나요?

A: 네! 언제든지 Ctrl+C로 중단하고 나중에 `run-agent.sh`로 특정 단계부터 재시작할 수 있습니다.

### Q: 결과를 어디서 확인하나요?

A:

- 프롬프트: `agents/logs/`
- Claude 응답: `agents/results/`
- 최종 코드: `src/` (직접 추가한 파일)

## 라이선스

MIT License
