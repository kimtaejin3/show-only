import sys, os, subprocess
import tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS = os.path.join(HERE, "source")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "6.9")
S = tempfile.mkdtemp()
os.makedirs(os.path.join(S, "gen"))
os.makedirs(OUT, exist_ok=True)
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

FRAMES = [
    ("01", "home_selected", "건네기 전에\n보여줄 사진만 골라요", "최대 10장, 고른 순서대로 보여줘요.", 0),
    ("02", "guide_top", "알림·앱 이동 막는 법,\n한 화면에 정리했어요", "iOS 집중 모드와 사용법 유도 설정을 안내해요.", 0),
    ("03", "viewer", "옆으로 넘겨도\n고른 사진만 나와요", "끝낼 때는 내 Face ID로 확인해요.", 0),
    ("04", "lock", "앱을 나갔다 오면\n사진은 잠겨 있어요", "다시 보려면 본인 확인이 필요해요.", 0),
]

THEMES = {
    "A": dict(bg="#F4F6F6", h="#111716", sub="#5C6A68", bezel="#111716"),
}

TPL = """<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:1320px;height:2868px;overflow:hidden;background:{bg}}}
body{{font-family:Pretendard,'Apple SD Gothic Neo',sans-serif;position:relative}}
.copy{{position:absolute;left:110px;right:110px;top:{copy_top}px}}
h1{{font-size:108px;line-height:1.24;font-weight:700;letter-spacing:-0.035em;color:{h};white-space:pre-line}}
p{{margin-top:40px;font-size:46px;line-height:1.4;font-weight:500;letter-spacing:-0.02em;color:{sub}}}
.phone{{position:absolute;left:50%;transform:translateX(-50%);top:{phone_top}px;width:1040px;
  padding:22px;border-radius:150px;background:{bezel}}}
.screen{{display:block;width:996px;height:2164px;border-radius:128px;overflow:hidden;position:relative}}
.screen img{{width:100%;height:100%;display:block}}
</style></head><body>
<div class="copy"><h1>{h1}</h1><p>{p}</p></div>
<div class="phone"><div class="screen"><img src="file://{img}"></div></div>
</body></html>"""

for tkey, t in THEMES.items():
    for num, shot, h1, p, shift in FRAMES:
        copy_top = 190
        phone_top = 820 + shift
        html = TPL.format(h1=h1, p=p, img=os.path.join(SHOTS, shot + ".png"),
                          copy_top=copy_top, phone_top=phone_top, **t)
        if shift < 0:
            # 휴대폰이 위로 올라가면 문구를 아래로 내린다
            html = html.replace(f"top:{copy_top}px", "bottom:220px", 1)
        hp = os.path.join(S, "gen", f"{tkey}_{num}.html")
        open(hp, "w").write(html)
        png = os.path.join(OUT, f"{num}.png")
        subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                        "--force-device-scale-factor=1", "--window-size=1320,2868",
                        "--virtual-time-budget=6000", "--allow-file-access-from-files", f"--user-data-dir={S}/chrome-prof",
                        f"--screenshot={png}", "file://" + hp],
                       check=True, capture_output=True)
        print(png)
