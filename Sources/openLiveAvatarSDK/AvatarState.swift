import simd
public struct AvatarState: Codable {
    // Properties representing facial feature positions and movements.
    var eyeBlinkRight: Float
    var eyeBlinkLeft: Float
    var mouthFunnel: Float
    var jawOpen: Float
    var id: String
    var browInnerUp: Float
    var browOuterUpLeft: Float
    var browOuterUpRight: Float
    var eyeSquintLeft: Float
    var eyeSquintRight: Float
    var cheekPuff: Float
    var lookAtPoint : simd_float3
    var transform : simd_float4x4
}

extension simd_float4x4: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0,columns.1, columns.2, columns.3])
    }
}
