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
CYAN='\033[0;36m'
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

# 기능 브랜치 생성 함수
create_feature_branch() {
    local feature_name=$1
    
    if [ "$AUTO_BRANCH" != "true" ]; then
        return 0
    fi
    
    log_step "기능 브랜치 생성"
    
    # Git 저장소 확인
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Git 저장소가 아닙니다."
        return 1
    fi
    
    # 현재 브랜치 확인
    local current_branch=$(git branch --show-current)
    
    if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
        log_warning "이미 기능 브랜치에 있습니다: $current_branch"
        read -p "현재 브랜치를 사용하시겠습니까? (y/n): " use_current
        if [ "$use_current" == "y" ]; then
            FEATURE_BRANCH="$current_branch"
            log_success "현재 브랜치 사용: $FEATURE_BRANCH"
            return 0
        fi
    fi
    
    # 브랜치 이름 생성
    local timestamp=$(date +%Y%m%d-%H%M%S)
    FEATURE_BRANCH="feature/tdd-${feature_name}-${timestamp}"
    
    log "브랜치 생성: $FEATURE_BRANCH"
    
    # 변경사항이 있는지 확인
    if [ -n "$(git status --porcelain)" ]; then
        log_warning "커밋되지 않은 변경사항이 있습니다."
        read -p "변경사항을 stash 하시겠습니까? (y/n): " do_stash
        if [ "$do_stash" == "y" ]; then
            git stash save "Auto-stash before creating TDD branch"
            log_success "변경사항 stash 완료"
        else
            log_error "브랜치 생성을 취소합니다."
            return 1
        fi
    fi
    
    # 최신 main/master 가져오기
    local main_branch="main"
    if ! git rev-parse --verify main > /dev/null 2>&1; then
        main_branch="master"
    fi
    
    log "최신 $main_branch 브랜치 가져오는 중..."
    git fetch origin "$main_branch" 2>/dev/null || true
    git checkout "$main_branch" 2>/dev/null || true
    git pull origin "$main_branch" 2>/dev/null || true
    
    # 새 브랜치 생성
    git checkout -b "$FEATURE_BRANCH"
    
    log_success "브랜치 생성 완료: $FEATURE_BRANCH"
    echo ""
}

# PR 생성 가이드 출력 함수
show_pr_guide() {
    log_step "PR 생성 가이드 🚀"
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}다음 단계로 PR을 생성하세요:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "1️⃣  리모트로 푸시:"
    echo -e "   ${GREEN}git push -u origin $FEATURE_BRANCH${NC}"
    echo ""
    echo "2️⃣  GitHub에서 PR 생성:"
    echo "   브라우저에서 자동으로 'Create Pull Request' 버튼이 나타납니다."
    echo ""
    echo "3️⃣  PR 템플릿 체크리스트 작성:"
    echo "   ${YELLOW}기본 과제(Hard)${NC}"
    echo "   - [x] Agent 구현 명세 문서 또는 코드"
    echo "   - [x] 커밋별 올바르게 단계에 대한 작업"
    echo "   - [x] 결과를 올바로 얻기위한 history 또는 log"
    echo "   - [x] AI 도구 활용을 개선하기 위해 노력한 점"
    echo ""
    echo "4️⃣  커밋 히스토리 확인:"
    echo -e "   ${GREEN}git log --oneline --graph -n 10${NC}"
    echo ""
    
    # 커밋 히스토리 출력
    if [ "$AUTO_COMMIT" == "true" ]; then
        echo -e "${MAGENTA}📝 생성된 커밋 히스토리:${NC}"
        git log --oneline --graph --color=always -n 10 | sed 's/^/   /'
        echo ""
    fi
    
    # 자동 푸시 옵션
    if [ "$AUTO_PUSH" == "true" ]; then
        echo ""
        read -p "리모트로 푸시하시겠습니까? (y/n): " do_push
        if [ "$do_push" == "y" ]; then
            log "자동 푸시 실행 중..."
            git push -u origin "$FEATURE_BRANCH"
            
            if [ $? -eq 0 ]; then
                log_success "푸시 완료!"
                echo ""
                echo -e "${GREEN}✨ GitHub에서 PR을 생성하세요!${NC}"
                echo ""
                # GitHub 저장소 URL 추출
                local repo_url=$(git remote get-url origin | sed 's/\.git$//' | sed 's/git@github.com:/https:\/\/github.com\//')
                echo "   $repo_url/compare/$FEATURE_BRANCH"
            else
                log_error "푸시 실패"
            fi
        fi
    fi
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Git 자동 커밋 함수
auto_commit() {
    local stage=$1
    local files=$2
    local feature_name=$3
    
    if [ "$AUTO_COMMIT" != "true" ]; then
        return 0
    fi
    
    log "Git 커밋 생성 중..."
    
    # Git 저장소 확인
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warning "Git 저장소가 아닙니다. 커밋을 건너뜁니다."
        return 1
    fi
    
    # 변경사항 확인
    if [ -z "$(git status --porcelain)" ]; then
        log_warning "커밋할 변경사항이 없습니다."
        return 1
    fi
    
    # 파일 추가
    if [ -n "$files" ]; then
        git add $files
    else
        git add .
    fi
    
    # 커밋 메시지 생성
    local commit_message
    case $stage in
        RED)
            commit_message="test: add failing tests for $feature_name (RED)

