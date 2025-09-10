# Start browser-sync and auto-rebuild markdown with pandoc
watch md_file:
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Extract filename without extension for HTML output
    dir_name=$(dirname "{{md_file}}")
    base_name=$(basename "{{md_file}}" .md)
    html_file="${dir_name}/${base_name}.html"
    
    # Define build command
    build_cmd="pandoc '{{md_file}}' -o '${html_file}' --standalone -L \${DIAGRAM_PKG}/diagram.lua --embed-resources --css=style.css"
    
    # Build once initially
    echo "Building..."
    eval "$build_cmd"
    
    # Start entr to watch for changes and rebuild
    ls "{{md_file}}" style.css | entr -r sh -c "$build_cmd" &
    ENTR_PID=$!
    
    # Start browser-sync in background
    browser-sync start --server "${dir_name}" --files "${html_file}" --startPath "${base_name}.html" &
    BROWSER_SYNC_PID=$!
    
    # Function to cleanup background processes
    cleanup() {
        echo "Stopping processes..."
        kill $ENTR_PID 2>/dev/null || true
        kill $BROWSER_SYNC_PID 2>/dev/null || true
        stty echo  # Restore terminal echo
        exit 0
    }
    
    # Trap signals to cleanup
    trap cleanup SIGINT SIGTERM
    
    echo "Started browser-sync and file watcher. Press Ctrl+C to stop."
    wait
