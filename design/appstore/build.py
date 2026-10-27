import sys, os, subprocess
import tempfile
HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS = os.path.join(HERE, "source")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "6.9")
S = tempfile.mkdtemp()
os.makedirs(os.path.join(S, "gen"))
os.makedirs(OUT, exist_ok=True)
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# 빈 줄(\n\n)로 나눈 문단은 같은 크기로 쓰고 사이만 띄운다. 보조 문구는 쓰지 않는다.
FRAMES = [
    ("01", "viewer", "사진 보여줄 때,\n다른 사진까지\n볼까 봐 걱정되나요?", "", 0),
    ("02", "home_selected", "보여주고 싶은\n사진만 골라서\n보여주세요", "", 0),
    ("03", "guide_top", "카톡 알림이나\n다른 앱으로 이동하는 게\n걱정된다면?\n\n보호 설정 방법도\n알려드려요", "", 160),
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
h1{{font-size:96px;line-height:1.24;font-weight:700;letter-spacing:-0.035em;color:{h};white-space:pre-line}}
h1+h1{{margin-top:36px}}
p{{margin-top:40px;font-size:46px;line-height:1.4;font-weight:500;letter-spacing:-0.02em;color:{sub}}}
.phone{{position:absolute;left:50%;transform:translateX(-50%);top:{phone_top}px;width:1040px;
  padding:22px;border-radius:150px;background:{bezel}}}
.screen{{display:block;width:996px;height:2164px;border-radius:128px;overflow:hidden;position:relative}}
.screen img{{width:100%;height:100%;display:block}}
</style></head><body>
<div class="copy">{h1}{p}</div>
<div class="phone"><div class="screen"><img src="file://{img}"></div></div>
</body></html>"""

for tkey, t in THEMES.items():
    for num, shot, h1, p, shift in FRAMES:
        copy_top = 190
        phone_top = 820 + shift
        h1 = "".join(f"<h1>{b}</h1>" for b in h1.split("\n\n"))
        p = f"<p>{p}</p>" if p else ""
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