📝 RED 단계 - 실패하는 테스트 작성
- AAA 패턴 적용
- 엣지 케이스 포함

Generated by TDD Orchestrator"
            ;;
        GREEN)
            commit_message="feat: implement $feature_name (GREEN)

✅ GREEN 단계 - 테스트 통과하는 구현
- 최소한의 구현
- 모든 테스트 통과

Generated by TDD Orchestrator"
            ;;
        REFACTOR)
            commit_message="refactor: improve $feature_name (REFACTOR)

♻️ REFACTOR 단계 - 코드 품질 개선
- DRY 원칙 적용
- 명명 개선
- 복잡도 감소

Generated by TDD Orchestrator"
            ;;
    esac
    
    # 커밋
    git commit -m "$commit_message"
    
    if [ $? -eq 0 ]; then
        log_success "커밋 생성 완료"
        local commit_hash=$(git rev-parse --short HEAD)
        echo -e "${CYAN}  Commit: $commit_hash${NC}"
        return 0
    else
        log_error "커밋 실패"
        return 1
    fi
}

# 코드 블록 추출 및 파일 생성 함수
extract_and_create_file() {
    local result_file=$1
    local default_output=$2
    
    log "코드 블록 추출 중..."
    
    # TypeScript 코드 블록 추출
    awk '/```typescript/,/```/' "$result_file" | sed '/```/d' > /tmp/extracted_code.ts
    
    if [ ! -s /tmp/extracted_code.ts ]; then
        log_warning "코드 블록을 찾을 수 없습니다"
        return 1
    fi
    
    # filepath 주석에서 경로 추출
    local filepath=$(grep -m1 "^// filepath:" /tmp/extracted_code.ts | sed 's|// filepath: ||' | tr -d '\r' | xargs)
    
    if [ -z "$filepath" ]; then
        filepath="$default_output"
        log_warning "파일 경로를 찾을 수 없어 기본 경로 사용: $filepath"
    fi
    
    # 디렉토리 생성
    mkdir -p "$(dirname "$filepath")"
    
    # filepath 주석 제거하고 코드만 저장
    grep -v "^// filepath:" /tmp/extracted_code.ts > "$filepath"
    
    log_success "파일 생성됨: $filepath"
    echo "$filepath"
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
    echo "사용법: $0 <요구사항 파일> [모드] [옵션]"
    echo ""
    echo "모드:"
    echo "  --auto        Claude CLI를 자동으로 실행 (추천)"
    echo "  --interactive 단계별로 확인하며 진행"
    echo "  --manual      프롬프트만 생성 (기본값)"
    echo ""
    echo "옵션:"
    echo "  --commit      각 단계마다 자동으로 Git 커밋"
    echo "  --branch      기능 브랜치 자동 생성 (PR 준비)"
    echo "  --push        리모트로 자동 푸시"
    echo "  --pr          브랜치 생성 + 커밋 + 푸시 (= --branch --commit --push)"
    echo ""
    echo "예시:"
    echo "  # 완전 자동화 (PR 준비)"
    echo "  $0 specs/feature.md --auto --pr"
    echo ""
    echo "  # 브랜치 + 커밋만 (푸시는 수동)"
    echo "  $0 specs/feature.md --auto --branch --commit"
    echo ""
    echo "  # 단계별 확인"
    echo "  $0 specs/feature.md --interactive --branch --commit"
    echo ""
    echo "  # 수동 모드 (프롬프트만 생성)"
    echo "  $0 specs/feature.md --manual"
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
AUTO_COMMIT="false"
AUTO_BRANCH="false"
AUTO_PUSH="false"
FEATURE_BRANCH=""
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
WORKFLOW_LOG="$LOG_DIR/workflow_$TIMESTAMP.log"

# 옵션 파싱
shift 2 2>/dev/null || shift 1 2>/dev/null || true
while [ $# -gt 0 ]; do
    case "$1" in
        --commit)
            AUTO_COMMIT="true"
            ;;
        --branch)
            AUTO_BRANCH="true"
            ;;
        --push)
            AUTO_PUSH="true"
            ;;
        --pr)
            # PR 모드: 브랜치 + 커밋 + 푸시
            AUTO_COMMIT="true"
            AUTO_BRANCH="true"
            AUTO_PUSH="true"
            ;;
        --no-commit)
            AUTO_COMMIT="false"
            ;;
    esac
    shift
