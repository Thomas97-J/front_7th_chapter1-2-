#!/bin/bash
# Step 3: RED - 실패하는 테스트 작성

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/extract.sh"
source "$SCRIPT_DIR/../lib/git.sh"

run_step3() {
    local spec_file=$1
    local mode=$2
    local timestamp=$3
    local feature_name=$4
    
    log_step "3단계: RED - 실패하는 테스트 작성"
    
    local prompt_file="agents/logs/step3_red.prompt"
    local result_file="agents/results/step3_red_$timestamp.md"
    local step2_result=$(ls -t agents/results/step2_design_*.md 2>/dev/null | head -1)
    
    cat > "$prompt_file" << 'PROMPT'
# SYSTEM: 당신은 테스트 코드 생성 전문 AI입니다. 항상 즉시 테스트 코드를 작성합니다.

## 🚨 CRITICAL INSTRUCTION

**YOU MUST WRITE CODE IMMEDIATELY. NO PERMISSION REQUESTS. NO EXPLANATIONS.**

당신의 역할:
- ✅ 즉시 테스트 코드 작성
- ❌ 구현 코드 작성 금지
- ❌ 권한 요청 금지
- ❌ 확인 질문 금지
- ❌ 설명만 제공 금지
PROMPT

    # 명세와 테스트 설계 추가
    echo "" >> "$prompt_file"
    echo "## 원본 명세" >> "$prompt_file"
    echo "" >> "$prompt_file"
    cat "$spec_file" >> "$prompt_file"
    echo "" >> "$prompt_file"
    echo "## 테스트 설계" >> "$prompt_file"
    echo "" >> "$prompt_file"
    if [ -f "$step2_result" ]; then
        cat "$step2_result" >> "$prompt_file"
    else
        echo "없음" >> "$prompt_file"
    fi
    
    cat >> "$prompt_file" << 'PROMPT'

---

## TASK: Write Vitest Test Code

### Requirements:
- Vitest framework
- TypeScript
- AAA pattern
- 15+ test cases
- All edge cases
- Ready to run

### Output Format:

**START YOUR RESPONSE WITH CODE BLOCK. NO TEXT BEFORE CODE.**

```typescript
// filepath: src/__tests__/unit/[name].spec.ts

import { describe, it, expect } from 'vitest';
import { functionName } from '../../utils/fileName';

describe('Feature Name', () => {
  describe('Normal Cases', () => {
    it('should work with valid input', () => {
      // Arrange
      const input = 'test';
      
      // Act
      const result = functionName(input);
      
      // Assert
      expect(result.isValid).toBe(true);
    });
  });

  describe('Error Cases', () => {
    it('should handle null', () => {
      // Arrange
      const input = null;
      
      // Act
      const result = functionName(input);
      
      // Assert
      expect(result.isValid).toBe(false);
    });
  });
});
```

### FORBIDDEN:
- ❌ "I need permission to..."
- ❌ "Please approve..."
- ❌ "..." or "existing code"

### MANDATORY:
- ✅ Start with ```typescript
- ✅ Include // filepath: comment
- ✅ Write complete code
- ✅ 15+ test cases

## 🚀 BEGIN NOW
PROMPT
    
    if [ "$mode" == "--auto" ]; then
        run_claude "$prompt_file" "$result_file" "RED 단계"
        
        log_step "테스트 파일 자동 생성"
        
        set +e
        TEST_FILE=$(extract_and_create_file "$result_file" "src/__tests__/unit/${feature_name}.spec.ts")
        EXTRACT_STATUS=$?
        set -e
        
        if [ $EXTRACT_STATUS -eq 0 ] && [ -n "$TEST_FILE" ] && [ -f "$TEST_FILE" ]; then
            log_success "테스트 파일 생성 완료: $TEST_FILE"
            
            echo ""
            log "테스트 실행 중..."
            
            set +e
            pnpm test -- --run "$TEST_FILE" 2>&1 | tee /tmp/test_output.log
            TEST_STATUS=$?
            set -e
            
            # 검증 추가
            if grep -qE "failed.*Test|FAIL" /tmp/test_output.log; then
                TEST_STATUS=1
            fi
            
            if [ $TEST_STATUS -ne 0 ]; then
                log_warning "테스트 실패 (예상된 동작 - RED 단계)"
            fi
            echo ""
            
            if [ -f "$TEST_FILE" ]; then
                auto_commit "RED" "$TEST_FILE" "$feature_name"
            fi
        else
            log_warning "파일 자동 생성 실패. 수동 작업이 필요합니다."
            show_manual_extraction_guide "$result_file" "src/__tests__/unit/${feature_name}.spec.ts" "테스트"
            
            read -p "테스트 파일 생성 완료 후 Enter를 누르세요... " 
            
            TEST_FILE="src/__tests__/unit/${feature_name}.spec.ts"
            
            if [ -f "$TEST_FILE" ]; then
                log_success "테스트 파일 확인됨: $TEST_FILE"
                
                set +e
                pnpm test "$TEST_FILE"
                set -e
                
                if [ "$AUTO_COMMIT" == "true" ]; then
                    auto_commit "RED" "$TEST_FILE" "$feature_name"
                fi
            fi
        fi
        
        read -p "다음 단계로 진행하려면 Enter를 누르세요... " 
    fi
    
    log_success "3단계 완료"
    
    # TEST_FILE을 export하여 다음 단계에서 사용
    export TEST_FILE
}
