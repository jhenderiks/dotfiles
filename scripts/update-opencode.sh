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

# GitHub API
API_URL="https://api.github.com/repos/anomalyco/opencode/releases/latest"

# Check dependencies
check_deps() {
    local missing=()
    for cmd in curl jq nix-prefetch-url; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Error: Missing required commands: ${missing[*]}${NC}"
        echo "Please install them: nix-shell -p curl jq nix-prefetch-url"
        exit 1
    fi
}

# Fetch latest release info
fetch_latest() {
    echo "Fetching latest release info..." >&2
    local response
    response=$(curl -s -H "Accept: application/vnd.github.v3+json" "$API_URL")
    
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
    grep -E '^\s+version\s*=\s*"[^"]+"' "$OPENCODE_NIX" | head -1 | sed 's/.*"\([^"]*\)".*/\1/'
}

# Compute hash for a URL
compute_hash() {
    local url="$1"
    echo "Computing hash for: $url" >&2
    
    # nix-prefetch-url outputs the base32 hash, convert to SRI format
    local hash
    hash=$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$hash" ]; then
        echo -e "${RED}Error: Failed to compute hash for $url${NC}" >&2
        return 1
    fi
    
    # Convert to SRI format
    local sri_hash
    sri_hash=$(nix --extra-experimental-features nix-command hash to-base64 --type sha256 "$hash" 2>/dev/null)
    
    echo "sha256-$sri_hash"
}

# Update the nix file
update_nix_file() {
    local version="$1"
    local linux_x64_hash="$2"
    local linux_arm64_hash="$3"
    local darwin_x64_hash="$4"
    local darwin_arm64_hash="$5"
    
    echo "Updating ${OPENCODE_NIX}..."
    
    # Create backup
    cp "$OPENCODE_NIX" "${OPENCODE_NIX}.backup"
    
    # Update version
    sed -i "s/version = \"[^\"]*\";/version = \"${version}\";/" "$OPENCODE_NIX"
    
    # Update hashes - using a more careful approach
    # Read the file, replace hashes in the sources attrset
    
    local temp_file
    temp_file=$(mktemp)
    
    # Use awk to replace hashes in the sources section
    awk -v lx="$linux_x64_hash" \
        -v la="$linux_arm64_hash" \
        -v dx="$darwin_x64_hash" \
        -v da="$darwin_arm64_hash" \
        '
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
    ' "$OPENCODE_NIX" > "$temp_file"
    
    mv "$temp_file" "$OPENCODE_NIX"
    rm -f "${OPENCODE_NIX}.backup"
    
    echo -e "${GREEN}Successfully updated opencode.nix to version ${version}${NC}"
}

# Main
main() {
    local check_only=false
    
    if [ "${1:-}" = "--check-only" ]; then
        check_only=true
    fi
    
    check_deps
    
    local current_version
    current_version=$(get_current_version)
    
    echo "Current version: $current_version"
    
    local latest_version
    latest_version=$(fetch_latest)
    
    echo "Latest version: $latest_version"
    
    if [ "$current_version" = "$latest_version" ]; then
        echo -e "${GREEN}Already up to date!${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}Update available: ${current_version} → ${latest_version}${NC}"
    
    if [ "$check_only" = true ]; then
        exit 0
    fi
    
    echo ""
    echo "Computing hashes for all platforms..."
    
    local base_url="https://github.com/anomalyco/opencode/releases/download/v${latest_version}"
    
    # Compute hashes
    local linux_x64_hash
    local linux_arm64_hash
    local darwin_x64_hash
    local darwin_arm64_hash
    
    linux_x64_hash=$(compute_hash "${base_url}/opencode-linux-x64.tar.gz")
    linux_arm64_hash=$(compute_hash "${base_url}/opencode-linux-arm64.tar.gz")
    darwin_x64_hash=$(compute_hash "${base_url}/opencode-darwin-x64.zip")
    darwin_arm64_hash=$(compute_hash "${base_url}/opencode-darwin-arm64.zip")
    
    echo ""
    echo "Linux x64:    $linux_x64_hash"
    echo "Linux arm64:  $linux_arm64_hash"
    echo "Darwin x64:   $darwin_x64_hash"
    echo "Darwin arm64: $darwin_arm64_hash"
    
    echo ""
    update_nix_file "$latest_version" "$linux_x64_hash" "$linux_arm64_hash" "$darwin_x64_hash" "$darwin_arm64_hash"
    
    echo ""
    echo -e "${YELLOW}Changes made to ${OPENCODE_NIX}${NC}"
    echo "Review the changes with: git diff"
    echo "Then commit with: git commit -m 'Update opencode to v${latest_version}'"
}

main "$@"
