import Cmlx

extension MLXArray {
    /// Get dimension size without forcing synchronization
    /// This is computed lazily on GPU when needed
    public func dim(_ axis: Int) -> Int {
        let actualAxis = axis < 0 ? ndim + axis : axis
        return shape[actualAxis]
    }
}
