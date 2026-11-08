from datetime import datetime
from pathlib import Path
import os
import shutil

ignore = [
    ".DS_Store",
    ".sonar_lock",
    "__pycache__",
    "sonar-scanner",
    ".scannerwork",
    "cpython",
]

# Buckets kept in the repo but never installed, matching scripts/link-skills.sh.
skip_buckets = {"deprecated", "misc"}

home_dir = Path.home()
backup_dir = home_dir / "bak"
repo_dir = Path(os.environ.get("REPO_DIR", home_dir / "Documents" / "repos"))


def is_within(path, directory):
    try:
        path.resolve().relative_to(directory)
        return True
    except ValueError:
        return False


def skill_roots(source_dir, destination_dir):
    '''Map each installable skill folder to <destination_dir>/<skill name>, dropping the bucket level.'''
    roots = {}
    for skill_md in sorted(source_dir.rglob("SKILL.md")):
        skill_dir = skill_md.parent
        relative = skill_dir.relative_to(source_dir)
        if not relative.parts or relative.parts[0] in skip_buckets:
            continue
        if skill_dir.name in roots:
            print(f"Warning: duplicate skill name, skipping {skill_dir}")
            continue
        roots[skill_dir.name] = (skill_dir, destination_dir / skill_dir.name)
    return list(roots.values())


def copy_file(source_file, destination_file, backup_file):
    if destination_file.exists():
        source_mtime = source_file.stat().st_mtime
        destination_mtime = destination_file.stat().st_mtime
        if source_mtime == destination_mtime:
            return
        if source_mtime < destination_mtime:
            print(f"Destination is newer, skipping: {destination_file}")
            return
        print(f"Backing up {destination_file.name}")
        backup_file.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(destination_file, backup_file)

    print(f"Copying {source_file.name}")
    destination_file.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source_file, destination_file)


def sync_dir(source_repo, dir_name, target_dir, backup_dtm):
    '''
    Copy files from <repo_dir>/<source_repo>/<dir_name> to <target_dir>/<dir_name>.
    For skills, each skill folder is placed directly under the target, skipping the bucket level
    and the deprecated/misc buckets.
    A file is copied when it is missing from the target or the source is newer.
    An overwritten file is first backed up to <backup_dir>/<backup_run>/.
    Destinations that resolve inside repo_dir (for example through a symlink) are skipped.
    Files matching the ignore list are skipped.
    Deleted or renamed source files are not removed from the target.
    '''
    source_dir = repo_dir / source_repo / dir_name
    destination_dir = Path(target_dir) / dir_name
    repo_root = repo_dir.resolve()
    backup_root = backup_dir / backup_dtm / Path(target_dir).name / dir_name

    if not source_dir.is_dir():
        return

    if is_within(destination_dir, repo_root):
        print(f"Warning: skipping destination inside repository: {destination_dir}")
        return

    if dir_name == "skills":
        roots = skill_roots(source_dir, destination_dir)
    else:
        roots = [(source_dir, destination_dir)]

    for source_root, destination_root in roots:
        if is_within(destination_root, repo_root):
            print(f"Warning: skipping destination inside repository: {destination_root}")
            continue

        for source_file in source_root.rglob("*"):
            relative = source_file.relative_to(source_root)
            if any(part in ignore for part in relative.parts):
                continue

            destination_file = destination_root / relative
            if is_within(destination_file, repo_root):
                print(f"Warning: skipping destination inside repository: {destination_file}")
                continue

            try:
                if source_file.is_dir():
                    destination_file.mkdir(parents=True, exist_ok=True)
                elif source_file.is_file():
                    backup_file = backup_root / destination_file.relative_to(destination_dir)
                    copy_file(source_file, destination_file, backup_file)
            except OSError as error:
                print(f"Error syncing {source_file} to {destination_file}: {error}")


def main():
    backup_dtm = datetime.now().strftime("%Y%m%d%H%M%S")
    source_repos = ["nhsapp-ai-factory-nav-onboarding"]
    dirs_to_copy = ["skills", "instructions"]  # 'instructions' will exist in future
    target_dirs = [home_dir / ".copilot"]

    for source_repo in source_repos:
        print(f"Source repo: {source_repo}")
        for dir_name in dirs_to_copy:
            print(f"Directory: {dir_name}")
            for target_dir in target_dirs:
                sync_dir(
                    source_repo=source_repo, 
                    dir_name=dir_name, 
                    target_dir=target_dir, 
                    backup_dtm=backup_dtm)


if __name__ == "__main__":
    main()