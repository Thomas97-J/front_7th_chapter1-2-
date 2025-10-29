#!/bin/bash
# TDD 워크플로우 오케스트레이터
# 전체 TDD 사이클을 자동으로 실행합니다.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $SCRIPT_DIR
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

# 변수 초기화
SPEC_FILE="$1"
MODE="${2:---manual}"
export AUTO_COMMIT="false"
export AUTO_BRANCH="false"
export AUTO_PUSH="false"
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
        --no-commit) AUTO_COMMIT="false" ;;
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
log "자동 푸시: $AUTO_PUSH"
echo ""

# 브랜치 생성
if [ "$AUTO_BRANCH" == "true" ]; then
    create_feature_branch "$FEATURE_NAME"
    
    if [ $? -ne 0 ]; then
        log_error "브랜치 생성 실패. 워크플로우를 종료합니다."
        exit 1
    fi
fi

# 각 단계 실행
run_step1 "$SPEC_FILE" "$MODE" "$TIMESTAMP"
run_step2 "$SPEC_FILE" "$MODE" "$TIMESTAMP"
run_step3 "$SPEC_FILE" "$MODE" "$TIMESTAMP" "$FEATURE_NAME"
run_step4 "$SPEC_FILE" "$MODE" "$TIMESTAMP" "$FEATURE_NAME"
run_step5 "$SPEC_FILE" "$MODE" "$TIMESTAMP" "$FEATURE_NAME"

# 완료
log_step "워크플로우 완료! 🎉"
log_success "모든 단계가 완료되었습니다"
echo ""

# PR 생성 가이드 출력
if [ "$AUTO_BRANCH" == "true" ]; then
    show_pr_guide
fi

log "생성된 파일:"
echo "  📁 프롬프트: agents/logs/"
echo "  📁 결과: agents/results/"
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
