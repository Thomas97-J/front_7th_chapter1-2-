#!/bin/bash
# TDD 워크플로우 오케스트레이터
# 전체 TDD 사이클을 자동으로 실행합니다.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 공통 라이브러리 로드
source "$SCRIPT_DIR/lib/common.sh"
source "$AGENTS_ROOT/lib/git.sh"
source "$AGENTS_ROOT/lib/extract.sh"

# 각 단계 스크립트 로드
source "$AGENTS_ROOT/steps/step1_validation.sh"
source "$AGENTS_ROOT/steps/step2_design.sh"
source "$AGENTS_ROOT/steps/step3_red.sh"
source "$AGENTS_ROOT/steps/step4_green.sh"
source "$AGENTS_ROOT/steps/step5_refactor.sh"

# 디렉토리 생성
mkdir -p agents/logs agents/results

# ✅ 재시도 로직 함수
retry_step() {
    local step_name=$1
    local step_function=$2
    local max_retries=$3
    shift 3
    local step_args=("$@")
    
    local retry_count=0
    local success=false
    
    while [ $retry_count -lt $max_retries ]; do
        if [ $retry_count -gt 0 ]; then
            log_warning "재시도 $retry_count/$((max_retries - 1))..."
            echo ""
            
            # 이전 실패 정보 출력
            if [ -f "/tmp/test_output.log" ]; then
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "이전 실패 원인:"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                tail -20 /tmp/test_output.log
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
            fi
            
            read -p "계속하려면 Enter를 누르세요 (q로 중단)... " continue_retry
            if [ "$continue_retry" == "q" ]; then
                log_warning "$step_name 중단됨"
                return 1
            fi
        fi
        
        # Step 함수 실행
        set +e
        $step_function "${step_args[@]}"
        local step_result=$?
        set -e
        
        if [ $step_result -eq 0 ]; then
            success=true
            break
        else
            retry_count=$((retry_count + 1))
            
            if [ $retry_count -lt $max_retries ]; then
                log_error "$step_name 실패 (시도 $retry_count/$((max_retries - 1)))"
                
                if [ "$MODE" == "--interactive" ]; then
                    echo ""
                    read -p "수동으로 수정하시겠습니까? (y/n): " manual_fix
                    if [ "$manual_fix" == "y" ]; then
                        echo ""
                        echo "💡 수정 가이드:"
                        echo "  1. 에디터로 파일 수정"
                        echo "  2. 테스트 실행: pnpm test"
                        echo "  3. 통과하면 이 창으로 돌아와 Enter"
                        echo ""
                        read -p "수정 완료 후 Enter를 누르세요... "
                        
                        # 테스트 재실행
                        if pnpm test 2>&1 | tee /tmp/test_output.log; then
                            log_success "테스트 통과!"
                            success=true
                            break
                        fi
                    fi
                fi
            fi
        fi
    done
    
    if [ "$success" == "true" ]; then
        log_success "$step_name 완료 ✅"
        return 0
    else
        log_error "$step_name 실패 ❌ (최대 재시도 횟수 초과)"
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "💡 다음 단계로 건너뛰시겠습니까?"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        read -p "(y: 건너뛰기 / n: 중단) " skip_step
        
        if [ "$skip_step" == "y" ]; then
            log_warning "$step_name 건너뛰기"
            return 0
        else
            log_error "워크플로우 중단"
            return 1
        fi
    fi
}

# 사용법 출력
show_usage() {
    echo "사용법: $0 <요구사항 파일> [모드] [옵션]"
    echo ""
    echo "모드:"
    echo "  --auto        Claude CLI를 자동으로 실행"
    echo "  --interactive 단계별로 확인하며 진행"
    echo "  --manual      프롬프트만 생성 (기본값)"
    echo ""
    echo "옵션:"
    echo "  --commit      각 단계마다 자동 커밋"
    echo "  --branch      기능 브랜치 자동 생성"
    echo "  --push        리모트로 자동 푸시"
    echo "  --pr          --branch --commit --push 통합"
    echo "  --max-retries=N  최대 재시도 횟수 설정 (기본: 3)"
}

