#!/bin/bash
# Apply patches to MLX for v0.26.0 compatibility
# This script is idempotent - safe to run multiple times

set -e  # Exit on error

echo "🔧 Checking MLX v0.26.0 compatibility patches..."

# Check if we're in the right directory
if [ ! -d "Source/Cmlx/mlx" ]; then
    echo "❌ Error: Source/Cmlx/mlx directory not found!"
    echo "   Please run this script from the mlx-swift root directory"
    exit 1
fi

# Function to apply RandomBits patch
apply_randombits_patch() {
    local cpp_file="Source/Cmlx/mlx/mlx/primitives.cpp"
    local h_file="Source/Cmlx/mlx/mlx/primitives.h"
    
    # Check if patch is already applied
    if grep -q "RandomBits::output_shapes" "$cpp_file" 2>/dev/null; then
        echo "✅ RandomBits::output_shapes patch already applied"
        return 0
    fi
    
    echo "📝 Applying RandomBits::output_shapes patch..."
    
    # Create temporary files for atomic replacement
    local cpp_tmp="${cpp_file}.tmp"
    local h_tmp="${h_file}.tmp"
    
    # Patch the .cpp file - insert after is_equivalent method
    awk '
    /^bool RandomBits::is_equivalent.*{$/ { found=1 }
    found && /^}$/ {
        print $0
        print ""
        print "std::vector<Shape> RandomBits::output_shapes("
        print "    const std::vector<array>& inputs) {"
        print "  return {shape_};"
        print "}"
        found=0
        next
    }
    { print }
    ' "$cpp_file" > "$cpp_tmp"
    
    # Patch the .h file - add declaration after is_equivalent
    sed '/bool is_equivalent(const Primitive& other) const override;/a\
  std::vector<Shape> output_shapes(const std::vector<array>&) override;' "$h_file" > "$h_tmp"
    
    # Verify patches were applied correctly
    if grep -q "RandomBits::output_shapes" "$cpp_tmp" && \
       grep -q "output_shapes.*override" "$h_tmp"; then
        mv "$cpp_tmp" "$cpp_file"
        mv "$h_tmp" "$h_file"
        echo "✅ RandomBits patch applied successfully!"
    else
        rm -f "$cpp_tmp" "$h_tmp"
        echo "❌ Failed to apply RandomBits patch"
        exit 1
    fi
}

# Apply all patches
apply_randombits_patch

echo "✨ All patches checked/applied successfully!"
echo "   You can now build the project."