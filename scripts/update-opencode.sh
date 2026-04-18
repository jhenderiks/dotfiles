#!/usr/bin/env bash
# Update opencode derivation with latest release hashes
# Usage: ./scripts/update-opencode.sh [--check-only]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OPENCODE_NIX="${DOTFILES_DIR}/modules/common/dev/opencode/default.nix"
OPENCODE_DESKTOP_NIX="${DOTFILES_DIR}/modules/common/apps/opencode-desktop.nix"

# GitHub API
API_URL="https://api.github.com/repos/anomalyco/opencode/releases/latest"

# Check dependencies
check_deps() {
    local missing=()
    for cmd in curl jq nix; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Error: Missing required commands: ${missing[*]}${NC}"
        echo "Please install them: nix-shell -p curl jq nix"
        exit 1
    fi
}

fetch_release() {
    echo "Fetching latest release info..." >&2
    curl -s -H "Accept: application/vnd.github.v3+json" "$API_URL"
}

fetch_latest() {
    local response="$1"

    local tag_name
    tag_name=$(echo "$response" | jq -r '.tag_name')
    
    if [ -z "$tag_name" ] || [ "$tag_name" = "null" ]; then
        echo -e "${RED}Error: Could not fetch latest release${NC}" >&2
        exit 1
    fi
    
    # Remove 'v' prefix
    local version="${tag_name#v}"
    
    echo "$version"
}

# Get current version from nix file
get_current_version() {
    local nix_file="$1"
    grep -E '^\s+version\s*=\s*"[^"]+"' "$nix_file" | head -1 | sed 's/.*"\([^"]*\)".*/\1/'
}

get_asset_hash() {
    local response="$1"
    local asset_name="$2"

    local digest
    digest=$(echo "$response" | jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .digest' | head -1)

    if [ -z "$digest" ] || [ "$digest" = "null" ]; then
        echo -e "${RED}Error: Could not find digest for ${asset_name}${NC}" >&2
        return 1
    fi

    if [[ "$digest" != sha256:* ]]; then
        echo -e "${RED}Error: Unsupported digest format for ${asset_name}: ${digest}${NC}" >&2
        return 1
    fi

    nix hash convert --hash-algo sha256 --to sri "${digest#sha256:}"
}

update_nix_files() {
    local version="$1"
    local linux_x64_hash="$2"
    local linux_arm64_hash="$3"
    local darwin_x64_hash="$4"
    local darwin_arm64_hash="$5"
    local desktop_linux_amd64_hash="$6"
    
    echo "Updating ${OPENCODE_NIX}..."
    echo "Updating ${OPENCODE_DESKTOP_NIX}..."

    local opencode_temp_file
    local desktop_temp_file
    opencode_temp_file=$(mktemp)
    desktop_temp_file=$(mktemp)

    awk -v lx="$linux_x64_hash" \
        -v la="$linux_arm64_hash" \
        -v dx="$darwin_x64_hash" \
        -v da="$darwin_arm64_hash" \
        -v ver="$version" \
        '
        !done_version && /version = "[^"]*";/ {
            sub(/version = "[^"]*";/, "version = \"" ver "\";")
            done_version = 1
        }

        /^\s+x86_64-linux = \{/ { in_linux_x64 = 1 }
        /^\s+aarch64-linux = \{/ { in_linux_arm64 = 1 }
        /^\s+x86_64-darwin = \{/ { in_darwin_x64 = 1 }
        /^\s+aarch64-darwin = \{/ { in_darwin_arm64 = 1 }
        
        /sha256 = "sha256-/ { 
            if (in_linux_x64 && !done_linux_x64) {
                sub(/sha256 = "[^"]*";/, "sha256 = \"" lx "\";"); 
                done_linux_x64 = 1
            }
            if (in_linux_arm64 && !done_linux_arm64) {
                sub(/sha256 = "[^"]*";/, "sha256 = \"" la "\";"); 
                done_linux_arm64 = 1
            }
            if (in_darwin_x64 && !done_darwin_x64) {
                sub(/sha256 = "[^"]*";/, "sha256 = \"" dx "\";"); 
                done_darwin_x64 = 1
            }
            if (in_darwin_arm64 && !done_darwin_arm64) {
                sub(/sha256 = "[^"]*";/, "sha256 = \"" da "\";"); 
                done_darwin_arm64 = 1
            }
        }
        
        /^\s*\};$/ {
            in_linux_x64 = 0
            in_linux_arm64 = 0
            in_darwin_x64 = 0
            in_darwin_arm64 = 0
        }
        
        { print }
    ' "$OPENCODE_NIX" > "$opencode_temp_file"

    awk -v ver="$version" -v dh="$desktop_linux_amd64_hash" '
        !done_version && /version = "[^"]*";/ {
            sub(/version = "[^"]*";/, "version = \"" ver "\";")
            done_version = 1
        }

        !done_hash && /sha256 = "sha256-/ {
            sub(/sha256 = "[^"]*";/, "sha256 = \"" dh "\";")
            done_hash = 1
        }

        { print }
    ' "$OPENCODE_DESKTOP_NIX" > "$desktop_temp_file"

    mv "$opencode_temp_file" "$OPENCODE_NIX"
    mv "$desktop_temp_file" "$OPENCODE_DESKTOP_NIX"
    
    echo -e "${GREEN}Successfully updated opencode packages to version ${version}${NC}"
}

