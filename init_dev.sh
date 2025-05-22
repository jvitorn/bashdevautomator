#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="$HOME/Documentos/projetos"
PROJECT="${1:-my-project}"
CMD_DEV="${2:-npm run dev}"
PORT="${3:-3000}"
PROJECT_DIR="$BASE_DIR/$PROJECT"

# Validate project directory
if [ ! -d "$PROJECT_DIR" ]; then
  echo -e "${RED}❌ Error:${NC} Directory '$PROJECT_DIR' not found."
  exit 1
fi

# Check for wmctrl
if ! command -v wmctrl &> /dev/null; then
  echo -e "${YELLOW}⚠️ Warning:${NC} 'wmctrl' not found. Workspace switch will be skipped."
else
  echo -e "${GREEN}✔️ Switching to a new workspace...${NC}"
  wmctrl -s 1
fi

# Check for VSCode
if command -v code &> /dev/null; then
  echo -e "${GREEN}✔️ Opening VSCode in project:${NC} $PROJECT_DIR"
  code "$PROJECT_DIR" 2>/dev/null
else
  echo -e "${YELLOW}⚠️ Warning:${NC} 'code' not found. Skipping VSCode opening."
fi

# Enter the project directory
cd "$PROJECT_DIR" || exit

# Start the development server in a new process group
echo -e "${GREEN}✔️ Starting development server:${NC} $CMD_DEV"
eval "$CMD_DEV" &

SERVER_PID=$!
SERVER_PGID=$(ps -o pgid= $SERVER_PID | grep -o '[0-9]*')

# Trap for Ctrl+C (SIGINT)
trap 'echo -e "\n${RED}❌ Stopping development server...${NC}"; kill -TERM -$SERVER_PGID; exit' SIGINT

# Spinner while waiting
echo -ne "${CYAN}⏳ Waiting for the server to start: ${NC}"
spin='/-\|'
for i in {1..20}; do
  printf "\b${spin:i%${#spin}:1}"
  sleep 0.2
done
echo -e "\n${GREEN}✔️ Server started!${NC}"

# Check for xdg-open
if command -v xdg-open &> /dev/null; then
  echo -e "${GREEN}✔️ Opening browser at:${NC} http://localhost:$PORT"
  xdg-open "http://localhost:$PORT" 2>/dev/null
else
  echo -e "${YELLOW}⚠️ Warning:${NC} 'xdg-open' not found. Please open http://localhost:$PORT manually."
fi

# Wait for the server process to finish
wait $SERVER_PID

# Final message
echo -e "\n${GREEN}✔️ Development environment ready!${NC}"

