#!/bin/bash

# TDD 워크플로우 오케스트레이터
# 전체 TDD 사이클을 자동으로 실행합니다.

set -e

AGENTS_DIR="agents"
LOG_DIR="agents/logs"
RESULTS_DIR="agents/results"
mkdir -p "$LOG_DIR" "$RESULTS_DIR"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 로그 함수
log() {
    echo -e "${BLUE}[ORCHESTRATOR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_step() {
    echo -e "\n${YELLOW}======================================${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}======================================${NC}\n"
}

# Claude CLI 실행 함수
run_claude() {
    local prompt_file=$1
    local output_file=$2
    local step_name=$3
    
    log "Claude CLI로 $step_name 실행 중..."
    
    # Claude CLI가 설치되어 있는지 확인
    if ! command -v claude &> /dev/null; then
        log_error "Claude CLI가 설치되지 않았습니다"
        log_warning "수동 모드로 전환합니다"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📋 다음 내용을 Claude에게 전달하세요:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$prompt_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        read -p "완료 후 Enter를 누르세요..." 
        return 1
    fi
    
    # Claude CLI로 프롬프트 실행
    if cat "$prompt_file" | claude > "$output_file" 2>&1; then
        log_success "Claude 응답 저장됨: $output_file"
        echo ""
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${MAGENTA}📄 Claude 응답:${NC}"
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        cat "$output_file"
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        return 0
    else
        log_error "Claude 실행 실패"
        cat "$output_file"
        return 1
    fi
}

# 사용법 출력
show_usage() {
    echo "사용법: $0 <요구사항 파일> [모드]"
    echo ""
    echo "모드:"
    echo "  --auto        Claude CLI를 자동으로 실행 (추천)"
    echo "  --interactive 단계별로 확인하며 진행"
    echo "  --manual      프롬프트만 생성 (기본값)"
    echo ""
    echo "예시:"
    echo "  $0 specs/feature.md --auto"
    echo "  $0 specs/feature.md --interactive"
    echo "  $0 specs/feature.md"
    echo ""
    echo "Claude CLI 설치:"
    echo "  npm install -g @anthropic-ai/claude-cli"
}

# 인자 확인
if [ "$#" -lt 1 ]; then
    show_usage
    exit 1
fi

SPEC_FILE="$1"
MODE="${2:---manual}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
WORKFLOW_LOG="$LOG_DIR/workflow_$TIMESTAMP.log"

# 명세 파일 존재 확인
if [ ! -f "$SPEC_FILE" ]; then
    log_error "명세 파일을 찾을 수 없습니다: $SPEC_FILE"
    exit 1
fi

log "TDD 워크플로우 시작: $SPEC_FILE"
log "모드: $MODE"
log "로그 파일: $WORKFLOW_LOG"

# 1. 명세 검증
log_step "1단계: 명세 검증"

PROMPT_FILE="$LOG_DIR/step1_spec_validation.prompt"
RESULT_FILE="$RESULTS_DIR/step1_validation_$TIMESTAMP.md"

cat > "$PROMPT_FILE" << PROMPT
당신은 요구사항 명세를 검증하는 전문가입니다.

다음 명세를 검토하고 검증해주세요:

$(cat "$SPEC_FILE")

다음 기준으로 검증하세요:
1. 명확성: 요구사항이 모호하지 않고 구체적인가?
2. 완전성: 모든 시나리오와 엣지 케이스가 포함되어 있는가?
3. 테스트 가능성: 검증 가능한 조건이 명시되어 있는가?
4. 일관성: 요구사항 간 충돌이 없는가?

결과를 다음 형식으로 제공하세요:

## 검증 결과

### 명확성
- 평가: [통과/개선 필요]
- 의견: ...

### 완전성
- 평가: [통과/개선 필요]
- 의견: ...

### 테스트 가능성
- 평가: [통과/개선 필요]
- 의견: ...

### 일관성
- 평가: [통과/개선 필요]
- 의견: ...

## 개선된 명세

[개선된 명세 내용]
PROMPT

if [ "$MODE" == "--auto" ]; then
    run_claude "$PROMPT_FILE" "$RESULT_FILE" "명세 검증"
elif [ "$MODE" == "--interactive" ]; then
    log "프롬프트 생성 완료"
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "명세 검증"
    else
        log "프롬프트 파일: $PROMPT_FILE"
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "1단계 완료"

# 2. 테스트 설계
log_step "2단계: 테스트 설계"

