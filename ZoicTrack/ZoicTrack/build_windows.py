import os
import PyInstaller.__main__
import shutil

# Configuration
APP_NAME = "ZoicTrack"
MAIN_SCRIPT = "main.py"
ICON_PATH = "assets/icon.ico" if os.path.exists("assets/icon.ico") else None
ADD_DATA = [
    ("locales/", "locales"),
    ("modules/", "modules"),
    ("config.json", "."),
    ("blockchain_config.json", "."),
    ("contracts/", "contracts")
]

def build_executable():
    # Prepare PyInstaller command
    cmd = [
        MAIN_SCRIPT,
        "--onefile",
        "--windowed",
        f"--name={APP_NAME}",
        "--clean",
        "--noconfirm",
        "--distpath=dist/windows",
        "--workpath=build/windows",
        "--specpath=build/windows"
    ]

    # Add icon if available
    if ICON_PATH and os.path.exists(ICON_PATH):
        cmd.append(f"--icon={ICON_PATH}")

    # Add additional files
    for src, dest in ADD_DATA:
        if os.path.exists(src):
            cmd.append(f"--add-data={src}{os.pathsep}{dest}")

    # Run PyInstaller
    PyInstaller.__main__.run(cmd)

    print(f"\nBuild complete! Executable is in: dist/windows/{APP_NAME}.exe")

if __name__ == "__main__":
    # Create necessary directories
    os.makedirs("dist/windows", exist_ok=True)
    os.makedirs("build/windows", exist_ok=True)

    # Build the executable
    build_executable()