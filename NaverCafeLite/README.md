# NaverCafeLite

iOS 14 이상에서 동작하는 네이버 카페(m.cafe.naver.com) 전용 경량 WebView 앱.

## 기능
- 로그인 유지 (쿠키 저장)
- 뒤로/앞으로 스와이프, 당겨서 새로고침, 하단 툴바(뒤로·앞으로·홈·새로고침·공유)
- 사진/동영상 첨부, 영상 인라인 재생
- 새 창 링크(target=_blank)를 같은 화면에서 열기
- 앱스토어/카페앱 호출 링크 차단 (업데이트 화면으로 튕기는 것 방지)
- Safari와 같은 User-Agent 사용

## 빌드 방법 A — GitHub Actions (Mac 없어도 됨, 추천)
1. GitHub에 새 저장소(비공개 가능)를 만들고 이 폴더 내용을 그대로 올림
2. 저장소의 **Actions** 탭 → `Build IPA` 실행 (push만 해도 자동 실행)
3. 완료되면 Artifacts에서 `NaverCafeLite-ipa` 다운로드 → 압축 풀면 `NaverCafeLite.ipa`

## 빌드 방법 B — Mac / Linux에 Theos가 있을 때
```bash
export THEOS=~/theos
./build_ipa.sh
# 결과: packages/NaverCafeLite.ipa
```

## 설치
IPA를 아이폰으로 옮겨 **TrollStore**로 열어 설치.
(iOS 15.1 + Dopamine 환경이면 대부분 TrollStore가 이미 설치되어 있음)

## 수정 팁
- 시작 페이지 변경: `WebViewController.m`의 `kHomeURL`
  (예: 자주 가는 카페 주소 `https://m.cafe.naver.com/카페아이디`)
- 앱 아이콘: `Resources/AppIcon60x60@2x.png`(120x120), `AppIcon60x60@3x.png`(180x180)가 들어 있음.
  다른 그림으로 바꾸려면 같은 이름·크기의 PNG로 덮어쓰기만 하면 됨 (원본 1024px은 `icon_1024.png`)
- 아이콘이 바로 안 바뀌면 앱 삭제 후 재설치하거나 리스프링(uicache)
