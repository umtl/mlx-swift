#!/bin/bash
# Apply patches to MLX for v0.26.0 compatibility

echo "Applying MLX v0.26.0 compatibility patches..."

# Check if we're in the right directory
if [ ! -d "Source/Cmlx/mlx" ]; then
    echo "Error: Source/Cmlx/mlx directory not found!"
    exit 1
fi

# Apply RandomBits patch
cd Source/Cmlx/mlx

# Check if patch is already applied
if grep -q "RandomBits::output_shapes" mlx/primitives.cpp; then
    echo "Patch already applied, skipping..."
else
    echo "Applying RandomBits::output_shapes patch..."
    
    # Add the output_shapes method implementation
    cat >> mlx/primitives.cpp << 'EOF'

// Patch for MLX v0.26.0 compatibility
std::vector<Shape> RandomBits::output_shapes(
    const std::vector<array>& inputs) {
  return {shape_};
}
EOF

    # Add the declaration to the header
    sed -i '' '/bool is_equivalent(const Primitive& other) const override;/a\
  std::vector<Shape> output_shapes(const std::vector<array>&) override;' mlx/primitives.h
    
    echo "Patch applied successfully!"
fi

cd ../../..