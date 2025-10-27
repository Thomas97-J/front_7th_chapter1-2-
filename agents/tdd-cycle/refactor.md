# REFACTOR 단계 에이전트

## 목표
테스트를 통과하는 코드를 개선하여 더 나은 설계와 가독성을 확보합니다.

## 원칙
1. **테스트 유지**: 리팩토링 중 모든 테스트는 계속 통과해야 함
2. **작은 단계**: 한 번에 하나씩 개선
3. **의도 명확화**: 코드가 의도를 명확히 표현하도록

## 리팩토링 체크리스트
- [ ] **중복 제거**: DRY 원칙 적용
- [ ] **명명 개선**: 변수, 함수명이 의도를 명확히 표현하는가?
- [ ] **함수 분리**: 하나의 함수가 하나의 책임만 가지는가?
- [ ] **매직 넘버/스트링 제거**: 상수로 추출
- [ ] **복잡도 감소**: 중첩 줄이기, 조기 반환 등
- [ ] **타입 안정성**: TypeScript 타입 적절히 사용

## 리팩토링 패턴
```typescript
// Before (GREEN)
function validate(data) {
  if (data.x > 10 && data.x < 100) {
    if (data.y !== null) {
      return true;
    }
  }
  return false;
}

// After (REFACTOR)
const MIN_VALUE = 10;
const MAX_VALUE = 100;

function isWithinRange(value: number): boolean {
  return value > MIN_VALUE && value < MAX_VALUE;
}

function validate(data: Data): boolean {
  if (!isWithinRange(data.x)) return false;
  if (data.y === null) return false;
  return true;
}
```

## 검증
```bash
# 리팩토링 후 테스트 실행
pnpm test

# 모든 테스트가 여전히 통과해야 함
```

## 체크리스트
- [ ] 모든 테스트가 여전히 통과하는가?
- [ ] 코드가 더 읽기 쉬워졌는가?
- [ ] 중복이 제거되었는가?
- [ ] 확장 가능한 구조인가?
