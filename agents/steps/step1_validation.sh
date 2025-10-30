#!/bin/bash
# Step 1: 명세 검증 (프로젝트 컨텍스트 포함)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# 프로젝트 구조 분석 함수
analyze_project_structure() {
    local output_file=$1
    
    echo "## 📁 프로젝트 구조 분석" >> "$output_file"
    echo "" >> "$output_file"
    
    # 1. 디렉토리 구조
    echo "### 1. 디렉토리 구조" >> "$output_file"
    echo '```' >> "$output_file"
    tree -L 3 -I 'node_modules|dist|build|.git' . 2>/dev/null || find . -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' | head -30
    echo '```' >> "$output_file"
    echo "" >> "$output_file"
    
    # 2. 패키지 정보
    if [ -f "package.json" ]; then
        echo "### 2. 기술 스택" >> "$output_file"
        echo '```json' >> "$output_file"
        jq '{
          name: .name,
          dependencies: .dependencies,
          devDependencies: .devDependencies
        }' package.json 2>/dev/null || cat package.json
        echo '```' >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # 3. TypeScript 설정
    if [ -f "tsconfig.json" ]; then
        echo "### 3. TypeScript 설정" >> "$output_file"
        echo '```json' >> "$output_file"
        cat tsconfig.json
        echo '```' >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # 4. 기존 타입 정의
    echo "### 4. 기존 타입 정의 (src/types.ts)" >> "$output_file"
    if [ -f "src/types.ts" ]; then
        echo '```typescript' >> "$output_file"
        cat src/types.ts
        echo '```' >> "$output_file"
    else
        echo "타입 정의 파일이 없습니다." >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # 5. 기존 유틸리티 함수들
    echo "### 5. 기존 유틸리티 함수 목록" >> "$output_file"
    if [ -d "src/utils" ]; then
        echo '```' >> "$output_file"
        ls -la src/utils/ 2>/dev/null || echo "유틸리티 디렉토리가 비어있습니다."
        echo '```' >> "$output_file"
        echo "" >> "$output_file"
        
        # 각 유틸리티 파일의 export 함수 목록
        echo "**주요 export 함수들:**" >> "$output_file"
        echo "" >> "$output_file"
        for file in src/utils/*.ts; do
            if [ -f "$file" ]; then
                echo "- **$(basename $file)**:" >> "$output_file"
                grep -E "export (function|const|interface|type)" "$file" 2>/dev/null | sed 's/^/  /' >> "$output_file"
                echo "" >> "$output_file"
            fi
        done
    else
        echo "유틸리티 디렉토리가 없습니다." >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # 6. 메인 컴포넌트 구조
    echo "### 6. 메인 컴포넌트 (App.tsx)" >> "$output_file"
    if [ -f "src/App.tsx" ]; then
        echo "**주요 state 변수:**" >> "$output_file"
        echo '```typescript' >> "$output_file"
        grep "useState\|const \[" src/App.tsx | head -20
        echo '```' >> "$output_file"
        echo "" >> "$output_file"
        
        echo "**주요 컴포넌트 구조:**" >> "$output_file"
        echo '```typescript' >> "$output_file"
        grep -E "function |const.*=.*\(" src/App.tsx | head -10
        echo '```' >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # 7. 테스트 파일 구조
    echo "### 7. 기존 테스트 파일들" >> "$output_file"
    if [ -d "src/__tests__" ]; then
        echo '```' >> "$output_file"
        ls -la src/__tests__/ 2>/dev/null
        echo '```' >> "$output_file"
        echo "" >> "$output_file"
        
        # 테스트 패턴 분석
        echo "**테스트 작성 패턴 (샘플):**" >> "$output_file"
        echo '```typescript' >> "$output_file"
        find src/__tests__ -name "*.test.ts" -o -name "*.test.tsx" | head -1 | xargs head -30 2>/dev/null
        echo '```' >> "$output_file"
    else
        echo "테스트 디렉토리가 없습니다." >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # 8. 프로젝트 규칙/컨벤션
    echo "### 8. 프로젝트 코딩 컨벤션 분석" >> "$output_file"
    echo "" >> "$output_file"
    
    # 네이밍 컨벤션 분석
    echo "**파일 네이밍:**" >> "$output_file"
    if ls src/utils/*.ts >/dev/null 2>&1; then
        echo "- Utils: camelCase ($(ls src/utils/*.ts 2>/dev/null | head -3 | xargs -n1 basename))" >> "$output_file"
    fi
    if ls src/hooks/*.ts >/dev/null 2>&1; then
        echo "- Hooks: use prefix ($(ls src/hooks/*.ts 2>/dev/null | head -3 | xargs -n1 basename))" >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # 함수 스타일 분석
    echo "**함수 선언 스타일:**" >> "$output_file"
    local arrow_count=$(grep -r "export const.*=.*=>" src/utils/ 2>/dev/null | wc -l)
    local function_count=$(grep -r "export function" src/utils/ 2>/dev/null | wc -l)
    echo "- Arrow function exports: $arrow_count" >> "$output_file"
    echo "- Function declarations: $function_count" >> "$output_file"
    echo "" >> "$output_file"
}

# 코딩 가이드라인 로드
load_coding_guidelines() {
    local output_file=$1
    
    echo "## 📋 코딩 표준 가이드라인" >> "$output_file"
    echo "" >> "$output_file"
    
    if [ -f "agents/guidelines/coding-standards.md" ]; then
        cat "agents/guidelines/coding-standards.md" >> "$output_file"
    else
        echo "**기본 가이드라인:**" >> "$output_file"
        echo "" >> "$output_file"
        echo "- TypeScript strict 모드 준수" >> "$output_file"
        echo "- 명시적 타입 선언" >> "$output_file"
        echo "- JSDoc 주석 작성" >> "$output_file"
        echo "- 단일 책임 원칙" >> "$output_file"
        echo "- 테스트 커버리지 100% 목표" >> "$output_file"
    fi
    echo "" >> "$output_file"
    echo "---" >> "$output_file"
    echo "" >> "$output_file"
}

run_step1() {
    local spec_file=$1
    local mode=$2
    local timestamp=$3
    
    log_step "1단계: 명세 검증 (프로젝트 컨텍스트 분석 포함)"
    
    local prompt_file="agents/logs/step1_spec_validation.prompt"
    local result_file="agents/results/step1_validation_$timestamp.md"
    local context_file="agents/logs/project_context_$timestamp.md"
    
    # ✅ 1. 프로젝트 구조 분석
    log "프로젝트 구조 분석 중..."
    analyze_project_structure "$context_file"
    log_success "프로젝트 분석 완료"
    
    # ✅ 2. 프롬프트 생성 (프로젝트 컨텍스트 포함)
    log "명세 검증 프롬프트 생성 중..."
    
    cat > "$prompt_file" << 'PROMPT'
# SYSTEM INSTRUCTION

You are a REQUIREMENTS SPECIFICATION VALIDATOR with full project context awareness.

## Your Task

Validate and improve the given specification based on:
1. **Project Structure** - Understand existing codebase
2. **Coding Standards** - Follow project conventions
3. **Type System** - Integrate with existing types
4. **Testing Patterns** - Match existing test style
5. **Best Practices** - Apply industry standards

---

PROMPT

    # 코딩 가이드라인 추가
    load_coding_guidelines "$prompt_file"
    
    # 프로젝트 컨텍스트 추가
    cat "$context_file" >> "$prompt_file"
    
    # 원본 명세 추가
    cat >> "$prompt_file" << 'PROMPT'

---

## 📄 사용자 제공 명세

PROMPT

    echo '```markdown' >> "$prompt_file"
    cat "$spec_file" >> "$prompt_file"
    echo '```' >> "$prompt_file"
    
    cat >> "$prompt_file" << 'PROMPT'

---

## 🎯 검증 작업

다음 기준으로 **프로젝트 컨텍스트를 고려하여** 명세를 검증하세요:

### 1. 프로젝트 통합성
- [ ] 기존 타입 시스템과 호환되는가? (src/types.ts 확인)
- [ ] 기존 유틸리티 함수와 중복되지 않는가?
- [ ] 프로젝트 디렉토리 구조에 맞는 위치인가?
- [ ] 기존 네이밍 컨벤션을 따르는가?

### 2. 명확성
- [ ] 요구사항이 모호하지 않고 구체적인가?
- [ ] 함수 시그니처가 명확한가?
- [ ] 입력/출력이 명확하게 정의되었는가?

### 3. 완전성
- [ ] 모든 시나리오와 엣지 케이스가 포함되어 있는가?
- [ ] 에러 처리가 정의되어 있는가?
- [ ] 타입 정의가 완전한가?

### 4. 테스트 가능성
- [ ] 검증 가능한 조건이 명시되어 있는가?
- [ ] 기존 테스트 패턴과 일관된가?
- [ ] 모든 분기가 테스트 가능한가?

### 5. 일관성
- [ ] 요구사항 간 충돌이 없는가?
- [ ] 프로젝트의 다른 기능과 일관된가?
- [ ] 코딩 스타일이 프로젝트와 일치하는가?

### 6. 성능 고려사항
- [ ] 성능 요구사항이 있는가?
- [ ] 최적화가 필요한 부분이 있는가?

---

cat >> "$prompt_file" << 'PROMPT'

---

## 📤 출력 형식

### ✅ 검증 결과

#### 1. 프로젝트 통합성
**평가:** [통과 / 개선 필요 / 실패]

**발견 사항:**
- 기존 타입: (관련 타입 나열)
- 중복 가능성: (있다면 명시)
- 권장 파일 위치: `src/utils/xxx.ts` 또는 `src/hooks/useXxx.ts`

**개선 사항:**
- (구체적인 개선 제안)

#### 2. 명확성
**평가:** [통과 / 개선 필요 / 실패]

**발견 사항:**
- (모호한 부분 지적)

**개선 사항:**
- (구체적인 명확화 방안)

#### 3. 완전성
**평가:** [통과 / 개선 필요 / 실패]

**누락된 사항:**
- (누락된 시나리오/엣지 케이스)

**추가할 내용:**
- (구체적인 추가 사항)

#### 4. 테스트 가능성
**평가:** [통과 / 개선 필요 / 실패]

**테스트 전략:**
- (테스트 가능한 조건으로 명세 개선 방안)

#### 5. 일관성
**평가:** [통과 / 개선 필요 / 실패]

**충돌 사항:**
- (발견된 불일치)

#### 6. 성능 고려사항
**평가:** [통과 / 개선 필요 / 해당없음]

**성능 이슈:**
- (잠재적 성능 문제)

---

### 📝 개선된 명세 (요구사항 수준)

```markdown
# [기능 이름]

## 개요
(프로젝트 컨텍스트를 고려한 개선된 설명)

## 위치
**권장 파일 경로:** `src/utils/xxx.ts` 또는 `src/hooks/useXxx.ts`

**선정 이유:**
- 기존 프로젝트 구조와의 일관성
- 관련 기능과의 응집도

## 기능 설명
- **핵심 기능:** (무엇을 하는가)
- **주요 동작:** (어떻게 동작하는가)
- **제약 조건:** (어떤 제한이 있는가)

## 입력 (개념적)
- **파라미터 1:** 설명 (타입 힌트: Date, string, number 등)
  - 필수/선택: 필수
  - 예시: `'2024-01-01'` 또는 `new Date()`
  - 제약: ISO 형식 문자열 또는 Date 객체
  
- **파라미터 2:** 설명 (타입 힌트)
  - 필수/선택: 선택
  - 예시: `undefined` 가능
  - 제약: 특정 조건

## 출력 (개념적)
- **반환 타입:** 설명 (객체, boolean, number 등)
  - 성공 시 포함 정보: 성공 여부, 데이터
  - 실패 시 포함 정보: 실패 여부, 에러 메시지
  
**예시:**
```
성공 케이스:
{ success: true, data: {...} }

실패 케이스:
{ success: false, error: "에러 메시지" }
```

## 관련 타입 (기존 재사용)
- **Event** (src/types.ts) - 이벤트 데이터 구조
- **RepeatType** (src/types.ts) - 반복 타입 정의
- **새 타입 필요 여부:** [예/아니오]
  - 필요한 경우: 간단한 설명 (Step 2에서 구체화)

## 상세 요구사항

### 1. 입력 검증 규칙
1. **파라미터 1 검증:**
   - null/undefined 체크 → 에러: "파라미터1은 필수입니다"
   - 형식 검증 → 에러: "올바른 형식이 아닙니다"
   
2. **파라미터 2 검증:**
   - 범위 확인 → 에러: "범위를 벗어났습니다"

### 2. 비즈니스 로직
1. **조건 A 확인:**
   - 파라미터1 > 파라미터2 → 에러
   
2. **조건 B 처리:**
   - 특정 계산 수행
   - 결과 검증
   
3. **결과 생성:**
   - 성공 객체 반환

### 3. 에러 처리 시나리오
| 상황 | 에러 메시지 | 심각도 |
|------|------------|--------|
| 파라미터 null | "xxx은 필수입니다" | Error |
| 잘못된 형식 | "형식이 올바르지 않습니다" | Error |
| 범위 초과 | "범위를 벗어났습니다" | Warning |

### 4. 엣지 케이스
1. **극단 값:**
   - 최소값: 처리 방법
   - 최대값: 처리 방법
   
2. **경계 조건:**
   - 같은 값 입력 → 경고 또는 정상 처리
   
3. **특수 케이스:**
   - 100년 이상 차이 → 경고 메시지
   - 과거 날짜 → 허용 또는 거부

## 테스트 시나리오 (개념적)

### 정상 케이스
1. **기본 동작:**
   - 입력: 유효한 값
   - 예상 출력: 성공 결과
   
2. **일반적 사용:**
   - 입력: 실제 사용 케이스
   - 예상 출력: 올바른 처리

### 예외 케이스
1. **null/undefined:**
   - 입력: null
   - 예상 출력: 에러 메시지
   
2. **잘못된 형식:**
   - 입력: 유효하지 않은 형식
   - 예상 출력: 형식 에러

### 엣지 케이스
1. **극단 값:**
   - 입력: 최대/최소 값
   - 예상 출력: 경고 또는 정상 처리
   
2. **경계 값:**
   - 입력: 경계선 값
   - 예상 출력: 올바른 처리

## 통합 가이드

### 기존 코드와의 관계
**재사용할 유틸리티:**
- `formatDate()` - 날짜 포맷팅 (src/utils/dateUtils.ts)
- `parseDateTime()` - 날짜 파싱 (src/utils/dateUtils.ts)

**연관된 컴포넌트:**
- `App.tsx` - 날짜 입력 폼 (350-400번째 줄)
- `EventForm` - 이벤트 생성 폼

**영향받는 타입:**
- `Event` - repeat 필드 관련
- `EventForm` - 폼 데이터 구조

### 예상 사용처 (개념적)
```typescript
// App.tsx에서 사용 예시
import { validateDateRange } from './utils/validateDateRange';

// 폼 제출 시
const handleSubmit = () => {
  const result = validateDateRange(startDate, endDate);
  
  if (!result.isValid) {
    // 에러 처리
    showErrorMessage(result.error);
    return;
  }
  
  if (result.warning) {
    // 경고 표시
    showWarningMessage(result.warning);
  }
  
  // 정상 처리
  saveEvent(eventData);
};
```

## 성능 고려사항
- **시간 복잡도:** O(1) - 단순 비교 연산
- **공간 복잡도:** O(1) - 고정 크기 객체 반환
- **최적화 불필요:** 계산량이 적음
- **대용량 데이터:** 해당 없음 (단일 날짜 처리)

## 마이그레이션 가이드
(기존 코드 변경이 필요한 경우)

### 영향받는 파일
- `App.tsx` - 날짜 검증 로직 대체
- `EventForm` - 에러 처리 방식 변경

### 변경 사항
**Before:**
```typescript
// 기존 인라인 검증
if (!startDate || !endDate) {
  alert('날짜를 입력하세요');
}
```

**After:**
```typescript
// 새 유틸리티 사용
const result = validateDateRange(startDate, endDate);
if (!result.isValid) {
  showError(result.error);
}
```

### 호환성
- **하위 호환:** 불가 (기존 검증 로직 대체)
- **점진적 마이그레이션:** 가능 (파일별 순차 적용)
```

---

## 🚨 중요: 구현 세부사항 제외

**Step 1에서는 다음을 포함하지 마세요:**

❌ **제외할 것:**
- 정확한 함수 시그니처 (`function xxx(a: Type): Return`)
- 구체적인 인터페이스 정의 (`interface Result { isValid: boolean }`)
- 변수명, 상수명 (`const ERROR_MESSAGES = {...}`)
- 구현 방법 (`// Date 객체로 변환 후 비교`)
- 헬퍼 함수 구조

✅ **포함할 것:**
- 기능 설명 (무엇을 하는가)
- 입출력 개념 (어떤 종류의 데이터, 예시 포함)
- 검증 규칙 (어떤 조건 확인)
- 에러 시나리오 (언제 실패, 메시지는?)
- 테스트 시나리오 개념 (어떻게 검증할 것인가)
- 프로젝트 통합 정보 (어디 위치, 무엇 재사용)
- 사용 예시 (실제로 어떻게 쓰일지)

**이유:**
- 명세는 **"WHAT"** (무엇을 만들지)
- Step 2 (테스트 설계)는 **"HOW TO VERIFY"** (어떻게 검증할지)
  - 이 단계에서 인터페이스, 함수 시그니처가 자연스럽게 도출됨
- Step 3-4 (구현)는 **"HOW TO IMPLEMENT"** (어떻게 만들지)

**Step 1은 개발자가 읽고 "아, 이걸 만들어야 하는구나"를 이해하는 문서입니다.**
**구체적인 코드 구조는 Step 2의 테스트 설계 과정에서 결정됩니다.**

PROMPT

    # ✅ 3. Claude 실행
    if [ "$mode" == "--auto" ]; then
        log "Claude로 명세 검증 중..."
        run_claude "$prompt_file" "$result_file" "명세 검증 (프로젝트 컨텍스트 포함)"
        
        echo ""
        log_success "검증 결과: $result_file"
        
        # 검증 결과 요약 출력
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📊 검증 결과 요약"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        grep -A 1 "평가:" "$result_file" | head -20
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # 개선된 명세 위치 표시
        if grep -q "## 📝 개선된 명세\|### 📝 개선된 명세" "$result_file"; then
            log_success "✅ 개선된 명세가 생성되었습니다"
            echo ""
            echo "💡 개선된 명세 확인:"
            echo "   cat $result_file"
            echo ""
        fi
        
    elif [ "$mode" == "--interactive" ]; then
        log "프롬프트 생성 완료"
        echo ""
        echo "생성된 파일:"
        echo "  - 프로젝트 분석: $context_file"
        echo "  - 검증 프롬프트: $prompt_file"
        echo ""
        
        read -p "프로젝트 분석 결과를 확인하시겠습니까? (y/n): " view_context
        if [ "$view_context" == "y" ]; then
            less "$context_file"
        fi
        
        echo ""
        read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            run_claude "$prompt_file" "$result_file" "명세 검증"
            
            echo ""
            read -p "검증 결과를 확인하시겠습니까? (y/n): " view_result
            if [ "$view_result" == "y" ]; then
                less "$result_file"
            fi
        else
            log "프롬프트 파일: $prompt_file"
        fi
        
    else
        # manual 모드
        log "파일 생성 완료:"
        echo "  - 프로젝트 분석: $context_file"
        echo "  - 검증 프롬프트: $prompt_file"
        echo ""
        echo "💡 다음 단계:"
        echo "  1. cat $context_file  # 프로젝트 구조 확인"
        echo "  2. cat $prompt_file   # 프롬프트 확인"
        echo "  3. Claude.ai에 프롬프트 입력"
        echo "  4. 응답을 $result_file 에 저장"
    fi
    
    log_success "1단계 완료"
}