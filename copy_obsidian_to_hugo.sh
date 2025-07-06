#!/bin/bash

# --- 설정 (필수 수정) ---
# 1. Obsidian 저장소 루트 경로
OBSIDIAN_ROOT_PATH="/Users/albert_macpro/Library/Mobile Documents/iCloud~md~obsidian/Documents/PlantmaruObsidian"
              
# 2. Hugo 프로젝트 루트 경로 (현재 스크립트가 실행되는 곳)
HUGO_ROOT_PATH="/Users/albert_macpro/development/plantmaru_blog"

# 3. Obsidian 내 이미지 파일이 저장되는 상대 경로 (Obsidian 설정에 따라 다를 수 있음)
#    예: Obsidian Vault/images 또는 Obsidian Vault/assets 등
OBSIDIAN_IMAGES_SUBPATH="images" # Obsidian Vault 내부에 images 폴더가 있다면 images

# 4. Hugo 내 이미지를 저장할 static 폴더 내의 상대 경로
HUGO_STATIC_IMAGES_SUBPATH="static/images"

# --- 스크립트 시작 ---

echo "--- Obsidian 콘텐츠를 Hugo로 복사 시작 ---"
echo "Obsidian 경로: $OBSIDIAN_ROOT_PATH"
echo "Hugo 경로:     $HUGO_ROOT_PATH"
echo ""

# 1. 각 섹션 폴더별로 마크다운 파일 복사
# Obsidian의 8개 폴더명을 배열로 정의합니다.
OBSIDIAN_SECTIONS=(
    "app-guide"
    "calendar"
    "encyclopedia"
    "guides"
    "problems"
    "reviews"
    "stories"
    "trends"
)

for section in "${OBSIDIAN_SECTIONS[@]}"; do
    OBSIDIAN_SECTION_DIR="${OBSIDIAN_ROOT_PATH}/content/posts/${section}"
    HUGO_CONTENT_DIR="${HUGO_ROOT_PATH}/content/posts/${section}"

    if [ -d "$OBSIDIAN_SECTION_DIR" ]; then
        echo "✅ '$section' 섹션의 마크다운 파일 복사 중..."
        # 해당 섹션 폴더의 모든 .md 파일을 Hugo content/section 폴더로 복사
        # -f: 기존 파일이 있으면 강제로 덮어쓰기
        find "$OBSIDIAN_SECTION_DIR" -maxdepth 1 -name "*.md" -print0 | while IFS= read -r -d $'\0' file; do
            filename=$(basename "$file")
            # 파일명에 한글, 특수문자가 있을 경우 영문-하이픈으로 변경 (선택 사항, 필요시 주석 해제)
            # cleaned_filename=$(echo "$filename" | iconv -f utf8 -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9_-]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')
            # cp -f "$file" "${HUGO_CONTENT_DIR}/${cleaned_filename}"
            cp -f "$file" "${HUGO_CONTENT_DIR}/${filename}" # 일단 원본 파일명 유지
            echo "   -> $filename"
        done
    else
        echo "⚠️ 경고: Obsidian에 '$section' 폴더가 없습니다: $OBSIDIAN_SECTION_DIR"
        echo "   -> Obsidian Vault 내의 폴더 구조를 확인해주세요. (예: $OBSIDIAN_ROOT_PATH/app-guide)"
    fi
done

echo ""

# 2. 이미지 파일 복사
OBSIDIAN_ALL_IMAGES_DIR="${OBSIDIAN_ROOT_PATH}/${OBSIDIAN_IMAGES_SUBPATH}"
HUGO_STATIC_IMAGES_DIR="${HUGO_ROOT_PATH}/${HUGO_STATIC_IMAGES_SUBPATH}"

echo "✅ 이미지 파일 복사 중: $OBSIDIAN_ALL_IMAGES_DIR -> $HUGO_STATIC_IMAGES_DIR"

# Hugo static 이미지 폴더가 없으면 생성
mkdir -p "$HUGO_STATIC_IMAGES_DIR"

if [ -d "$OBSIDIAN_ALL_IMAGES_DIR" ]; then
    # Obsidian 이미지 폴더의 모든 내용을 Hugo static 이미지 폴더로 복사
    # -r: 하위 디렉토리도 재귀적으로 복사
    # -v: 복사 진행 상황 표시
    cp -rv "$OBSIDIAN_ALL_IMAGES_DIR/." "$HUGO_STATIC_IMAGES_DIR/"
else
    echo "⚠️ 경고: Obsidian에 이미지 폴더가 없습니다: $OBSIDIAN_ALL_IMAGES_DIR"
    echo "   -> Obsidian 이미지 저장 경로를 확인하거나 OBSIDIAN_IMAGES_SUBPATH 설정을 점검해주세요."
fi

echo ""
echo "--- 콘텐츠 복사 완료! ---"
echo "이제 'cd $HUGO_ROOT_PATH'로 이동하여 'hugo server'를 실행하여 확인하거나, Git 푸시를 진행하세요."
echo ""