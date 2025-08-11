import Cmlx
import Foundation

/// Generate evenly spaced values within a given interval.
///
/// This is the GPU-native equivalent of Swift's range operators, avoiding CPU-GPU synchronization.
///
/// Example:
///
/// ```swift
/// // Generate [0, 1, 2, 3, 4]
/// let a = arange(5)
///
/// // Generate [2, 3, 4]
/// let b = arange(2, 5)
///
/// // Generate [0, 2, 4, 6, 8]
/// let c = arange(0, 10, 2)
///
/// // Use for indexing without shape access
/// let indices = arange(logprobs.dim(0))
/// let values = logprobs[indices, nextTokens]
/// ```
///
/// - Parameters:
///     - start: Starting value (inclusive)
///     - stop: Stopping value (exclusive)
///     - step: Increment between values
///     - dtype: Data type of output array
///     - stream: Stream or device to evaluate on
/// - Returns: Array of evenly spaced values
public func arange(
    _ start: Int,
    _ stop: Int,
    _ step: Int = 1,
    dtype: DType = .int32,
    stream: StreamOrDevice = .default
) -> MLXArray {
    var result = mlx_array_new()
    mlx_arange(&result, Double(start), Double(stop), Double(step), dtype.cmlxDtype, stream.ctx)
    return MLXArray(result)
}

/// Generate evenly spaced values from 0 to stop.
public func arange(
    _ stop: Int,
    dtype: DType = .int32,
    stream: StreamOrDevice = .default
) -> MLXArray {
    return arange(0, stop, 1, dtype: dtype, stream: stream)
}

/// Generate evenly spaced values with floating point parameters.
public func arange<T: BinaryFloatingPoint>(
    _ start: T,
    _ stop: T,
    _ step: T = 1.0,
    dtype: DType = .float32,
    stream: StreamOrDevice = .default
) -> MLXArray {
    var result = mlx_array_new()
    mlx_arange(&result, Double(start), Double(stop), Double(step), dtype.cmlxDtype, stream.ctx)
    return MLXArray(result)
}

/// Generate evenly spaced values from 0 to stop with floating point.
public func arange<T: BinaryFloatingPoint>(
    _ stop: T,
    dtype: DType = .float32,
    stream: StreamOrDevice = .default
) -> MLXArray {
    return arange(T(0), stop, T(1), dtype: dtype, stream: stream)
}
