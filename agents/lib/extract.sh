#!/bin/bash
# 코드 추출 함수

# 코드 블록 추출 및 파일 생성
extract_and_create_file() {
    local result_file=$1
    local default_output=$2
    
    log "코드 블록 추출 중..."
    
    awk '/```typescript/,/```/' "$result_file" | sed '/```/d' > /tmp/extracted_code.ts
    
    if [ ! -s /tmp/extracted_code.ts ]; then
        log_warning "코드 블록을 찾을 수 없습니다"
        return 1
    fi
    
    local filepath=$(grep -m1 "^// filepath:" /tmp/extracted_code.ts | sed 's|// filepath: ||' | tr -d '\r' | xargs)
    
    if [ -z "$filepath" ]; then
        filepath="$default_output"
        log_warning "파일 경로를 찾을 수 없어 기본 경로 사용: $filepath"
    fi
    
    mkdir -p "$(dirname "$filepath")"
    grep -v "^// filepath:" /tmp/extracted_code.ts > "$filepath"
    
    log_success "파일 생성됨: $filepath"
    echo "$filepath"
    return 0
}

# 수동 추출 가이드 출력
show_manual_extraction_guide() {
    local result_file=$1
    local default_path=$2
    local file_type=$3
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 수동 코드 추출 방법:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1️⃣  filepath 주석에서 경로 추출 (추천):"
    echo -e "   ${GREEN}FILEPATH=\$(awk '/\`\`\`typescript/,/\`\`\`/' $result_file | sed '/\`\`\`/d' | grep -m1 '^// filepath:' | sed 's|// filepath: ||' | xargs)${NC}"
    echo -e "   ${GREEN}awk '/\`\`\`typescript/,/\`\`\`/' $result_file | sed '/\`\`\`/d' | grep -v '^// filepath:' > \"\$FILEPATH\"${NC}"
    echo ""
    echo "2️⃣  기본 경로로 생성 (간단):"
    echo -e "   ${GREEN}awk '/\`\`\`typescript/,/\`\`\`/' $result_file | sed '/\`\`\`/d' | grep -v '^// filepath:' > $default_path${NC}"
    echo ""
    echo "3️⃣  결과 파일을 직접 확인:"
    echo -e "   ${GREEN}cat $result_file${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}
