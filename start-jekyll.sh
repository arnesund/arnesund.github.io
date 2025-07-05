#!/bin/bash

# Jekyll Development Server Startup Script
# This script starts Jekyll in the background with auto-reload

cd "$(dirname "$0")"

# Set up rbenv if available
if command -v rbenv &> /dev/null; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PID_FILE=".jekyll.pid"
LOG_FILE="jekyll.log"

# Function to check if Jekyll is running
check_jekyll() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# Function to start Jekyll
start_jekyll() {
    echo -e "${GREEN}Starting Jekyll development server...${NC}"
    
    # Start Jekyll in background
    nohup bundle exec jekyll serve --host 0.0.0.0 --port 4000 --incremental --livereload > "$LOG_FILE" 2>&1 &
    
    # Save PID
    echo $! > "$PID_FILE"
    
    # Wait a moment for server to start
    sleep 3
    
    if check_jekyll; then
        echo -e "${GREEN}✓ Jekyll server started successfully${NC}"
        echo -e "${GREEN}✓ Server running at: http://localhost:4000${NC}"
        echo -e "${GREEN}✓ PID: $(cat $PID_FILE)${NC}"
        echo -e "${YELLOW}✓ Auto-reload and live-reload enabled${NC}"
        echo -e "${YELLOW}✓ Log file: $LOG_FILE${NC}"
        echo ""
        echo "Commands:"
        echo "  ./start-jekyll.sh stop    - Stop the server"
        echo "  ./start-jekyll.sh restart - Restart the server" 
        echo "  ./start-jekyll.sh status  - Check server status"
        echo "  ./start-jekyll.sh logs    - Show recent logs"
    else
        echo -e "${RED}✗ Failed to start Jekyll server${NC}"
        echo "Check the log file for errors: $LOG_FILE"
        exit 1
    fi
}

# Function to stop Jekyll
stop_jekyll() {
    if check_jekyll; then
        PID=$(cat "$PID_FILE")
        echo -e "${YELLOW}Stopping Jekyll server (PID: $PID)...${NC}"
        kill $PID
        rm -f "$PID_FILE"
        sleep 2
        echo -e "${GREEN}✓ Jekyll server stopped${NC}"
    else
        echo -e "${YELLOW}Jekyll server is not running${NC}"
    fi
}

# Function to show status
show_status() {
    if check_jekyll; then
        PID=$(cat "$PID_FILE")
        echo -e "${GREEN}✓ Jekyll server is running${NC}"
        echo -e "${GREEN}✓ PID: $PID${NC}"
        echo -e "${GREEN}✓ URL: http://localhost:4000${NC}"
        echo -e "${GREEN}✓ Log file: $LOG_FILE${NC}"
    else
        echo -e "${RED}✗ Jekyll server is not running${NC}"
    fi
}

# Function to show logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "${YELLOW}Recent Jekyll logs:${NC}"
        tail -n 20 "$LOG_FILE"
    else
        echo -e "${RED}No log file found${NC}"
    fi
}

# Main script logic
case "${1:-start}" in
    "start")
        if check_jekyll; then
            echo -e "${YELLOW}Jekyll server is already running${NC}"
            show_status
        else
            start_jekyll
        fi
        ;;
    "stop")
        stop_jekyll
        ;;
    "restart")
        stop_jekyll
        sleep 1
        start_jekyll
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "Commands:"
        echo "  start   - Start Jekyll server (default)"
        echo "  stop    - Stop Jekyll server"
        echo "  restart - Restart Jekyll server"
        echo "  status  - Show server status"
        echo "  logs    - Show recent logs"
        exit 1
        ;;
esac