done

# 명세 파일 존재 확인
if [ ! -f "$SPEC_FILE" ]; then
    log_error "명세 파일을 찾을 수 없습니다: $SPEC_FILE"
    exit 1
fi

# 기능 이름 추출 (커밋 메시지용)
FEATURE_NAME=$(basename "$SPEC_FILE" .md)

log "TDD 워크플로우 시작: $SPEC_FILE"
log "모드: $MODE"
log "자동 커밋: $AUTO_COMMIT"
log "자동 브랜치: $AUTO_BRANCH"
log "자동 푸시: $AUTO_PUSH"
log "로그 파일: $WORKFLOW_LOG"
echo ""

# ✅ 워크플로우 시작 전에 기능 브랜치 생성
if [ "$AUTO_BRANCH" == "true" ]; then
    create_feature_branch "$FEATURE_NAME"
    
    if [ $? -ne 0 ]; then
        log_error "브랜치 생성 실패. 워크플로우를 종료합니다."
        exit 1
    fi
fi

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

# 3. RED - 실패하는 테스트 작성 (자동 커밋 추가)
log_step "3단계: RED - 실패하는 테스트 작성"

PROMPT_FILE="$LOG_DIR/step3_red.prompt"
RESULT_FILE="$RESULTS_DIR/step3_red_$TIMESTAMP.md"
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
\`\`\`typescript
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
\`\`\`

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
    
    # ✅ 테스트 파일 자동 생성
    log_step "테스트 파일 자동 생성"
    TEST_FILE=$(extract_and_create_file "$RESULT_FILE" "src/__tests__/unit/${FEATURE_NAME}.spec.ts")
    
    if [ $? -eq 0 ]; then
        log_success "테스트 파일 생성 완료: $TEST_FILE"
        
        echo ""
        log "테스트 실행 중..."
        pnpm test "$TEST_FILE" || true  # 실패해도 계속 진행
        echo ""
        
        # ✅ RED 단계 자동 커밋
        auto_commit "RED" "$TEST_FILE" "$FEATURE_NAME"
    else
        log_warning "수동으로 코드를 복사하세요: $RESULT_FILE"
    fi
    
    read -p "테스트 확인 후 Enter를 누르세요..." 
elif [ "$MODE" == "--interactive" ]; then
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "RED 단계"
        
        read -p "테스트 파일을 자동으로 생성하시겠습니까? (y/n): " create_file
        if [ "$create_file" == "y" ]; then
            TEST_FILE=$(extract_and_create_file "$RESULT_FILE" "src/__tests__/unit/${FEATURE_NAME}.spec.ts")
            pnpm test "$TEST_FILE" || true
            
            if [ "$AUTO_COMMIT" == "true" ]; then
                auto_commit "RED" "$TEST_FILE" "$FEATURE_NAME"
            fi
        fi
        
        read -p "테스트 파일 추가 후 Enter를 누르세요..." 
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "3단계 완료"

# 4. GREEN - 테스트 통과하는 구현 (자동 커밋 추가)
log_step "4단계: GREEN - 테스트 통과 구현"

PROMPT_FILE="$LOG_DIR/step4_green.prompt"
RESULT_FILE="$RESULTS_DIR/step4_green_$TIMESTAMP.md"
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
\`\`\`typescript
// filepath: src/utils/[기능명].ts

export interface ValidationResult {
  isValid: boolean;
  error?: string;
  warning?: string;
}

export function functionName(...): ValidationResult {
  // 구현
}
\`\`\`

원칙:
1. 테스트를 통과시키는 가장 간단한 코드
2. 하드코딩도 허용 (리팩토링에서 개선)
3. 빠른 피드백 중심

**주의: TypeScript 타입 정의 포함, 완전한 실행 가능 코드 작성**
PROMPT

if [ "$MODE" == "--auto" ]; then
    run_claude "$PROMPT_FILE" "$RESULT_FILE" "GREEN 단계"
    
    # ✅ 구현 파일 자동 생성
    log_step "구현 파일 자동 생성"
    IMPL_FILE=$(extract_and_create_file "$RESULT_FILE" "src/utils/${FEATURE_NAME}.ts")
    
    if [ $? -eq 0 ]; then
        log_success "구현 파일 생성 완료: $IMPL_FILE"
        
        echo ""
        log "테스트 실행 중..."
        pnpm test "$TEST_FILE"
        
        # ✅ GREEN 단계 자동 커밋 (테스트 통과 확인 후)
        if [ $? -eq 0 ]; then
            log_success "모든 테스트 통과!"
            auto_commit "GREEN" "$IMPL_FILE" "$FEATURE_NAME"
        else
            log_error "테스트 실패. 커밋을 건너뜁니다."
        fi
        echo ""
    else
        log_warning "수동으로 코드를 복사하세요: $RESULT_FILE"
    fi
    
    read -p "구현 확인 후 Enter를 누르세요..." 
elif [ "$MODE" == "--interactive" ]; then
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "GREEN 단계"
        
        read -p "구현 파일을 자동으로 생성하시겠습니까? (y/n): " create_file
        if [ "$create_file" == "y" ]; then
            IMPL_FILE=$(extract_and_create_file "$RESULT_FILE" "src/utils/${FEATURE_NAME}.ts")
            pnpm test "$TEST_FILE"
            
            if [ $? -eq 0 ] && [ "$AUTO_COMMIT" == "true" ]; then
                auto_commit "GREEN" "$IMPL_FILE" "$FEATURE_NAME"
            fi
        fi
        
        read -p "구현 파일 추가 후 Enter를 누르세요..." 
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "4단계 완료"

# 5. REFACTOR - 코드 개선 (자동 커밋 추가)
log_step "5단계: REFACTOR - 코드 개선"

PROMPT_FILE="$LOG_DIR/step5_refactor.prompt"
RESULT_FILE="$RESULTS_DIR/step5_refactor_$TIMESTAMP.md"
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
\`\`\`typescript
// filepath: src/utils/[기능명].ts

// 개선된 코드
\`\`\`

**중요: 리팩토링 후에도 모든 테스트가 통과해야 합니다!**

개선 포인트를 설명하고 개선된 전체 코드를 제공하세요.
PROMPT

if [ "$MODE" == "--auto" ]; then
    run_claude "$PROMPT_FILE" "$RESULT_FILE" "REFACTOR 단계"
    
    # ✅ 리팩토링된 코드 적용
    log_step "리팩토링된 코드 적용"
    REFACTORED_FILE=$(extract_and_create_file "$RESULT_FILE" "$IMPL_FILE")
    
    if [ $? -eq 0 ]; then
        log_success "리팩토링 완료: $REFACTORED_FILE"
        
        echo ""
        log "최종 테스트 실행 중..."
        pnpm test
        
        # ✅ REFACTOR 단계 자동 커밋 (테스트 통과 확인 후)
        if [ $? -eq 0 ]; then
            log_success "모든 테스트 통과!"
            auto_commit "REFACTOR" "$REFACTORED_FILE" "$FEATURE_NAME"
        else
            log_error "테스트 실패. 리팩토링을 롤백하세요."
            log_warning "롤백 명령: git checkout $REFACTORED_FILE"
        fi
        echo ""
    else
        log_warning "수동으로 코드를 복사하세요: $RESULT_FILE"
    fi
elif [ "$MODE" == "--interactive" ]; then
    read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
    if [ "$confirm" == "y" ]; then
        run_claude "$PROMPT_FILE" "$RESULT_FILE" "REFACTOR 단계"
        
        read -p "리팩토링된 코드를 적용하시겠습니까? (y/n): " apply_code
        if [ "$apply_code" == "y" ]; then
            REFACTORED_FILE=$(extract_and_create_file "$RESULT_FILE" "$IMPL_FILE")
            pnpm test
            
            if [ $? -eq 0 ] && [ "$AUTO_COMMIT" == "true" ]; then
                auto_commit "REFACTOR" "$REFACTORED_FILE" "$FEATURE_NAME"
            fi
        fi
    fi
else
    log "프롬프트 생성: $PROMPT_FILE"
fi

log_success "5단계 완료"

# 완료
log_step "워크플로우 완료! 🎉"
log_success "모든 단계가 완료되었습니다"
echo ""

# ✅ PR 생성 가이드 출력
if [ "$AUTO_BRANCH" == "true" ]; then
    show_pr_guide
fi

log "생성된 파일:"
echo "  📁 프롬프트: $LOG_DIR/"
echo "  📁 결과: $RESULTS_DIR/"
if [ -n "$TEST_FILE" ]; then
    echo "  📄 테스트: $TEST_FILE"
fi
if [ -n "$IMPL_FILE" ]; then
    echo "  📄 구현: $IMPL_FILE"
fi
echo ""

log "최종 체크리스트:"
echo "  1. ✅ 테스트 작성 완료"
echo "  2. ✅ 구현 완료"
echo "  3. ✅ 리팩토링 완료"
if [ "$AUTO_COMMIT" == "true" ]; then
    echo "  4. ✅ Git 커밋 완료"
fi
if [ "$AUTO_BRANCH" == "true" ]; then
    echo "  5. ⬜ 리모트로 푸시 (git push -u origin $FEATURE_BRANCH)"
    echo "  6. ⬜ GitHub에서 PR 생성"
else
    echo "  4. ⬜ pnpm test 실행하여 모든 테스트 통과 확인"
    echo "  5. ⬜ git add & commit으로 변경사항 저장"
fi
echo ""

if [ "$MODE" == "--manual" ]; then
    log "💡 팁: 다음번엔 자동 모드를 사용해보세요!"
    echo "  $0 $SPEC_FILE --auto --pr"
fi
