#!/bin/bash

# 개별 에이전트 실행 스크립트

set -e

AGENTS_DIR="agents"
LOG_DIR="agents/logs"
mkdir -p "$LOG_DIR"

# 색상 정의
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[AGENT]${NC} $1"
}

if [ "$#" -lt 2 ]; then
    echo "사용법: $0 <agent-name> <input-file>"
    echo ""
    echo "사용 가능한 에이전트:"
    echo "  spec-validator  - 명세 검증"
    echo "  test-designer   - 테스트 설계"
    echo "  red             - 실패하는 테스트 작성"
    echo "  green           - 테스트 통과 구현"
    echo "  refactor        - 코드 리팩토링"
    echo ""
    echo "예시: $0 spec-validator specs/feature.md"
    exit 1
fi

AGENT_NAME="$1"
INPUT_FILE="$2"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$LOG_DIR/${AGENT_NAME}_${TIMESTAMP}.prompt"

log "에이전트: $AGENT_NAME"
log "입력 파일: $INPUT_FILE"

case "$AGENT_NAME" in
    spec-validator)
        cat "$AGENTS_DIR/spec-validator/prompt.md" > "$OUTPUT_FILE"
        echo -e "\n\n## 검증할 명세:\n" >> "$OUTPUT_FILE"
        cat "$INPUT_FILE" >> "$OUTPUT_FILE"
        ;;
    test-designer)
        cat "$AGENTS_DIR/test-designer/prompt.md" > "$OUTPUT_FILE"
        echo -e "\n\n## 설계할 명세:\n" >> "$OUTPUT_FILE"
        cat "$INPUT_FILE" >> "$OUTPUT_FILE"
        ;;
    red)
        cat "$AGENTS_DIR/tdd-cycle/red.md" > "$OUTPUT_FILE"
        echo -e "\n\n## 테스트 설계:\n" >> "$OUTPUT_FILE"
        cat "$INPUT_FILE" >> "$OUTPUT_FILE"
        ;;
    green)
        cat "$AGENTS_DIR/tdd-cycle/green.md" > "$OUTPUT_FILE"
        echo -e "\n\n## 실패한 테스트:\n" >> "$OUTPUT_FILE"
        cat "$INPUT_FILE" >> "$OUTPUT_FILE"
        ;;
    refactor)
        cat "$AGENTS_DIR/tdd-cycle/refactor.md" > "$OUTPUT_FILE"
        echo -e "\n\n## 리팩토링할 코드:\n" >> "$OUTPUT_FILE"
        cat "$INPUT_FILE" >> "$OUTPUT_FILE"
        ;;
    *)
        echo "알 수 없는 에이전트: $AGENT_NAME"
        exit 1
        ;;
esac

echo -e "${GREEN}✓${NC} 프롬프트 생성 완료: $OUTPUT_FILE"
echo ""
echo "다음 단계:"
echo "  1. Claude CLI를 사용하는 경우:"
echo "     cat $OUTPUT_FILE | claude"
echo ""
echo "  2. 또는 파일 내용을 복사하여 Claude에게 전달:"
echo "     cat $OUTPUT_FILE"