PROMPT_FILE="$LOG_DIR/step2_test_design.prompt"
RESULT_FILE="$RESULTS_DIR/step2_design_$TIMESTAMP.md"

cat > "$PROMPT_FILE" << PROMPT
당신은 테스트 설계 전문가입니다.

검증된 명세를 바탕으로 테스트 케이스를 설계해주세요:

$(cat "$SPEC_FILE")

다음 원칙을 따르세요:
- AAA 패턴 (Arrange-Act-Assert)
- 테스트 독립성
- 명확한 의도
- 경계 테스트 포함

테스트 분류:
- Unit Tests: 개별 함수 테스트
- Integration Tests: 컴포넌트 간 상호작용
- Edge Cases: 경계값, 예외 상황

각 테스트 케이스에 대해:
- 이름: should [expected behavior] when [condition]
- Given-When-Then 형식으로 설명
- 우선순위 (high/medium/low)

프로젝트 구조:
- 테스트 프레임워크: Vitest
- 테스트 위치: src/__tests__/
- React 컴포넌트: @testing-library/react 사용

## 출력 형식

### 테스트 스위트: [기능명]

#### 테스트 케이스 1
- **이름**: should ...
- **타입**: unit/integration/edge
- **우선순위**: high/medium/low
- **Given**: ...
- **When**: ...
- **Then**: ...

[나머지 테스트 케이스들...]
PROMPT

if [ "$MODE" == "--auto" ]; then
    run_claude "$PROMPT_FILE" "$RESULT_FILE" "테스트 설계"
elif [ "$MODE" == "--interactive" ]; then
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "테스트 설계"
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "2단계 완료"

# 3. RED - 실패하는 테스트 작성
log_step "3단계: RED - 실패하는 테스트 작성"

PROMPT_FILE="$LOG_DIR/step3_red.prompt"
RESULT_FILE="$RESULTS_DIR/step3_red_$TIMESTAMP.md"

# ✅ 이전 단계(Step 2) 결과 파일 찾기
STEP2_RESULT=$(ls -t "$RESULTS_DIR"/step2_design_*.md 2>/dev/null | head -1)

cat > "$PROMPT_FILE" << PROMPT
당신은 TDD RED 단계 전문가입니다.

## 원본 명세

$(cat "$SPEC_FILE")

## 테스트 설계 결과 (Step 2)

$(if [ -f "$STEP2_RESULT" ]; then cat "$STEP2_RESULT"; else echo "테스트 설계 결과가 없습니다. 명세를 기반으로 직접 설계하세요."; fi)

---

위의 테스트 설계를 바탕으로 **완전한 Vitest 테스트 코드**를 작성해주세요.

**중요: 반드시 실행 가능한 TypeScript 코드만 제공하세요!**