# Main
main() {
    local check_only=false
    
    if [ "${1:-}" = "--check-only" ]; then
        check_only=true
    fi
    
    check_deps
    
    local current_cli_version
    local current_desktop_version
    current_cli_version=$(get_current_version "$OPENCODE_NIX")
    current_desktop_version=$(get_current_version "$OPENCODE_DESKTOP_NIX")
    
    echo "Current CLI version: $current_cli_version"
    echo "Current desktop version: $current_desktop_version"

    local release
    release=$(fetch_release)

    local latest_version
    latest_version=$(fetch_latest "$release")
    
    echo "Latest version: $latest_version"
    
    if [ "$current_cli_version" != "$current_desktop_version" ]; then
        echo -e "${YELLOW}Version drift detected: CLI ${current_cli_version}, desktop ${current_desktop_version}${NC}"
    fi

    if [ "$current_cli_version" = "$latest_version" ] && [ "$current_desktop_version" = "$latest_version" ]; then
        echo -e "${GREEN}Already up to date!${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}Update available: CLI ${current_cli_version} / desktop ${current_desktop_version} → ${latest_version}${NC}"
    
    if [ "$check_only" = true ]; then
        exit 0
    fi
    
    echo ""
    echo "Reading release digests for all platforms..."
    
    # Compute hashes
    local linux_x64_hash
    local linux_arm64_hash
    local darwin_x64_hash
    local darwin_arm64_hash
    local desktop_linux_amd64_hash
    
    linux_x64_hash=$(get_asset_hash "$release" "opencode-linux-x64.tar.gz")
    linux_arm64_hash=$(get_asset_hash "$release" "opencode-linux-arm64.tar.gz")
    darwin_x64_hash=$(get_asset_hash "$release" "opencode-darwin-x64.zip")
    darwin_arm64_hash=$(get_asset_hash "$release" "opencode-darwin-arm64.zip")
    desktop_linux_amd64_hash=$(get_asset_hash "$release" "opencode-desktop-linux-amd64.deb")
    
    echo ""
    echo "Linux x64:    $linux_x64_hash"
    echo "Linux arm64:  $linux_arm64_hash"
    echo "Darwin x64:   $darwin_x64_hash"
    echo "Darwin arm64: $darwin_arm64_hash"
    echo "Desktop deb:  $desktop_linux_amd64_hash"
    
    echo ""
    update_nix_files "$latest_version" "$linux_x64_hash" "$linux_arm64_hash" "$darwin_x64_hash" "$darwin_arm64_hash" "$desktop_linux_amd64_hash"
    
    echo ""
    echo -e "${YELLOW}Changes made to ${OPENCODE_NIX} and ${OPENCODE_DESKTOP_NIX}${NC}"
    echo "Review the changes with: git diff"
    echo "Then commit with: git commit -m 'Update opencode to v${latest_version}'"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
