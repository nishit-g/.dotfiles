#!/usr/bin/env bash
set -euo pipefail

echo "▶ Applying macOS performance defaults..."

# Keyboard: Blazing fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable auto-correct annoyances
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Finder: Show hidden files, extensions, path bar
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Finder: Disable warning when changing extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Finder: Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Dock: Auto-hide instantly
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2

# Dock: Minimize to application
defaults write com.apple.dock minimize-to-application -bool true

# Dock: Don't show recent apps
defaults write com.apple.dock show-recents -bool false

# Mission Control: Speed up animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Mission Control: Don't auto-rearrange spaces
defaults write com.apple.dock mru-spaces -bool false

# Trackpad: Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: Faster tracking speed
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5

# Screenshots: Save to ~/Screenshots, no shadow
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture type -string "png"

# Disable DS_Store on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Safari: Developer menu, disable auto-open
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# TextEdit: Use plain text by default
defaults write com.apple.TextEdit RichText -int 0

# Activity Monitor: Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Restart affected apps
echo "▶ Restarting Finder and Dock..."
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "✔ macOS defaults applied. Some changes require logout/restart."
