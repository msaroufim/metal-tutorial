//
//  main.swift
//  SquareApp
//
//  Created by Mark Saroufim on 2/8/24.
//

import Foundation
import Metal

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal is not supported on this device")
}
// Create a Command Queue
guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

// Load the Metal shader file
let defaultLibrary = device.makeDefaultLibrary()!

// Create the kernel function
let squareFunction = defaultLibrary.makeFunction(name: "squareVector")!

// Create a Compute Pipeline State
//Compute Pipeline State: Defines the GPU's execution state and the compute shader code to run.
let computePipelineState = try! device.makeComputePipelineState(function: squareFunction)

// Input data
let inputVector = (0..<10_00000).map { Float($0) }
let vectorSize = inputVector.count * MemoryLayout<Float>.size

// Create Metal buffers
let inputBuffer = device.makeBuffer(bytes: inputVector, length: vectorSize, options: [])
let outputBuffer = device.makeBuffer(length: vectorSize, options: [])

// Create a Command Buffer
//Command Buffer: Holds a sequence of commands (encoded using encoders) that the GPU will execute.
guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
    fatalError("Could not create command buffer or encoder")
}


// Set the compute pipeline state and buffers
//Compute Command Encoder: Records compute commands into the command buffer, specifying the compute pipeline state and how to execute it (e.g., resources to use and the number of threads).
computeCommandEncoder.setComputePipelineState(computePipelineState)
computeCommandEncoder.setBuffer(inputBuffer, offset: 0, index: 0)
computeCommandEncoder.setBuffer(outputBuffer, offset: 0, index: 1)

// Dispatch the compute kernel
let threadsPerGroup = MTLSize(width: 1, height: 1, depth: 1)
let numThreadgroups = MTLSize(width: inputVector.count, height: 1, depth: 1)
computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
computeCommandEncoder.endEncoding()

// Commit the command buffer and wait for completion
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

// Retrieve and print the output data
let data = Data(bytesNoCopy: outputBuffer!.contents(), count: vectorSize, deallocator: .none)
var outputVector = [Float](repeating: 0, count: inputVector.count)
outputVector.withUnsafeMutableBytes { bufferPointer in
    data.copyBytes(to: bufferPointer, count: vectorSize)
}
print("Output Vector: \(outputVector)")