출력 형식:
\`\`\`\`typescript
// filepath: src/__tests__/unit/[기능명].spec.ts
import { describe, it, expect } from 'vitest';
import { functionName } from '../../utils/[파일명]';

describe('테스트 스위트', () => {
  describe('카테고리', () => {
    it('should ...', () => {
      // Arrange
      const input = ...;
      
      // Act
      const result = functionName(input);
      
      // Assert
      expect(result).toBe(...);
    });
  });
});
\`\`\`\`

요구사항:
- Vitest 프레임워크
- TypeScript
- AAA 패턴
- 최소 10개 이상의 테스트
- 모든 엣지 케이스 포함

**주의: 설명이나 구조 안내가 아닌, 복사해서 바로 실행 가능한 코드만 작성하세요.**
PROMPT

if [ "$MODE" == "--auto" ]; then
    run_claude "$PROMPT_FILE" "$RESULT_FILE" "RED 단계"
    log_warning "생성된 테스트 코드를 프로젝트에 추가하세요"
    echo ""
    log "다음 명령으로 테스트 실패를 확인하세요:"
    echo "  pnpm test [테스트 파일명]"
    echo ""
    read -p "테스트 파일 추가 후 Enter를 누르세요..." 
elif [ "$MODE" == "--interactive" ]; then
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "RED 단계"
        read -p "테스트 파일 추가 후 Enter를 누르세요..." 
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "3단계 완료"

# 4. GREEN - 테스트 통과하는 구현
log_step "4단계: GREEN - 테스트 통과 구현"

PROMPT_FILE="$LOG_DIR/step4_green.prompt"
RESULT_FILE="$RESULTS_DIR/step4_green_$TIMESTAMP.md"

# ✅ 이전 단계(Step 3) 결과 파일 찾기
STEP3_RESULT=$(ls -t "$RESULTS_DIR"/step3_red_*.md 2>/dev/null | head -1)

cat > "$PROMPT_FILE" << PROMPT
당신은 TDD GREEN 단계 전문가입니다.

## 원본 명세

$(cat "$SPEC_FILE")

## RED 단계 테스트 코드 (Step 3)

$(if [ -f "$STEP3_RESULT" ]; then cat "$STEP3_RESULT"; else echo "테스트 코드가 없습니다."; fi)

---

위의 테스트를 통과시키는 **최소한의 구현**을 작성해주세요.

출력 형식:
\`\`\`\`typescript
// filepath: src/utils/[기능명].ts

export interface ValidationResult {
  isValid: boolean;
  error?: string;
  warning?: string;
}

export function functionName(...): ValidationResult {
  // 구현
}
\`\`\`\`

원칙:
1. 테스트를 통과시키는 가장 간단한 코드
2. 하드코딩도 허용 (리팩토링에서 개선)
3. 빠른 피드백 중심

**주의: TypeScript 타입 정의 포함, 완전한 실행 가능 코드 작성**
PROMPT

if [ "$MODE" == "--auto" ]; then
    run_claude "$PROMPT_FILE" "$RESULT_FILE" "GREEN 단계"
    log_warning "생성된 구현 코드를 프로젝트에 추가하세요"
    echo ""
    log "다음 명령으로 테스트 통과를 확인하세요:"
    echo "  pnpm test [테스트 파일명]"
    echo ""
    read -p "구현 파일 추가 후 Enter를 누르세요..." 
elif [ "$MODE" == "--interactive" ]; then
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "GREEN 단계"
        read -p "구현 파일 추가 후 Enter를 누르세요..." 
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "4단계 완료"

# 5. REFACTOR - 코드 개선
log_step "5단계: REFACTOR - 코드 개선"

PROMPT_FILE="$LOG_DIR/step5_refactor.prompt"
RESULT_FILE="$RESULTS_DIR/step5_refactor_$TIMESTAMP.md"

# ✅ 이전 단계(Step 4) 결과 파일 찾기
STEP4_RESULT=$(ls -t "$RESULTS_DIR"/step4_green_*.md 2>/dev/null | head -1)

cat > "$PROMPT_FILE" << PROMPT
당신은 TDD REFACTOR 단계 전문가입니다.

## 원본 명세

$(cat "$SPEC_FILE")

## GREEN 단계 구현 코드 (Step 4)

$(if [ -f "$STEP4_RESULT" ]; then cat "$STEP4_RESULT"; else echo "구현 코드가 없습니다."; fi)

---

위의 코드를 개선해주세요.

리팩토링 체크리스트:
- [ ] 중복 제거 (DRY 원칙)
- [ ] 명명 개선 (의도를 명확히)
- [ ] 함수 분리 (단일 책임)
- [ ] 매직 넘버/스트링 제거
- [ ] 복잡도 감소
- [ ] TypeScript 타입 개선
- [ ] 주석 추가 (필요시)

출력 형식:
\`\`\`\`typescript
// filepath: src/utils/[기능명].ts

// 개선된 코드
\`\`\`\`

**중요: 리팩토링 후에도 모든 테스트가 통과해야 합니다!**

개선 포인트를 설명하고 개선된 전체 코드를 제공하세요.
PROMPT

if [ "$MODE" == "--auto" ]; then
    run_claude "$PROMPT_FILE" "$RESULT_FILE" "REFACTOR 단계"
    log_warning "개선된 코드로 교체하세요"
    echo ""
    log "다음 명령으로 최종 검증하세요:"
    echo "  pnpm test"
    echo ""
    read -p "코드 교체 후 Enter를 누르세요..." 
elif [ "$MODE" == "--interactive" ]; then
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "REFACTOR 단계"
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "5단계 완료"

# 완료
log_step "워크플로우 완료! 🎉"
log_success "모든 단계가 완료되었습니다"
echo ""
log "생성된 파일:"
echo "  📁 프롬프트: $LOG_DIR/"
echo "  📁 결과: $RESULTS_DIR/"
echo ""
log "다음 단계:"
echo "  1. 생성된 테스트와 구현 코드를 프로젝트에 적용"
echo "  2. pnpm test 로 최종 검증"
echo "  3. git add & commit으로 변경사항 저장"
echo ""

if [ "$MODE" == "--manual" ]; then
    log "💡 팁: 다음번엔 자동 모드를 사용해보세요!"
    echo "  $0 $SPEC_FILE --auto"
fi