# 인자 확인
if [ "$#" -lt 1 ]; then
    show_usage
    exit 1
fi

# 변수 초기화
SPEC_FILE="$1"
MODE="${2:---manual}"
export AUTO_COMMIT="false"
export AUTO_BRANCH="false"
export AUTO_PUSH="false"
export MAX_RETRIES=3  # ✅ 기본 재시도 횟수
export FEATURE_BRANCH=""
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 옵션 파싱
shift 2 2>/dev/null || shift 1 2>/dev/null || true
while [ $# -gt 0 ]; do
    case "$1" in
        --commit) AUTO_COMMIT="true" ;;
        --branch) AUTO_BRANCH="true" ;;
        --push) AUTO_PUSH="true" ;;
        --pr)
            AUTO_COMMIT="true"
            AUTO_BRANCH="true"
            AUTO_PUSH="true"
            ;;
        --max-retries=*)
            MAX_RETRIES="${1#*=}"
            ;;
    esac
    shift
done

# 명세 파일 확인
if [ ! -f "$SPEC_FILE" ]; then
    log_error "명세 파일을 찾을 수 없습니다: $SPEC_FILE"
    exit 1
fi

FEATURE_NAME=$(basename "$SPEC_FILE" .md)

log "TDD 워크플로우 시작: $SPEC_FILE"
log "모드: $MODE"
log "자동 커밋: $AUTO_COMMIT"
log "자동 브랜치: $AUTO_BRANCH"
log "최대 재시도: $MAX_RETRIES"
echo ""

# 브랜치 생성
if [ "$AUTO_BRANCH" == "true" ]; then
    create_feature_branch "$FEATURE_NAME"
fi

# ✅ 각 단계 실행 (재시도 로직 적용)

# Step 1: 명세 검증 (재시도 불필요)
run_step1 "$SPEC_FILE" "$MODE" "$TIMESTAMP"

# Step 2: 테스트 설계 (재시도 불필요)
run_step2 "$SPEC_FILE" "$MODE" "$TIMESTAMP"

# Step 3: RED (재시도 가능)
if ! retry_step "Step 3 (RED)" run_step3 2 "$SPEC_FILE" "$MODE" "$TIMESTAMP" "$FEATURE_NAME"; then
    log_error "Step 3 실패로 워크플로우 중단"
    exit 1
fi

# Step 4: GREEN (재시도 적용 - 중요!) ⭐
if ! retry_step "Step 4 (GREEN)" run_step4 $MAX_RETRIES "$SPEC_FILE" "$MODE" "$TIMESTAMP" "$FEATURE_NAME"; then
    log_error "Step 4 실패로 워크플로우 중단"
    exit 1
fi

# Step 5: REFACTOR (재시도 가능)
if ! retry_step "Step 5 (REFACTOR)" run_step5 2 "$SPEC_FILE" "$MODE" "$TIMESTAMP" "$FEATURE_NAME"; then
    log_warning "Step 5 실패했지만 계속 진행"
fi

# 완료
log_step "워크플로우 완료! 🎉"

if [ "$AUTO_BRANCH" == "true" ]; then
    show_pr_guide
fi

log "생성된 파일:"
echo "  📄 테스트: ${TEST_FILE:-'N/A'}"
echo "  📄 구현: ${IMPL_FILE:-'N/A'}"

echo ""
log "최종 체크리스트:"
echo "  1. ✅ 테스트 작성 완료"
echo "  2. ✅ 구현 완료"
echo "  3. ✅ 리팩토링 완료"
if [ "$AUTO_COMMIT" == "true" ]; then
    echo "  4. ✅ Git 커밋 완료"
fi
if [ "$AUTO_BRANCH" == "true" ]; then
    echo "  5. ⬜ GitHub에서 PR 생성"
else
    echo "  5. ⬜ git add & commit으로 변경사항 저장"
fi