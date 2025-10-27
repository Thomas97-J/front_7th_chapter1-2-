# RED 단계 에이전트

## 목표
설계된 테스트 케이스를 실제 테스트 코드로 작성하여 실패하는 테스트를 만듭니다.

## 원칙
1. **실패하는 테스트 먼저**: 구현 전 테스트 작성
2. **명확한 실패**: 왜 실패하는지 명확해야 함
3. **하나씩**: 한 번에 하나의 테스트만 추가

## 작성 가이드
- 테스트 프레임워크: Vitest
- 테스트 라이브러리: @testing-library/react
- 파일 위치: src/__tests__/ 또는 src/__tests__/unit/
- 네이밍: *.spec.ts, *.spec.tsx

## 출력
```typescript
// 실패하는 테스트 코드
describe('기능명', () => {
  it('should [expected behavior] when [condition]', () => {
    // Arrange: 테스트 준비
    
    // Act: 실행
    
    // Assert: 검증 (현재는 실패)
    expect(result).toBe(expected);
  });
});
```

## 체크리스트
- [ ] 테스트가 실패하는가?
- [ ] 실패 이유가 명확한가?
- [ ] 테스트 코드는 명확하고 읽기 쉬운가?
