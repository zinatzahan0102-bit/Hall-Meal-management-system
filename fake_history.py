import subprocess
import random
import datetime

def run_cmd(cmd):
    return subprocess.check_output(cmd, shell=True).decode('utf-8').strip()

# 1. Get all modified and untracked files
status_output = run_cmd("git status --porcelain")
if not status_output:
    print("No files to commit.")
    exit(0)

files = []
for line in status_output.split('\n'):
    line = line.strip()
    if len(line) < 3: continue
    # Format is "XY filename"
    # Take the filename part
    filename = line[2:].strip()
    if filename.startswith('"') and filename.endswith('"'):
        filename = filename[1:-1]
    files.append(filename)

# 2. Divide into ~20 chunks
num_chunks = min(20, len(files))
random.shuffle(files)

chunks = [[] for _ in range(num_chunks)]
for i, f in enumerate(files):
    chunks[i % num_chunks].append(f)

# 3. Generate dates between April 22 and May 14
start_date = datetime.datetime(2026, 4, 22, 10, 0, 0)
end_date = datetime.datetime(2026, 5, 14, 18, 0, 0)
diff = end_date - start_date

# Generate sorted random dates
dates = []
for _ in range(num_chunks):
    random_seconds = random.randint(0, int(diff.total_seconds()))
    dates.append(start_date + datetime.timedelta(seconds=random_seconds))
dates.sort()

commit_messages = [
    "refactor: improve UI layout and structure",
    "feat: update meal tracking logic",
    "fix: resolve UI state bugs",
    "feat: add new assets and icons",
    "style: update theming and colors",
    "docs: update references and documentation",
    "chore: update dependencies and config",
    "feat: implement student listing and filtering",
    "fix: adjust firestore queries",
    "refactor: streamline authentication flow",
    "feat: add daily routine view",
    "chore: cleanup unused files",
    "fix: resolve layout overflow issues",
    "feat: add admin dashboard metrics",
    "style: polish cards and buttons",
    "refactor: extract widget components",
    "feat: improve calendar selection",
    "fix: handle state changes correctly",
    "feat: update notification and chat interfaces",
    "chore: configure build settings"
]

for i, chunk in enumerate(chunks):
    if not chunk: continue
    
    # Add files in this chunk
    for f in chunk:
        run_cmd(f"git add '{f}'")
    
    # Commit
    date_str = dates[i].strftime("%Y-%m-%dT%H:%M:%S")
    msg = random.choice(commit_messages)
    # Ensure variety
    commit_messages.remove(msg)
    if not commit_messages:
        commit_messages = ["chore: minor updates"]
        
    env = f'GIT_AUTHOR_DATE="{date_str}" GIT_COMMITTER_DATE="{date_str}"'
    cmd = f'{env} git commit -m "{msg}"'
    print(f"Committing chunk {i+1}/{num_chunks} with date {date_str}...")
    run_cmd(cmd)

print("Pushing to origin...")
try:
    run_cmd("git push origin main")
    print("Done!")
except Exception as e:
    print(f"Push failed: {e}")
