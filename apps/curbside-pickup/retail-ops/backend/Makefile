.PHONY: default build run

default: build run

build:
	python3 -m venv venv && source venv/bin/activate && pip3 install -r requirements.txt

run:
	uvicorn main:app --reload --port 8004
