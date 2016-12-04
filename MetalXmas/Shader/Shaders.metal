//
//  Shaders.metal
//  MetalXmas
//
//  Created by takopom on 2016/12/02.
//  Copyright © 2016年 takopom. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    packed_float4 position;
    packed_float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

// Vertex shader
vertex VertexOut basic_vertex(constant Vertex *vertices [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    VertexOut out;
    out.position = vertices[vid].position;
    out.color = vertices[vid].color;
    return out;
}

// Fragment shader
fragment float4 basic_fragment(VertexOut v[[stage_in]]) {
    return v.color;
}
