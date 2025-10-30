#!/bin/bash
# Step 1: 명세 검증

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

run_step1() {
    local spec_file=$1
    local mode=$2
    local timestamp=$3
    
    log_step "1단계: 명세 검증"
    
    local prompt_file="agents/logs/step1_spec_validation.prompt"
    local result_file="agents/results/step1_validation_$timestamp.md"
    
    cat > "$prompt_file" << PROMPT
당신은 요구사항 명세를 검증하는 전문가입니다.

다음 명세를 검토하고 검증해주세요:

$(cat "$spec_file")

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
    
    if [ "$mode" == "--auto" ]; then
        run_claude "$prompt_file" "$result_file" "명세 검증"
    elif [ "$mode" == "--interactive" ]; then
        log "프롬프트 생성 완료"
        read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            run_claude "$prompt_file" "$result_file" "명세 검증"
        else
            log "프롬프트 파일: $prompt_file"
        fi
    else
        log "프롬프트 생성: $prompt_file"
    fi
    
    log_success "1단계 완료"
}
