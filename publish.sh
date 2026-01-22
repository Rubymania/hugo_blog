#!/bin/bash

# --- 1. 설정 (기존 설정 유지) ---
OBSIDIAN_ROOT_PATH="/Users/albert_macpro/Library/Mobile Documents/iCloud~md~obsidian/Documents/PlantmaruObsidian"
HUGO_ROOT_PATH="/Users/albert_macpro/development/plantmaru_blog"
OBSIDIAN_IMAGES_SUBPATH="images"
HUGO_STATIC_IMAGES_SUBPATH="static/images"
GITHUB_REMOTE_URL="https://github.com/Rubymania/hugo_blog.git"

# 복사할 섹션 정의
OBSIDIAN_SECTIONS=("calendar" "encyclopedia" "guides" "problems" "reviews")

echo "============================================"
echo "   Plantmaru 블로그 통합 배포 시작"
echo "============================================"

# --- 2. Obsidian 콘텐츠 복사 ---
echo "Step 1: Obsidian에서 마크다운 및 이미지 복사 중..."
for section in "${OBSIDIAN_SECTIONS[@]}"; do
    OBSIDIAN_SECTION_DIR="${OBSIDIAN_ROOT_PATH}/content/posts/${section}"
    HUGO_CONTENT_DIR="${HUGO_ROOT_PATH}/content/posts/${section}"

    if [ -d "$OBSIDIAN_SECTION_DIR" ]; then
        mkdir -p "$HUGO_CONTENT_DIR"
        find "$OBSIDIAN_SECTION_DIR" -maxdepth 1 -name "*.md" -exec cp -f {} "$HUGO_CONTENT_DIR/" \;
        echo " ✅ '$section' 섹션 복사 완료"
    fi
done

# 이미지 복사
OBSIDIAN_ALL_IMAGES_DIR="${OBSIDIAN_ROOT_PATH}/${OBSIDIAN_IMAGES_SUBPATH}"
HUGO_STATIC_IMAGES_DIR="${HUGO_ROOT_PATH}/${HUGO_STATIC_IMAGES_SUBPATH}"
mkdir -p "$HUGO_STATIC_IMAGES_DIR"
if [ -d "$OBSIDIAN_ALL_IMAGES_DIR" ]; then
    cp -rf "$OBSIDIAN_ALL_IMAGES_DIR/." "$HUGO_STATIC_IMAGES_DIR/"
    echo " ✅ 이미지 파일 복사 완료"
fi

# --- 3. Hugo 소스 코드 GitHub 커밋 (Main Branch) ---
echo -e "\nStep 2: Hugo 소스 코드 GitHub 업데이트 중..."
cd "$HUGO_ROOT_PATH" || exit
git add .
git commit -m "Update content from Obsidian: $(date +'%Y-%m-%d %H:%M:%S')"
git push origin main # 브랜치명이 master라면 master로 수정하세요.

# --- 4. Hugo 빌드 및 gh-pages 배포 ---
echo -e "\nStep 3: Hugo 빌드 및 gh-pages 배포 중..."
hugo --minify || { echo "❌ Hugo 빌드 실패"; exit 1; }

# public 폴더 이동 및 배포 작업
cd public || { echo "❌ public 폴더를 찾을 수 없음"; exit 1; }

# public 내 git 초기화 및 강제 푸시 (기존 로직 유지)
if [ -d ".git" ]; then rm -rf .git; fi
git init .
git add .
git commit -m "Deploy Hugo site to gh-pages: $(date +'%Y-%m-%d %H:%M:%S')"
git remote add origin "$GITHUB_REMOTE_URL"
git checkout -B gh-pages
git push origin gh-pages --force

echo -e "\n============================================"
echo " 🎉 모든 작업이 완료되었습니다!"
echo " Plantmaru 블로그가 성공적으로 업데이트되었습니다."
echo "============================================"
