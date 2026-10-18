THW Termux Theme

A colorful, customizable Bash theme for Termux.

Features

- Custom ASCII banner
- Colorful terminal effects
- Multiple patterns and color palettes
- Skull, Terminal, Lock, Rocket, and Sword styles
- Custom banner name
- Keyboard shortcuts

Requirements

- Termux
- Bash
- Git

Installation

pkg update -y && pkg install git -y

git clone https://github.com/thwhackers/Termux-theme.git

cd Termux-theme

chmod +x theme.sh

bash theme.sh

Usage

cd ~/Termux-theme
bash theme.sh
thwname

Keyboard Shortcuts

- "Ctrl + N" — Change banner name
- "Ctrl + L" — Open Telegram
- "Ctrl + P" — Open YouTube
- "Ctrl + X" — Attempt to close Bash sessions

Configuration

- Config directory: "~/.thw/"
- Banner script: "~/.thw/banner.sh"
- Name file: "~/.thw/name"

Security

Review scripts before running them. Keyboard shortcuts may close terminal sessions.

Credits

- Project: THW Termux Theme
- Developer: THW HACKER
- GitHub: https://github.com/thwhackers/Termux-theme

License

Check the repository for license information before redistribution.
