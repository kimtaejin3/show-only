"""'내 이야기' 릴스 (v2). 20만뷰 예시 영상 구조를 따른다.
  문제 상황(직접 촬영) → "불안해서 만들었어요 ㅋ" → 앱 화면 3박자 → 필요하신가요? 댓글 질문
직접 찍을 장면은 회색 칸으로 비워두고 무엇을 찍을지 적어둔다. 찍은 영상으로 그 칸만 바꾸면 된다.

python3 design/promo/story.py <take.mov> <Pretendard 폴더> <출력.mp4> [직접 찍은 영상 폴더]
"""
import os, sys, subprocess, tempfile

TAKE, FONT, OUT = sys.argv[1:4]
FOOT = sys.argv[4] if len(sys.argv) > 4 else ""
TMP = tempfile.mkdtemp()
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1080, 1920

# ("slot", 길이, 자막, 번호, 찍을 것) / ("screen", 원본 시작, 끝, 배속, 자막)
BEATS = [
    # 직접 찍은 영상 ①②: 폰 건네기 → 옆으로 넘겨봄 → 다시 뺏어옴 (7.3초 한 컷)
    ("clip", "a.mp4", 0.0, 7.3, [("엄마한테 이 사진들만 보라고\n폰을 줬는데", 0.0, 3.0),
                                 ("아니나 다를까\n옆으로 넘겨봄 ㅋㅋ", 3.0, 7.3)]),
    # 직접 찍은 영상 ③: 노트북 코딩 (IMG_3300.MOV)
    ("clip", "img.mov", 0.3, 3.3, [("불안해서\n앱을 만들었어요", 0.3, 3.3)]),
    # 실제 아이폰 화면 녹화: 홈 화면에서 앱 열기
    ("clip", "sr.mp4", 0.6, 2.8, [("딱 이 사진만", 0.6, 2.8)]),
    ("screen", 29.0, 35.7, 1.6, "보여줄 사진들만 고르면"),
    ("screen", 40.2, 45.8, 1.5, "이것들만 볼 수 있어요"),
    ("slot", 3.0, "이제 엄마한테\n마음 편히 건네요", 4,
     "첫 장면처럼 다시 엄마에게 폰을 건네는 장면\n(같은 자리, 같은 각도면 더 좋아요)"),
    ("slot", 3.2, "써보고 싶으면\n댓글로 알려주세요!", 5,
     "웃으면서 폰을 돌려받는 장면\n(또는 카메라 보며 마무리)"),
]

CSS = f"""@font-face{{font-family:P;src:url('file://{FONT}/Pretendard-SemiBold.otf')}}
*{{margin:0;padding:0;box-sizing:border-box}}
html,body{{width:{W}px;height:{H}px;overflow:hidden;font-family:P}}"""

CAPTION = """<!doctype html><html><head><meta charset="utf-8"><style>{css}
html,body{{background:transparent}}
.c{{position:absolute;left:0;right:0;top:300px;text-align:center}}
span{{display:inline-block;font-size:64px;line-height:1.3;letter-spacing:-0.02em;color:#fff;background:#000;
  border-radius:26px;padding:18px 40px 22px;white-space:nowrap}}
</style></head><body><div class="c"><span>{text}</span></div></body></html>"""

SLOT = """<!doctype html><html><head><meta charset="utf-8"><style>{css}
body{{background:#3B3E3D;position:relative}}
.box{{position:absolute;left:60px;right:60px;top:820px;bottom:200px;border:6px dashed #8C9391;border-radius:40px;
  display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;color:#fff}}
.k{{font-size:44px;color:#C9D1CF;letter-spacing:-0.01em}}
.n{{font-size:96px;margin-top:18px;letter-spacing:-0.03em}}
.d{{font-size:46px;line-height:1.45;margin-top:40px;color:#E6ECEA;letter-spacing:-0.02em}}
.t{{font-size:40px;margin-top:44px;color:#9FB0AC}}
</style></head><body><div class="box"><div class="k">내 카메라로 찍을 장면</div><div class="n">직접 찍기 {num}</div>
<div class="d">{desc}</div><div class="t">{dur:.1f}초 · 세로</div></div></body></html>"""

def shot(html, png, transparent):
    hp = png + ".html"
    open(hp, "w").write(html)
    args = [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
            f"--window-size={W},{H}", "--allow-file-access-from-files", f"--user-data-dir={TMP}/prof",
            f"--screenshot={png}", "file://" + hp]
    if transparent:
        args.insert(1, "--default-background-color=00000000")
    subprocess.run(args, check=True, capture_output=True)

def run(args):
    subprocess.run(args, check=True, capture_output=True)

def br(s):
    return s.replace("\n", "<br>")

parts = []
for i, beat in enumerate(BEATS):
    cap = os.path.join(TMP, f"cap{i}.png")
    out = os.path.join(TMP, f"p{i:02d}.mp4")
    if beat[0] == "slot":
        _, dur, text, num, desc = beat
        slot = os.path.join(TMP, f"slot{i}.png")
        shot(SLOT.format(css=CSS, num="①②③④⑤"[num - 1], desc=br(desc), dur=dur), slot, False)
        shot(CAPTION.format(css=CSS, text=br(text)), cap, True)
        run(["ffmpeg", "-y", "-loop", "1", "-t", str(dur), "-i", slot, "-loop", "1", "-t", str(dur), "-i", cap,
             "-filter_complex", "[0][1]overlay=0:0,fps=30,format=yuv420p", "-c:v", "libx264", "-crf", "16", out])
    elif beat[0] == "clip":
        _, name, a, b, caps = beat
        inputs = ["-ss", str(a), "-t", str(b - a), "-i", os.path.join(FOOT, name)]
        f = [f"[0:v]scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},fps=30,setsar=1[v0]"]
        for j, (text, ta, tb) in enumerate(caps):
            c = os.path.join(TMP, f"cap{i}_{j}.png")
            shot(CAPTION.format(css=CSS, text=br(text)), c, True)
            inputs += ["-loop", "1", "-i", c]
            f.append(f"[v{j}][{j+1}:v]overlay=0:0:enable='between(t,{ta - a:.2f},{tb - a:.2f})'[v{j+1}]")
        f.append(f"[v{len(caps)}]format=yuv420p[out]")
        run(["ffmpeg", "-y", *inputs, "-filter_complex", ";".join(f), "-map", "[out]",
             "-t", f"{b - a:.3f}", "-c:v", "libx264", "-crf", "16", out])
    else:
        _, a, b, speed, text = beat
        shot(CAPTION.format(css=CSS, text=br(text)), cap, True)
        dur = (b - a) / speed
        # 화면 녹화(1178x2556)를 9:16으로 가득 채운다: 위아래를 조금 잘라낸다
        run(["ffmpeg", "-y", "-ss", str(a), "-t", str(b - a), "-i", TAKE, "-loop", "1", "-i", cap,
             "-filter_complex", f"[0:v]setpts=(PTS-STARTPTS)/{speed},fps=30,crop=1178:2094:0:231,scale={W}:{H}[v];"
                                f"[v][1:v]overlay=0:0,format=yuv420p",
             "-t", f"{dur:.3f}", "-c:v", "libx264", "-crf", "16", out])
    parts.append(out)
    print(out, flush=True)

lst = os.path.join(TMP, "list.txt")
open(lst, "w").write("".join(f"file '{p}'\n" for p in parts))
run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", lst, "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo",
     "-shortest", "-c:v", "libx264", "-crf", "18", "-preset", "slow", "-pix_fmt", "yuv420p",
     "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart", OUT])
print(OUT)
