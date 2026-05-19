import os
import sys
import time
import subprocess
import json

def is_pid_running(pid):
    try:
        # On Windows, tasklist can check if a PID exists
        output = subprocess.check_output(f'tasklist /FI "PID eq {pid}"', shell=True)
        return str(pid) in str(output)
    except Exception:
        return False

def log(msg, log_file):
    print(msg)
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")

def main():
    if len(sys.argv) < 4:
        print("Usage: python bg_install.py <parent_pid> <antigravity_path> <project_root>")
        sys.exit(1)

    parent_pid = int(sys.argv[1])
    antigravity_path = sys.argv[2]
    project_root = sys.argv[3]

    log_file = os.path.join(project_root, "bg_install.log")
    
    # Reset log file
    with open(log_file, "w", encoding="utf-8") as f:
        f.write("")

    log(f"Starting background installer. Waiting for PID {parent_pid} to exit...", log_file)
    log(f"Antigravity Path: {antigravity_path}", log_file)
    log(f"Project Root: {project_root}", log_file)

    # Wait for the parent process to exit
    wait_count = 0
    while is_pid_running(parent_pid):
        time.sleep(1.0)
        wait_count += 1
        if wait_count % 10 == 0:
            log(f"Still waiting for PID {parent_pid} to exit (waited {wait_count}s)...", log_file)
            
    log(f"PID {parent_pid} has exited. Starting file replacement...", log_file)

    # Allow a brief moment for locks to release
    time.sleep(2.0)

    try:
        # 1. Run translate_ui.py to generate front-end bundle
        log("1. Generating frontend UI translation bundle...", log_file)
        translate_script = os.path.join(project_root, "scripts", "translate_ui.py")
        subprocess.check_call([sys.executable, translate_script], shell=True)

        # 2. Backup and repack app.asar
        log("2. Repacking app.asar...", log_file)
        asar_path = os.path.join(antigravity_path, "resources", "app.asar")
        extracted_path = os.path.join(antigravity_path, "resources", "extracted_asar")
        
        if os.path.exists(extracted_path):
            if not os.path.exists(asar_path + ".bak"):
                # Create backup
                import shutil
                shutil.copy2(asar_path, asar_path + ".bak")
                log("Created backup of original app.asar", log_file)
            
            # Pack using npx asar
            subprocess.check_call(f'npx asar pack "{extracted_path}" "{asar_path}"', shell=True)
            log("Successfully repacked app.asar", log_file)
        else:
            log(f"Error: Extracted directory not found: {extracted_path}", log_file)
            sys.exit(1)

        # 3. Apply NLS translations to VS Code core
        log("3. Applying VS Code core NLS translations...", log_file)
        app_out = os.path.join(antigravity_path, "resources", "app", "out")
        nls_orig = os.path.join(app_out, "nls.messages.json")
        if not os.path.exists(nls_orig + ".bak"):
            import shutil
            shutil.copy2(nls_orig, nls_orig + ".bak")
            
        nls_trans = os.path.join(project_root, "translations", "nls.messages.zh-CN.json")
        import shutil
        shutil.copy2(nls_trans, nls_orig)
        log("Successfully applied VS Code core NLS translations", log_file)

        # 4. Apply product.json translations
        log("4. Applying product.json translations...", log_file)
        prod_orig = os.path.join(antigravity_path, "resources", "app", "product.json")
        if not os.path.exists(prod_orig + ".bak"):
            import shutil
            shutil.copy2(prod_orig, prod_orig + ".bak")
            
        prod_trans = os.path.join(project_root, "translations", "product.json")
        shutil.copy2(prod_trans, prod_orig)
        log("Successfully applied product.json translations", log_file)

        # 5. Apply extensions translations
        log("5. Applying extension translations...", log_file)
        ext_dir = os.path.join(antigravity_path, "resources", "app", "extensions")
        agy_extensions = [
            "antigravity",
            "antigravity-code-executor",
            "antigravity-dev-containers",
            "antigravity-remote-openssh",
            "antigravity-remote-wsl"
        ]
        for ext in agy_extensions:
            ext_path = os.path.join(ext_dir, ext)
            if os.path.exists(ext_path):
                pkg_orig = os.path.join(ext_path, "package.json")
                if not os.path.exists(pkg_orig + ".bak"):
                    shutil.copy2(pkg_orig, pkg_orig + ".bak")
                pkg_trans = os.path.join(project_root, "translations", "extensions", ext, "package.json")
                if os.path.exists(pkg_trans):
                    shutil.copy2(pkg_trans, pkg_orig)
                    log(f"Applied translations to {ext}/package.json", log_file)

        log("Localization files successfully applied! Relaunching Antigravity...", log_file)
        
        # 6. Relaunch Antigravity.exe
        exe_path = os.path.join(antigravity_path, "Antigravity.exe")
        subprocess.Popen([exe_path], creationflags=subprocess.CREATE_NEW_CONSOLE)
        log("Relaunch command sent successfully.", log_file)

    except Exception as e:
        log(f"CRITICAL ERROR: {str(e)}", log_file)
        import traceback
        log(traceback.format_exc(), log_file)
        sys.exit(1)

if __name__ == "__main__":
    main()
