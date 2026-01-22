#!/bin/bash

# --- 설정 (확인 필요) ---
# 1. Hugo 프로젝트 루트 경로 (현재 스크립트가 실행되는 곳)
HUGO_ROOT_PATH="/Users/albert_macpro/development/plantmaru_blog"

# 2. GitHub 원격 레포지토리 URL
GITHUB_REMOTE_URL="https://github.com/Rubymania/hugo_blog.git"

# --- 스크립트 시작 ---

echo "--- gh-pages 브랜치 수동 배포 시작 ---"
echo "Hugo 프로젝트 경로: $HUGO_ROOT_PATH"
echo "GitHub 레포지토리:   $GITHUB_REMOTE_URL"
echo ""

# 1. Hugo 프로젝트 루트 디렉토리로 이동
echo "✅ Hugo 프로젝트 루트 디렉토리로 이동 중: $HUGO_ROOT_PATH"
cd "$HUGO_ROOT_PATH" || { echo "오류: Hugo 프로젝트 경로를 찾을 수 없습니다."; exit 1; }

# 2. public 폴더 내용 업데이트를 위해 Hugo 사이트 빌드
echo "✅ Hugo 사이트 빌드 중 (public 폴더 업데이트)..."
hugo --minify || { echo "오류: Hugo 빌드 실패."; exit 1; }

# 3. public 폴더로 이동하여 Git 작업 수행
echo "✅ public/ 폴더에서 Git 작업 준비 중..."
cd public || { echo "오류: public/ 폴더를 찾을 수 없습니다. Hugo 빌드가 성공했는지 확인하세요."; exit 1; }

# 4. public 폴더를 새로운 Git 저장소로 초기화 (기존 .git 폴더가 있다면 삭제)
if [ -d ".git" ]; then
    echo "   -> 기존 .git 폴더 제거 중..."
    rm -rf .git
fi
git init . || { echo "오류: public/ 폴더에서 Git 초기화 실패."; exit 1; }

# 5. 모든 빌드된 파일 추가
echo "   -> 모든 빌드된 파일 Git에 추가 중..."
git add . || { echo "오류: 파일 추가 실패."; exit 1; }

# 6. 커밋 메시지 생성
COMMIT_MESSAGE="Deploy Hugo site to gh-pages branch (manual)"
echo "   -> 커밋 메시지: \"$COMMIT_MESSAGE\""

# 7. 변경사항 커밋
git commit -m "$COMMIT_MESSAGE" || { echo "오류: 커밋 실패. 변경사항이 없는지 확인하세요."; exit 1; }

# 8. 원격 저장소 설정 (없다면 추가)
# 이미 원격 'origin'이 설정되어 있을 수 있으므로, 오류를 무시하고 추가를 시도합니다.
echo "   -> 원격 'origin' 설정 중..."
git remote add origin "$GITHUB_REMOTE_URL" 2>/dev/null
if [ $? -ne 0 ]; then
    # git remote add 명령이 실패했다면, 이미 origin이 존재할 수 있음.
    # 이때는 git remote set-url 명령어로 URL을 업데이트하거나 확인합니다.
    EXISTING_ORIGIN=$(git remote get-url origin 2>/dev/null)
    if [ "$EXISTING_ORIGIN" != "$GITHUB_REMOTE_URL" ]; then
        echo "   -> 경고: 'origin'이 이미 다른 URL로 설정되어 있습니다. URL을 업데이트합니다."
        git remote set-url origin "$GITHUB_REMOTE_URL" || { echo "오류: 원격 URL 설정 실패."; exit 1; }
    else
        echo "   -> 'origin'이 이미 올바르게 설정되어 있습니다."
    fi
fi

# 9. gh-pages 브랜치로 전환 (없으면 생성)
echo "   -> 'gh-pages' 브랜치로 전환 또는 생성 중..."
git checkout -B gh-pages || { echo "오류: 'gh-pages' 브랜치 전환/생성 실패."; exit 1; }

# 10. gh-pages 브랜치로 강제 푸시 (public 폴더의 내용을 원격 gh-pages로)
echo "✅ 'gh-pages' 브랜치로 강제 푸시 중..."
git push origin gh-pages --force || { echo "오류: 'gh-pages' 브랜치 푸시 실패. 권한 또는 네트워크 문제일 수 있습니다."; exit 1; }

# 11. 원래 Hugo 프로젝트 루트로 돌아오기
echo "✅ 원래 Hugo 프로젝트 루트로 돌아옴."
cd "$HUGO_ROOT_PATH"

echo ""
echo "--- gh-pages 브랜치 수동 배포 완료! ---"
echo "이제 GitHub 레포지토리의 'Settings' -> 'Pages'에서 소스를 'gh-pages' 브랜치로 설정하고 'plantmaru.com'을 확인하세요."