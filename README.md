# HowAboutNow

감정 분석을 지원하는 iOS 일기 앱

## 시작하기

### 1. 프로젝트 설정

```bash
# 프로젝트 클론
git clone https://github.com/yourusername/HowAboutNow.git
cd HowAboutNow

# Tuist 설치 (없는 경우)
curl -Ls https://install.tuist.io | bash

# 프로젝트 생성
tuist generate
```

### 2. API 키 설정

1. `App/Resources/Configuration.template.plist`를 `App/Resources/Configuration.plist`로 복사
2. `Configuration.plist` 파일을 열고 다음 값을 설정:
   - `OpenAIAPIKey`: OpenAI API 키
   - `OpenAIEndpoint`: OpenAI API 엔드포인트 (기본값 사용 가능)

### 3. 앱 실행

Xcode에서 프로젝트를 열고 실행합니다.

## 기능

- 일기 작성 및 관리
- GPT 기반 감정 분석
- 로컬 데이터 저장 (SwiftData)

## 요구사항

- iOS 17.0+
- Xcode 15.0+
- OpenAI API 키