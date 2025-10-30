#!/bin/bash
# Step 5: REFACTOR - 코드 개선

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/extract.sh"
source "$SCRIPT_DIR/../lib/git.sh"

run_step5() {
    local spec_file=$1
    local mode=$2
    local timestamp=$3
    local feature_name=$4
    
    log_step "5단계: REFACTOR - 코드 개선"
    
    local prompt_file="agents/logs/step5_refactor.prompt"
    local result_file="agents/results/step5_refactor_$timestamp.md"
    local step4_result=$(ls -t agents/results/step4_green_*.md 2>/dev/null | head -1)
    
    # ✅ 강력한 프롬프트 생성
    cat > "$prompt_file" << 'PROMPT'
# SYSTEM INSTRUCTION

You are a CODE REFACTORING AI. You MUST output complete, refactored TypeScript code immediately.

## 🚨 ABSOLUTE RULES

**FORBIDDEN RESPONSES:**
- ❌ "개선된 전체 코드가 추가되었습니다"
- ❌ "리팩토링이 완료되었습니다"
- ❌ "다음과 같이 개선했습니다:" without showing code
- ❌ Any explanation without actual code
- ❌ "I refactored..." without showing code

**MANDATORY:**
- ✅ START with: ```typescript
- ✅ SHOW complete refactored code
- ✅ Include // filepath: comment
- ✅ Write ALL functions (no ...)
- ✅ Code must be copy-paste ready

---

## Example of FORBIDDEN Response (❌):

"리팩토링이 완료되었습니다.

**개선 사항:**
1. 중복 제거
2. 함수 분리
3. 타입 개선

**2단계: 개선된 전체 코드**

개선된 코드는 다음과 같습니다..."

**This is WRONG! You MUST show the actual refactored code!**

---

## Example of CORRECT Response (✅):

**개선 포인트:**
- 중복 제거 (DRY)
- 상수 추출
- 헬퍼 함수 분리

**개선된 전체 코드:**

```typescript
// filepath: src/utils/[YOUR-ACTUAL-FILENAME].ts

// Import statements (if needed)
import { SomeType } from './types';

/**
 * Type definitions
 */
export interface YourResultType {
  // Define your interface
}

/**
 * Constants (extract magic numbers/strings)
 */
const YOUR_CONSTANTS = {
  KEY_1: 'value1',
  KEY_2: 100
} as const;

/**
 * Main exported function with JSDoc
 * 
 * @param param1 - Description
 * @param param2 - Description
 * @returns Description
 */
export function yourMainFunction(
  param1: Type1,
  param2: Type2
): ReturnType {
  // Implement using helper functions
  // Apply refactoring principles:
  // - DRY (Don't Repeat Yourself)
  // - Single Responsibility
  // - Clear naming
  
  const result = helperFunction1(param1);
  
  if (!result) {
    return createError('Error message');
  }
  
  return processResult(result, param2);
}

/**
 * Helper function 1
 */
function helperFunction1(param: Type): ResultType | null {
  // Complete implementation
}

/**
 * Helper function 2
 */
function helperFunction2(param: Type): ResultType {
  // Complete implementation
}

/**
 * Error factory
 */
function createError(message: string): ErrorType {
  return { success: false, error: message };
}
```

**REMEMBER:**
- Replace `[YOUR-ACTUAL-FILENAME]` with actual file path from spec
- Replace `yourMainFunction` with actual function name
- Replace `YourResultType` with actual types
- Write COMPLETE implementation (no `...` placeholders)

---

PROMPT

    echo "" >> "$prompt_file"
    echo "## 원본 명세" >> "$prompt_file"
    echo "" >> "$prompt_file"
    cat "$spec_file" >> "$prompt_file"
    echo "" >> "$prompt_file"
    echo "## 현재 GREEN 단계 구현 코드" >> "$prompt_file"
    echo "" >> "$prompt_file"
    
    if [ -f "$IMPL_FILE" ]; then
        echo '```typescript' >> "$prompt_file"
        cat "$IMPL_FILE" >> "$prompt_file"
        echo '```' >> "$prompt_file"
    elif [ -f "$step4_result" ]; then
        cat "$step4_result" >> "$prompt_file"
    else
        echo "구현 코드를 찾을 수 없습니다." >> "$prompt_file"
    fi
    
    cat >> "$prompt_file" << 'PROMPT'

---

## YOUR TASK: Refactor the Code Above

### Refactoring Checklist:
- [ ] Remove duplication (DRY principle)
- [ ] Extract magic numbers/strings to constants
- [ ] Split large functions (Single Responsibility Principle)
- [ ] Improve naming (clear, descriptive names)
- [ ] Add/improve TypeScript types
- [ ] Add JSDoc comments to public APIs
- [ ] Reduce complexity (cyclomatic complexity)
- [ ] Improve error messages

### Critical Requirements:
1. **Keep the same functionality** - All existing tests MUST pass
2. **Use EXACT file path** from current implementation
3. **Keep same exports** (function names, interface names)
4. **Write COMPLETE code** - No `...` or `// existing code` placeholders
5. **Ready to run** - Copy & paste should work immediately

**BEGIN NOW. Output format:**

## ✅ REQUIRED

You MUST respond with:
- Actual refactored TypeScript code
- Starting with ```typescript
- Complete implementation
- All functions fully written
- Ready to use immediately

**BEGIN NOW. WRITE THE COMPLETE REFACTORED CODE:**

PROMPT
    
    if [ "$mode" == "--auto" ]; then
        run_claude "$prompt_file" "$result_file" "REFACTOR 단계"
        
        # ✅ 코드 블록 검증
        log "생성된 응답 검증 중..."
        
        if ! grep -q '```typescript' "$result_file"; then
            log_error "❌ TypeScript 코드 블록이 없습니다!"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Claude의 응답:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            cat "$result_file"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            log_error "Claude가 리팩토링 코드를 생성하지 않았습니다."
            return 1
        fi
        
        log_success "✅ TypeScript 코드 블록 발견"
        
        # 코드 블록 내용 확인
        local code_content=$(awk '/```typescript/,/```/' "$result_file" | sed '/```/d')
        
        # if [ -z "$code_content" ]; then
        #     log_error "❌ 코드 블록이 비어있습니다!"
        #     return 1
        # fi
        
        # placeholder 확인
        if echo "$code_content" | grep -q "\.\.\."; then
            log_warning "⚠️  코드에 '...' placeholder가 있습니다"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "문제가 있는 부분:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "$code_content" | grep -B 2 -A 2 "\.\.\."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            log_warning "불완전한 구현일 수 있습니다. 파일 생성을 시도합니다..."
        fi
        
        log_step "리팩토링된 코드 적용"
        
        set +e
        REFACTORED_FILE=$(extract_and_create_file "$result_file" "$IMPL_FILE")
        EXTRACT_STATUS=$?
        set -e
        
        if [ $EXTRACT_STATUS -eq 0 ] && [ -n "$REFACTORED_FILE" ] && [ -f "$REFACTORED_FILE" ]; then
            log_success "리팩토링 완료: $REFACTORED_FILE"
            
            echo ""
            log "최종 테스트 실행 중..."
            echo ""
            
            # ✅ CI 모드로 실행 (watch 모드 비활성화)
            set +e
            
            # vitest run 직접 실행
            npx vitest run > /tmp/test_output.log 2>&1
            TEST_STATUS=$?
            
            set -e
            
            # 결과 출력
            cat /tmp/test_output.log
            
            # ✅ 다중 검증
            local test_failed=false
            
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🔍 테스트 결과 분석:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            # Exit code 확인
            echo "Exit Code: $TEST_STATUS"
            if [ $TEST_STATUS -ne 0 ]; then
                echo "  → 실패 (exit code)"
                test_failed=true
            fi
            
            # 출력 패턴 확인
            if grep -qE "Test Files.*[1-9][0-9]* failed" /tmp/test_output.log; then
                echo "  → 테스트 파일 실패 감지"
                test_failed=true
            fi
            
            if grep -qE "Tests.*[1-9][0-9]* failed" /tmp/test_output.log; then
                echo "  → 테스트 케이스 실패 감지"
                grep -E "Tests.*failed" /tmp/test_output.log
                test_failed=true
            fi
            
            if grep -q "FAIL" /tmp/test_output.log; then
                echo "  → FAIL 키워드 감지"
                test_failed=true
            fi
            
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            
            # ✅ 결과 요약 출력
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "테스트 결과 요약:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            grep -E "Test Files|Tests|Duration" /tmp/test_output.log | tail -5 || echo "요약 없음"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            
            if [ "$test_failed" = false ]; then
                log_success "✅ 모든 테스트 통과! 리팩토링 성공"
                
                if [ -f "$REFACTORED_FILE" ]; then
                    auto_commit "REFACTOR" "$REFACTORED_FILE" "$feature_name"
                fi
                
                return 0
            else
                log_error "❌ 테스트 실패. 리팩토링에 문제가 있습니다."
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "실패한 테스트:"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                grep -A 5 "FAIL\|Error" /tmp/test_output.log | head -30
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                
                log_warning "리팩토링을 롤백하는 것을 권장합니다."
                
                if [ "$mode" == "--interactive" ] || [ "$AUTO_COMMIT" != "true" ]; then
                    read -p "롤백하시겠습니까? (y/n): " do_rollback
                    if [ "$do_rollback" == "y" ]; then
                        git checkout "$REFACTORED_FILE"
                        log_success "롤백 완료"
                    fi
                else
                    log_warning "자동 모드에서는 롤백하지 않습니다. 수동으로 확인하세요."
                    echo "롤백 명령: git checkout $REFACTORED_FILE"
                fi
                
                return 1
            fi
        else
            log_warning "파일 자동 생성 실패. 수동 작업이 필요합니다."
            # show_manual_extract_guide "$result_file" "$feature_name" "impl"
            return 1
        fi
        
    elif [ "$mode" == "--interactive" ]; then
        read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            run_claude "$prompt_file" "$result_file" "REFACTOR 단계"
        fi
        
        echo ""
        read -p "생성된 코드를 확인하시겠습니까? (y/n): " view_code
        if [ "$view_code" == "y" ]; then
            cat "$result_file"
        fi
        
        echo ""
        read -p "리팩토링을 적용하시겠습니까? (y/n): " apply_refactor
        if [ "$apply_refactor" == "y" ]; then
            REFACTORED_FILE=$(extract_and_create_file "$result_file" "$IMPL_FILE")
            
            if [ -f "$REFACTORED_FILE" ]; then
                echo ""
                read -p "테스트를 실행하시겠습니까? (y/n): " run_test
                if [ "$run_test" == "y" ]; then
                    set +e
                    pnpm test
                    TEST_STATUS=$?
                    set -e
                    
                    if [ $TEST_STATUS -eq 0 ]; then
                        log_success "✅ 테스트 통과!"
                        return 0
                    else
                        log_error "❌ 테스트 실패"
                        read -p "롤백하시겠습니까? (y/n): " rollback
                        if [ "$rollback" == "y" ]; then
                            git checkout "$REFACTORED_FILE"
                        fi
                        return 1
                    fi
                fi
            fi
        fi
        
        return 0
        
    else
        # manual 모드
        log "프롬프트 생성 완료: $prompt_file"
        echo ""
        echo "💡 다음 단계:"
        echo "  1. cat $prompt_file"
        echo "  2. Claude.ai에 복사"
        echo "  3. 응답을 $result_file 에 저장"
        echo "  4. 파일 추출 및 테스트"
        return 0
    fi
    
    log_success "5단계 완료"
}