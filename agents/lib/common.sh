#!/bin/bash
# 공통 함수 라이브러리
# agents 디렉토리 루트 찾기
if [ -z "$AGENTS_ROOT" ]; then
    CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export AGENTS_ROOT="$(cd "$CURRENT_DIR/.." && pwd)"
fi

# 색상 정의
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m'

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
        read -p "완료 후 Enter를 누르세요... " 
        return 1
    fi
    
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
