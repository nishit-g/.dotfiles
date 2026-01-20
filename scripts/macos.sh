#!/usr/bin/env bash
set -euo pipefail

info()    { echo -e "\033[0;34m▶\033[0m $*"; }
success() { echo -e "\033[0;32m✔\033[0m $*"; }
error()   { echo -e "\033[0;31m✖\033[0m $*" >&2; exit 1; }

[[ "$OSTYPE" == darwin* ]] || error "macOS only"

apply_keyboard_settings() {
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
}

apply_typing_settings() {
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
}

apply_finder_settings() {
  defaults write com.apple.finder AppleShowAllFiles -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
}

apply_dock_settings() {
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0.2
  defaults write com.apple.dock minimize-to-application -bool true
  defaults write com.apple.dock show-recents -bool false
  defaults write com.apple.dock expose-animation-duration -float 0.1
  defaults write com.apple.dock mru-spaces -bool false
}

apply_trackpad_settings() {
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
}

apply_screenshot_settings() {
  mkdir -p ~/Screenshots
  defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
  defaults write com.apple.screencapture disable-shadow -bool true
  defaults write com.apple.screencapture type -string "png"
}

apply_misc_settings() {
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
  defaults write com.apple.TextEdit RichText -int 0
  defaults write com.apple.ActivityMonitor ShowCategory -int 0
}

info "Applying macOS defaults..."

apply_keyboard_settings
apply_typing_settings
apply_finder_settings
apply_dock_settings
apply_trackpad_settings
apply_screenshot_settings
apply_misc_settings

killall Finder Dock 2>/dev/null || true

success "macOS defaults applied"
