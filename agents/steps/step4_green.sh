#!/bin/bash
# Step 4: GREEN - 테스트 통과 구현

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/extract.sh"
source "$SCRIPT_DIR/../lib/git.sh"

run_step4() {
    local spec_file=$1
    local mode=$2
    local timestamp=$3
    local feature_name=$4
    
    log_step "4단계: GREEN - 테스트 통과 구현"
    
    local prompt_file="agents/logs/step4_green.prompt"
    local result_file="agents/results/step4_green_$timestamp.md"
    local step3_result=$(ls -t agents/results/step3_red_*.md 2>/dev/null | head -1)
    
    # ✅ 강력한 프롬프트 생성
    cat > "$prompt_file" << 'PROMPT'
# SYSTEM INSTRUCTION

You are a CODE GENERATOR. You MUST output code immediately.

## 🚨 ABSOLUTE RULES

**FORBIDDEN RESPONSES:**
- ❌ "`src/utils/validateDateRange.ts` 파일에 다음 기능들을 구현했습니다"
- ❌ "구현 코드 작성이 완료되었습니다"
- ❌ "테스트를 실행하여..."
- ❌ "파일 작성 권한 승인 후..."
- ❌ Any explanation without code
- ❌ "I implemented..." without showing code

**MANDATORY:**
- ✅ START with: ```typescript
- ✅ SHOW complete implementation code
- ✅ Include // filepath: comment
- ✅ Write ALL functions (no ...)
- ✅ Code must be ready to copy & paste

---

## Example of FORBIDDEN Response (❌):

"구현 코드 작성이 완료되었습니다.
`src/utils/yourFunction.ts` 파일에 다음 기능들을 구현했습니다:
1. 입력 검증
2. 데이터 처리..."

**This is WRONG! You MUST show the actual code!**

---

## Example of CORRECT Response (✅):

```typescript
// filepath: src/utils/[your-actual-function-name].ts

// Import statements if needed
import { SomeType } from './types';

/**
 * Interface definitions
 */
export interface YourResultType {
  success: boolean;
  data?: YourDataType;
  error?: string;
}

/**
 * Main function implementation
 * 
 * @param param1 - Description
 * @param param2 - Description
 * @returns Result object
 */
export function yourMainFunction(
  param1: Type1 | null | undefined,
  param2: Type2 | null | undefined
): YourResultType {
  // Input validation
  if (!param1) {
    return {
      success: false,
      error: '파라미터1은 필수입니다'
    };
  }
  
  if (!param2) {
    return {
      success: false,
      error: '파라미터2는 필수입니다'
    };
  }
  
  // Main logic
  const result = processInput(param1, param2);
  
  if (!isValid(result)) {
    return {
      success: false,
      error: '처리 결과가 유효하지 않습니다'
    };
  }
  
  return {
    success: true,
    data: result
  };
}

/**
 * Helper functions
 */
function processInput(p1: Type1, p2: Type2): ProcessedType {
  // Complete implementation
  return processed;
}

function isValid(data: ProcessedType): boolean {
  // Complete implementation
  return true;
}
```

**REMEMBER:**
- Replace `[your-actual-function-name]` with the actual function name from the spec
- Replace `YourResultType`, `YourDataType` with actual types
- Replace `yourMainFunction` with actual function name from tests
- Write COMPLETE implementation (no `...` or comments like "// implement logic here")

---

PROMPT

    cat >> "$prompt_file" << PROMPT

## Original Specification

$(cat "$spec_file")

## Test Code (RED Step)

PROMPT

    if [ -f "$step3_result" ]; then
        # 테스트 코드만 추출 (설명 제외)
        awk '/```typescript/,/```/' "$step3_result" | sed '/```/d' >> "$prompt_file"
    fi
    
    cat >> "$prompt_file" << 'PROMPT'

---

## YOUR TASK

Write TypeScript implementation that passes ALL tests above.

### Requirements Analysis (from tests):

Look at the test file above and identify:
1. **Function name** - What is the main function being tested?
2. **Interface/Type name** - What types are expected?
3. **Parameters** - What inputs does the function take?
4. **Return type** - What should the function return?
5. **Edge cases** - What special cases are tested?

### Implementation Checklist:
- [ ] Export all required interfaces/types (found in tests)
- [ ] Export main function with correct signature
- [ ] Handle all edge cases from tests
- [ ] Complete implementation (NO placeholders like `...` or `// TODO`)
- [ ] Include helper functions if needed
- [ ] Add JSDoc comments for public APIs

### Output Format:

**YOU MUST START YOUR RESPONSE WITH CODE BLOCK:**

```typescript
// filepath: src/utils/[EXTRACT-FILENAME-FROM-SPEC-OR-TEST].ts

/**
 * Type definitions (extract from test expectations)
 */
export interface YourResultInterface {
  // Define based on test expectations
}

/**
 * Main function (extract name and signature from tests)
 * 
 * @param param1 - Description from spec
 * @param param2 - Description from spec
 * @returns Description from spec
 */
export function yourFunctionName(
  param1: ParamType1,
  param2: ParamType2
): ReturnType {
  // WRITE COMPLETE IMPLEMENTATION
  // Handle all test cases:
  
  // 1. Null/undefined checks (if tests check these)
  
  // 2. Type validation (if tests check invalid types)
  
  // 3. Business logic (core functionality)
  
  // 4. Edge cases (100-year warning, etc. from tests)
  
  return result;
}

// Helper functions if complexity requires separation
function helperFunction1(...): ReturnType {
  // COMPLETE IMPLEMENTATION
}

function helperFunction2(...): ReturnType {
  // COMPLETE IMPLEMENTATION
}
```

---

## 🚨 CRITICAL REQUIREMENTS

1. **Extract information from tests above** - Don't assume function names
2. **Use EXACT names from tests** - Function names, interface names, property names
3. **Include filepath comment** - Match the file structure from spec
4. **Write COMPLETE code** - No `...` or `// implement here` placeholders
5. **Ready to run** - Code must be copy-paste ready

## 🚫 ABSOLUTELY FORBIDDEN

DO NOT respond with:
- "구현했습니다" without showing code
- "`src/utils/...` 파일에..." without actual code block
- Only explanations or descriptions
- Code with placeholders (`...`, `// TODO`, `// implement logic`)

## ✅ YOU MUST RESPOND WITH

- Actual TypeScript code
- Starting with ```typescript
- Complete implementation
- All functions fully written
- Ready to use immediately

**ANALYZE THE TEST CODE ABOVE, THEN WRITE THE COMPLETE IMPLEMENTATION:**


PROMPT
    
    if [ "$mode" == "--auto" ]; then
        run_claude "$prompt_file" "$result_file" "GREEN 단계"
        
        # ✅ 코드 블록 검증 강화
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
            log_error "Claude가 코드를 생성하지 않았습니다."
            
            # 재시도를 orchestrator에게 위임 (return 1)
            return 1
        fi
        
        # 코드 블록 내용 확인 (실제 구현이 있는지)
        local code_content=$(awk '/```typescript/,/```/' "$result_file" | sed '/```/d')
        
        local validation_failed=false
        
        if ! echo "$code_content" | grep -q "export function validateDateRange\|export const validateDateRange"; then
            log_warning "⚠️  validateDateRange 함수를 찾을 수 없습니다"
            validation_failed=true
        else
            log_success "✅ validateDateRange 함수 발견"
        fi
        
        if ! echo "$code_content" | grep -q "export interface ValidationResult\|export type ValidationResult"; then
            log_warning "⚠️  ValidationResult 타입을 찾을 수 없습니다"
            validation_failed=true
        else
            log_success "✅ ValidationResult 타입 발견"
        fi
        
        if echo "$code_content" | grep -q "\.\.\..*existing code\|\.\.\..*COMPLETE"; then
            log_warning "⚠️  코드에 placeholder가 있을 수 있습니다"
            validation_failed=true
        fi
        
        log_success "✅ 코드 블록 검증 완료"
        
        # 파일 생성
        log_step "구현 파일 자동 생성"
        
        set +e
        IMPL_FILE=$(extract_and_create_file "$result_file" "src/utils/${feature_name}.ts")
        EXTRACT_STATUS=$?
        set -e
        
        if [ $EXTRACT_STATUS -eq 0 ] && [ -n "$IMPL_FILE" ] && [ -f "$IMPL_FILE" ]; then
            log_success "구현 파일 생성 완료: $IMPL_FILE"
            
            echo ""
            log "테스트 실행 중..."
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
                log_success "✅ 모든 테스트 통과!"
                
                if [ -f "$IMPL_FILE" ]; then
                    auto_commit "GREEN" "$IMPL_FILE" "$feature_name"
                fi
                
                export IMPL_FILE
                return 0
            else
                log_error "❌ 테스트 실패 (Exit: $TEST_STATUS)"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "실패한 테스트 상세:"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                grep -B 2 -A 10 "FAIL" /tmp/test_output.log | head -50
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                
                # orchestrator가 재시도하도록 실패 반환
                log_warning "orchestrator가 GREEN 단계를 재시도합니다..."
                return 1
            fi
        else
            log_warning "⚠️  파일 자동 생성 실패"
            
            # ✅ 수동 작업 기회 제공
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "💡 수동 파일 생성 가이드"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "예상 파일 경로: src/utils/${feature_name}.ts"
            echo ""
            echo "옵션 1: 결과에서 직접 추출"
            echo "  cat $result_file"
            echo ""
            echo "옵션 2: 자동 추출 명령어"
            echo "  awk '/\`\`\`typescript/,/\`\`\`/' $result_file | sed '/\`\`\`/d' | grep -v '^// filepath:' > src/utils/${feature_name}.ts"
            echo ""
            echo "옵션 3: 직접 작성"
            echo "  vi src/utils/${feature_name}.ts"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            
            # ✅ 사용자 대기
            read -p "파일을 생성한 후 Enter를 눌러 계속하세요 (skip: 재시도 / q: 중단)... " user_input
            
            if [ "$user_input" == "q" ]; then
                log_warning "사용자가 중단했습니다"
                return 1
            fi
            
            if [ "$user_input" == "skip" ]; then
                log_warning "orchestrator가 GREEN 단계를 재시도합니다..."
                return 1
            fi
            
            # ✅ 파일 존재 확인
            IMPL_FILE="src/utils/${feature_name}.ts"
            
            if [ ! -f "$IMPL_FILE" ]; then
                log_error "❌ 파일이 여전히 존재하지 않습니다: $IMPL_FILE"
                echo ""
                read -p "다시 시도하시겠습니까? (y/n): " retry_step
                
                if [ "$retry_step" == "y" ]; then
                    log_warning "orchestrator가 GREEN 단계를 재시도합니다..."
                    return 1
                else
                    log_warning "파일 없이 계속 진행합니다"
                    export IMPL_FILE
                    return 0
                fi
            fi
            
            log_success "✅ 파일 확인됨: $IMPL_FILE"
            
            # ✅ 수동 생성된 파일도 테스트 실행
            echo ""
            log "테스트 실행 중..."
            echo ""
            
            set +e
            npx vitest run > /tmp/test_output.log 2>&1
            TEST_STATUS=$?
            set -e
            
            cat /tmp/test_output.log
            
            # 다중 검증
            local manual_test_failed=false
            
            if [ $TEST_STATUS -ne 0 ]; then
                manual_test_failed=true
            fi
            
            if grep -qE "Test Files.*[1-9][0-9]* failed|Tests.*[1-9][0-9]* failed|FAIL" /tmp/test_output.log; then
                manual_test_failed=true
            fi
            
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "테스트 결과 요약:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            grep -E "Test Files|Tests|Duration" /tmp/test_output.log | tail -5 || echo "요약 없음"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            
            if [ "$manual_test_failed" = false ]; then
                log_success "✅ 모든 테스트 통과!"
                auto_commit "GREEN" "$IMPL_FILE" "$feature_name"
                export IMPL_FILE
                return 0
            else
                log_error "❌ 테스트 실패"
                echo ""
                read -p "다시 시도하시겠습니까? (y: 재시도 / n: 계속 진행): " retry_or_skip
                
                if [ "$retry_or_skip" == "y" ]; then
                    log_warning "orchestrator가 GREEN 단계를 재시도합니다..."
                    return 1
                else
                    log_warning "테스트 실패를 무시하고 계속 진행합니다"
                    export IMPL_FILE
                    return 0
                fi
            fi
        fi
    elif [ "$mode" == "--interactive" ]; then
        read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            run_claude "$prompt_file" "$result_file" "GREEN 단계"
        fi
        
        echo ""
        read -p "생성된 코드를 확인하시겠습니까? (y/n): " view_code
        if [ "$view_code" == "y" ]; then
            cat "$result_file"
        fi
        
        echo ""
        read -p "파일을 자동으로 생성하시겠습니까? (y/n): " create_file
        if [ "$create_file" == "y" ]; then
            IMPL_FILE=$(extract_and_create_file "$result_file" "src/utils/${feature_name}.ts")
            
            if [ -f "$IMPL_FILE" ]; then
                echo ""
                read -p "테스트를 실행하시겠습니까? (y/n): " run_test
                if [ "$run_test" == "y" ]; then
                    set +e
                    npx vitest run
                    TEST_STATUS=$?
                    set -e
                    
                    if [ $TEST_STATUS -eq 0 ]; then
                        return 0
                    else
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
        echo "  4. 파일 추출 실행"
        return 0
    fi
}