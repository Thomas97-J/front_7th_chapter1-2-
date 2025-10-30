#!/bin/bash
# Step 2: 테스트 설계 (Kent Beck TDD 원칙 적용)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

run_step2() {
    local spec_file=$1
    local mode=$2
    local timestamp=$3
    
    log_step "2단계: 테스트 설계 (Kent Beck 방식)"
    
    local prompt_file="agents/logs/step2_test_design.prompt"
    local result_file="agents/results/step2_design_$timestamp.md"
    
    cat > "$prompt_file" << PROMPT

# SYSTEM: 당신은 테스트 설계 전문가이자 Kent Beck의 TDD 철학을 실천하는 소프트웨어 장인입니다.

검증된 명세를 바탕으로, Kent Beck의 테스트 작성 원칙에 따라 테스트 케이스를 설계해주세요:

$(cat "$spec_file")

---

## 🎯 Kent Beck의 테스트 작성 원칙 (요약 문서)

1. **작게 시작하라 (Start Small)**  
   - 가장 단순한 동작부터 검증한다.  
   - 코드를 작성하기 전에 실패하는 테스트를 만든다.

2. **단계적으로 확장하라 (Grow Step by Step)**  
   - 실패하는 테스트를 통과할 만큼만 구현한다.  
   - 리팩토링 전에 항상 테스트가 초록색 상태인지 확인한다.

3. **명확하게 이름 짓기 (Name Clearly)**  
   - 테스트 이름은 동작의 의도를 표현해야 한다.  
   - “should [기대 동작] when [조건]” 패턴을 따른다.

4. **중복을 제거하라 (Eliminate Duplication)**  
   - 테스트와 코드에서 중복을 지속적으로 제거한다.  
   - 명확성과 간결함을 동시에 추구한다.

5. **하나의 이유만으로 실패해야 한다 (Single Responsibility)**  
   - 각 테스트는 한 가지 실패 원인만 가져야 한다.  
   - 복합 동작은 별도 테스트로 분리한다.

6. **예측 가능한 테스트 (Predictable Tests)**  
   - 외부 의존성은 Mock/Stubbing으로 격리한다.  
   - 테스트는 순서에 의존하지 않는다.

7. **읽기 쉬운 테스트 (Readable Tests)**  
   - AAA(Arrange-Act-Assert) 또는 Given-When-Then 구조를 따른다.  
   - 코드보다 “행동 시나리오”로 읽히게 작성한다.

---

## 🧩 테스트 설계 지침

다음 원칙을 반드시 따르세요:
- AAA 패턴 (Arrange → Act → Assert)
- 테스트 독립성 보장
- 명확한 의도 표현
- 경계값 및 예외 케이스 포함

테스트 분류:
- Unit Tests: 개별 함수 또는 로직 단위 검증
- Integration Tests: 모듈 간 상호작용 검증
- Edge Cases: 경계 조건, 예외 상황 검증

각 테스트 케이스는 다음 형식을 따릅니다:
- **이름**: should [expected behavior] when [condition]
- **Given**: 사전 조건
- **When**: 실행 조건
- **Then**: 기대 결과
- **우선순위**: high / medium / low

---

## 🧠 품질 기준
- 각 테스트는 단일 동작만 검증해야 함 (Single Assertion Principle)
- Mocking/Stubbing의 필요성을 명시
- 상태 변화가 있다면 Before/After 명시
- 외부 데이터 의존성 제거 (API, localStorage, DB 등)
- 테스트는 명세의 의도를 드러내야 하며, 구현 세부사항에 의존하지 않아야 함

---

## 🧪 프로젝트 컨텍스트
- 테스트 프레임워크: **Vitest**
- 테스트 파일 위치: `src/__tests__/`
- React 컴포넌트 테스트: **@testing-library/react**

---

## 🧾 출력 형식 예시

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
    
    if [ "$mode" == "--auto" ]; then
        run_claude "$prompt_file" "$result_file" "테스트 설계 (Kent Beck 원칙)"
    elif [ "$mode" == "--interactive" ]; then
        read -p "Claude CLI로 실행하시겠습니까? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            run_claude "$prompt_file" "$result_file" "테스트 설계 (Kent Beck 원칙)"
        fi
    else
        log "프롬프트 생성: $prompt_file"
    fi
    
    log_success "2단계 완료 (Kent Beck 스타일 테스트 설계)"
}