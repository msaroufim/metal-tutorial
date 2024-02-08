//
//  Square.metal
//  SquareApp
//
//  Created by Mark Saroufim on 2/8/24.
//

#include <metal_stdlib>
using namespace metal;

kernel void squareVector(const device float *input [[buffer(0)]],
                         device float *output [[buffer(1)]],
                         uint id [[thread_position_in_grid]]) {
    output[id] = input[id] * input[id];
}
