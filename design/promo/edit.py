"""시뮬레이터 녹화(take.mov)를 잘라 릴스용 1080x1920 영상으로 만든다.
python3 design/promo/edit.py <take.mov> <자막·마스크 폴더> <깨끗한 홈 화면.png> <출력.mp4>
"""
import os, sys, subprocess, tempfile

TAKE, CAP, CLEAN_SB, OUT = sys.argv[1:5]
TMP = tempfile.mkdtemp()
W, H = 1080, 1920
SW, SH, SX, SY = 682, 1480, 199, 400  # 화면 크기·위치

# (시작, 끝, 배속, [(자막, 원본 시각 from, to)], 홈 화면 패치 여부)  시각은 원본 녹화 기준(초)
SEGMENTS = [
    (10.0, 11.4, 1.0, [("c01", 0, 99)], False),                       # 사진 앱 보관함
    (17.4, 21.4, 1.0, [("c01", 0, 18.3), ("c02", 18.3, 99)], False),  # 사진 넘기다 다른 사진
    (24.6, 25.8, 1.0, [("c03", 0, 99)], False),                       # 홈
    (29.0, 35.7, 1.6, [("c03", 0, 99)], False),                       # 사진 고르기
    (36.0, 39.3, 1.3, [("c03", 0, 99)], False),                       # 3장 골랐어요
    (39.6, 49.6, 1.0, [("c04", 0, 46.0), ("c05", 46.0, 99)], False),  # 뷰어 넘기기
    (50.6, 52.85, 1.0, [("c06", 0, 99)], True),                        # 홈으로 나감
    (53.4, 54.6, 1.0, [("c07", 0, 99)], False),                       # 잠금 화면
    (55.9, 60.2, 1.6, [("c07", 0, 99)], False),                       # Face ID로 다시 보기
    (61.6, 67.2, 1.6, [("c08", 0, 99)], False),                       # 끝내기 Face ID
]
END_CARD = 2.8

def run(args):
    subprocess.run(args, check=True, capture_output=True)

parts = []
for i, (a, b, speed, caps, patch) in enumerate(SEGMENTS):
    inputs = ["-ss", str(a), "-t", str(b - a), "-i", TAKE, "-loop", "1", "-i", os.path.join(CAP, "mask.png")]
    f = []
    src = "[0:v]"
    if patch:
        # 테스트 실행기 아이콘 자리를 깨끗한 홈 화면으로 덮는다
        inputs += ["-loop", "1", "-i", CLEAN_SB]
        # 녹화는 화면이 바뀔 때만 프레임이 생기므로 fps로 고른 뒤에 덮는다
        f.append(f"[0:v]setpts=(PTS-STARTPTS)/{speed},fps=30,format=yuv420p[c0]")
        f.append(f"[2:v]crop=310:280:580:510,format=yuv420p[pt];[c0][pt]overlay=580:510:shortest=1:enable='between(t,0.15,2.3)'[src]")
        f.append("[src]split[s1][s2]")
    else:
        f.append(f"{src}setpts=(PTS-STARTPTS)/{speed},fps=30,format=yuv420p,split[s1][s2]")
    f.append(f"[s1]scale={W}:-2,crop={W}:{H},boxblur=40:2,eq=brightness=-0.06[bg]")
    f.append(f"[1:v]scale={SW}:{SH},format=gray[m]")
    f.append(f"[s2]scale={SW}:{SH},format=rgba[fg0];[fg0][m]alphamerge[fg]")
    f.append(f"[bg][fg]overlay={SX}:{SY}:shortest=1[v0]")
    last = "v0"
    idx = 3 if patch else 2
    for j, (name, fa, fb) in enumerate(caps):
        inputs += ["-i", os.path.join(CAP, name + ".png")]
        ta = max(0, (fa - a) / speed) if fa else 0
        tb = (min(fb, b) - a) / speed
        f.append(f"[{last}][{idx}:v]overlay=0:0:enable='between(t,{ta:.2f},{tb:.2f})'[v{j+1}]")
        last = f"v{j+1}"
        idx += 1
    out = os.path.join(TMP, f"p{i:02d}.mp4")
    run(["ffmpeg", "-y", *inputs, "-filter_complex", ";".join(f), "-map", f"[{last}]",
         "-t", f"{(b - a) / speed:.3f}", "-r", "30", "-c:v", "libx264", "-crf", "16", "-preset", "medium",
         "-pix_fmt", "yuv420p", out])
    parts.append(out)
    print(out, flush=True)

end = os.path.join(TMP, "p99.mp4")
run(["ffmpeg", "-y", "-loop", "1", "-t", str(END_CARD), "-i", os.path.join(CAP, "endcard.png"),
     "-vf", "fps=30,format=yuv420p,fade=t=in:st=0:d=0.25", "-c:v", "libx264", "-crf", "16", "-pix_fmt", "yuv420p", end])
parts.append(end)

lst = os.path.join(TMP, "list.txt")
open(lst, "w").write("".join(f"file '{p}'\n" for p in parts))
run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", lst,
     "-f", "lavfi", "-i", "anullsrc=r=44100:cl=stereo", "-shortest",
     "-c:v", "libx264", "-crf", "18", "-preset", "slow", "-pix_fmt", "yuv420p",
     "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart", OUT])
print(OUT)
