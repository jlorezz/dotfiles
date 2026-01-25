#!/usr/bin/env python3
import sys
import json
import os
import subprocess

input_data = sys.stdin.read()

try:
    data = json.loads(input_data)
except:
    print('Parse Error')
    sys.exit(0)

# 1. Model Name
model_name = data.get('model', {}).get('display_name', 'Unknown')

# 2. Context usage
ctx = data.get('context_window', {})
used_pct = int(ctx.get('used_percentage', 0))

# Create progress bar (20 chars wide)
bar_width = 20
filled = int(used_pct * bar_width / 100)
empty = bar_width - filled
progress_bar = '[' + '█' * filled + '─' * empty + ']'

# 3. Token counts
total_input = ctx.get('total_input_tokens', 0)
total_output = ctx.get('total_output_tokens', 0)
total_tokens = total_input + total_output
max_tokens = ctx.get('context_window_size', 200000)

def format_tokens(n):
    if n >= 1000:
        return f'{n/1000:.1f}k'.replace('.0k', 'k')
    return str(n)

tokens_display = f'{format_tokens(total_tokens)} / {format_tokens(max_tokens)}'

# 4. Git branch
cwd = data.get('cwd', data.get('workspace', {}).get('current_dir', ''))
git_branch = ''
if cwd:
    try:
        result = subprocess.run(
            ['git', '-C', cwd, 'branch', '--show-current'],
            capture_output=True, text=True, timeout=2
        )
        if result.returncode == 0:
            git_branch = result.stdout.strip()
    except:
        pass

# 5. Project name
project_dir = data.get('workspace', {}).get('project_dir', cwd)
project_name = os.path.basename(project_dir) if project_dir else ''

# Build output with colors
parts = []

# Model Name (bold cyan)
if model_name:
    parts.append(f'\033[1;36m{model_name}\033[0m')

# Progress Bar (yellow)
parts.append(f'\033[33m{progress_bar}\033[0m')

# Percentage (green)
parts.append(f'\033[32m{used_pct}%\033[0m')

# Token count (magenta)
parts.append(f'\033[35m{tokens_display}\033[0m')

# Git Branch (blue)
if git_branch:
    parts.append(f'\033[34m{git_branch}\033[0m')

# Project Name (bold white)
if project_name:
    parts.append(f'\033[1;37m{project_name}\033[0m')

print(' | '.join(parts), end='')
