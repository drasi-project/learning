#!/bin/bash
# Copyright 2025 The Drasi Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Installs tools required for AI-powered tutorial evaluation.
#
# This script only runs when DRASI_TUTORIAL_EVALUATION=true, which is
# explicitly set by the GitHub Actions tutorial evaluation workflows.
#
# Tools installed:
#   - @github/copilot: GitHub Copilot CLI for AI agent
#   - playwright: Browser automation for taking screenshots
#   - chromium: Headless browser for Playwright
#
# Usage: Source this script from post-create.sh:
#   source "$(dirname "$0")/scripts/install-evaluation-tools.sh"  # from .devcontainer/
#   source "$(dirname "$0")/../scripts/install-evaluation-tools.sh"  # from .devcontainer/*/

if [ "$DRASI_TUTORIAL_EVALUATION" = "true" ]; then
    echo "Installing tutorial evaluation tools..."

    echo "Installing GitHub Copilot CLI..."
    npm install -g @github/copilot

    echo "Installing Playwright..."
    npm install -g playwright

    echo "Installing Chromium browser for Playwright..."
    npx playwright install --with-deps chromium

    echo "Evaluation tools installed successfully."
fi
