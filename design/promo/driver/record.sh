#!/bin/zsh
# usage: record.sh <out.mov> ; records sim, runs testRecord, answers Face ID
U=6186BDC9-5BD3-4873-947E-596A9818DD81
SP=/private/tmp/claude-501/-Users-kimtaejin-app-show-only/c75f5442-c1f2-4ebf-a98d-67fc6dad1f89/scratchpad
OUT=$1
rm -f $SP/run/markers.txt; touch $SP/run/markers.txt
xcrun simctl terminate $U com.example.showonly 2>/dev/null
xcrun simctl terminate $U com.apple.mobileslideshow 2>/dev/null
python3 $SP/watch.py $SP/run/markers.txt &
W=$!
if [[ -n $OUT ]]; then
  xcrun simctl io $U recordVideo --codec=h264 --force $OUT 2>$SP/run/rec.log &
  R=$!
  sleep 2
  python3 -c "import time;print(time.time())" > $SP/run/rec_start.txt
fi
cd $SP/uiproj && xcodebuild -project PromoDriver.xcodeproj -scheme Promo -destination "id=$U" -derivedDataPath $SP/dd2 -only-testing:PromoUITests/PromoTests/${TEST:-testRecord} test 2>&1 | grep -E "error:|failed|Executed" | head -5
if [[ -n $OUT ]]; then kill -INT $R; wait $R; fi
kill $W
cat $SP/run/markers.txt
