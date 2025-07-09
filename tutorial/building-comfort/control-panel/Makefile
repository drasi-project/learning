# Variables
VENV_DIR = venv
PYTHON = python3
PIP = $(VENV_DIR)/bin/pip
FLASK = $(VENV_DIR)/bin/flask

# Default target
all: build run

# Create virtual environment and install dependencies
build:
	$(PYTHON) -m venv $(VENV_DIR)
	$(PIP) install -r backend/requirements.txt

# Run the application
run:
	cd backend && ../$(VENV_DIR)/bin/uvicorn main:app --reload --host 0.0.0.0 --port 5000

# Clean up
clean:
	rm -rf $(VENV_DIR)

.PHONY: all build run clean