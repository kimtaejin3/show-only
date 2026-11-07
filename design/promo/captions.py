"""릴스 자막 PNG(1080x1920, 투명 배경)를 만든다.
검은 둥근 상자 + 흰 글씨, Pretendard(OFL). Google Chrome 헤드리스로 그린다.
python3 design/promo/captions.py <폰트 폴더> <출력 폴더>
"""
import os, sys, subprocess, tempfile

FONT_DIR, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TMP = tempfile.mkdtemp()

# (파일 이름, 줄들, 세로 위치 px)
CAPTIONS = [
    ("c01", ["친구에게 사진 보여줄 때"], None),
    ("c02", ["옆으로 넘기다가", "다른 사진까지 볼까 봐 불안했죠?"], None),
    ("c03", ["이제 보여줄 사진만 골라요"], None),
    ("c04", ["고른 사진만 넘어가요"], None),
    ("c05", ["그 뒤로는 안 넘어가요"], None),
    ("c06", ["잠깐 앱을 나갔다 와도"], None),
    ("c07", ["내 Face ID 없이는", "다시 못 봐요"], None),
    ("c08", ["끝낼 때도 내 Face ID로만"], None),
]

TPL = """<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{{font-family:P;src:url('file://{font}/Pretendard-Bold.otf');font-weight:700}}
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:1080px;height:1920px;background:transparent;overflow:hidden}}
.wrap{{position:absolute;left:0;right:0;top:{top}px;display:flex;flex-direction:column;align-items:center;gap:14px}}
span{{font-family:P;font-weight:700;font-size:{size}px;line-height:1.32;letter-spacing:-0.02em;color:#fff;text-align:center;
  background:#111;border-radius:24px;padding:20px 38px 22px;white-space:nowrap}}
</style></head><body><div class="wrap">{lines}</div></body></html>"""

for name, lines, top in CAPTIONS:
    size = 62
    # 화면 위 띠(0~400px) 가운데에 놓는다. 한 줄 상자 높이 약 110px
    top = top if top is not None else (145 if len(lines) == 1 else 104)
    html = TPL.format(font=FONT_DIR, top=top, size=size,
                      lines="<span>" + "<br>".join(lines) + "</span>")
    hp = os.path.join(TMP, name + ".html")
    open(hp, "w").write(html)
    png = os.path.join(OUT, name + ".png")
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    "--force-device-scale-factor=1", "--window-size=1080,1920",
                    "--default-background-color=00000000", "--allow-file-access-from-files",
                    f"--user-data-dir={TMP}/prof", f"--screenshot={png}", "file://" + hp],
                   check=True, capture_output=True)
    print(png)

# 화면 둥근 모서리 마스크 (682x1480) 와 마지막 카드
EXTRA = {
    "mask": ("<!doctype html><html><body style='margin:0;background:#000;width:682px;height:1480px'>"
             "<div style='width:682px;height:1480px;border-radius:64px;background:#fff'></div></body></html>", (682, 1480)),
    "endcard": (f"""<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{{font-family:P;src:url('file://{FONT_DIR}/Pretendard-Bold.otf');font-weight:700}}
*{{margin:0;padding:0}} body{{width:1080px;height:1920px;background:#F4F6F6;position:relative;overflow:hidden}}
img{{position:absolute;left:350px;top:560px;width:380px;height:380px;border-radius:86px;box-shadow:0 12px 40px rgba(17,23,22,.12)}}
.wrap{{position:absolute;left:0;right:0;top:1030px;display:flex;flex-direction:column;align-items:center;gap:14px}}
span{{font-family:P;font-weight:700;font-size:62px;line-height:1;letter-spacing:-0.02em;color:#fff;background:#111;border-radius:22px;padding:22px 34px 24px}}
</style></head><body><img src="file://{os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'app-icon.svg')}">
<div class="wrap"><span style='line-height:1.32;text-align:center'>보여줄 땐,<br>딱 이 사진만</span></div></body></html>""", (1080, 1920)),
}
for name, (html, (w, h)) in EXTRA.items():
    hp = os.path.join(TMP, name + ".html")
    open(hp, "w").write(html)
    png = os.path.join(OUT, name + ".png")
    subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
                    "--force-device-scale-factor=1", f"--window-size={w},{h}",
                    "--allow-file-access-from-files", f"--user-data-dir={TMP}/prof",
                    f"--screenshot={png}", "file://" + hp], check=True, capture_output=True)
    print(png)
