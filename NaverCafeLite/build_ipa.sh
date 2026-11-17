#!/bin/bash
# Theos로 빌드한 뒤 TrollStore용 IPA로 묶는 스크립트
set -e
APP=NaverCafeLite

make clean
make stage FINALPACKAGE=1

STAGE=".theos/_/Applications/$APP.app"
[ -d "$STAGE" ] || { echo "스테이징된 앱을 찾을 수 없음: $STAGE"; exit 1; }

rm -rf build_ipa
mkdir -p build_ipa/Payload packages
cp -R "$STAGE" build_ipa/Payload/
ldid -S "build_ipa/Payload/$APP.app/$APP"

(cd build_ipa && zip -qry "../packages/$APP.ipa" Payload)
echo "완료: packages/$APP.ipa"
