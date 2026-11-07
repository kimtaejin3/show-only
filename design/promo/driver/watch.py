import time, subprocess, sys
f = sys.argv[1]; seen = 0
while True:
    try: lines = open(f).read().splitlines()
    except FileNotFoundError: lines = []
    for l in lines[seen:]:
        if " AUTH" in l:
            time.sleep(1.2)
            subprocess.run(["xcrun","simctl","spawn","6186BDC9-5BD3-4873-947E-596A9818DD81","notifyutil","-p","com.apple.BiometricKit_Sim.pearl.match"])
            print("matched", l, flush=True)
    seen = len(lines); time.sleep(0.2)
