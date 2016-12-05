//
//  MetalView.swift
//  MetalXmas
//
//  Created by takopom on 2016/12/05.
//  Copyright © 2016年 takopom. All rights reserved.
//

import UIKit
import MetalKit

class MetalView: MTKView {

    // MARK: Properties
    private var vertexBuffer: MTLBuffer!
    
    private var piplineState: MTLRenderPipelineState!
    
    private var commandQueue: MTLCommandQueue!
    
    private var vertexCount: Int = 0
    
    
    // MARK: Methods
    init(frame: CGRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        setupMetal()
    }
    
    required init(coder: NSCoder) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), device: MTLCreateSystemDefaultDevice())
        setupMetal()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        render()
    }    
    
    private func setupMetal() {
        
        // Metal Device を作る
        let device = MTLCreateSystemDefaultDevice()!
        self.device = device
        
        // Vertex Buffer を作る
        let vertices = [
            // 上段
            Vertex(position: [     0,  0.5, 0, 1], color: [143/255, 195/255, 31/255, 1]),
            Vertex(position: [-0.375, 0.25, 0, 1], color: [ 34/255, 172/255, 56/255, 1]),
            Vertex(position: [ 0.375, 0.25, 0, 1], color: [ 34/255, 172/255, 56/255, 1]),
            // 下段
            Vertex(position: [-0.25,  0.25, 0, 1], color: [34/255, 172/255, 56/255, 1]),
            Vertex(position: [ -0.5,     0, 0, 1], color: [ 0/255, 113/255, 48/255, 1]),
            Vertex(position: [    0,     0, 0, 1], color: [ 0/255, 113/255, 48/255, 1]),
            Vertex(position: [-0.25,  0.25, 0, 1], color: [34/255, 172/255, 56/255, 1]),
            Vertex(position: [    0,     0, 0, 1], color: [ 0/255, 113/255, 48/255, 1]),
            Vertex(position: [ 0.25,  0.25, 0, 1], color: [34/255, 172/255, 56/255, 1]),
            Vertex(position: [ 0.25,  0.25, 0, 1], color: [34/255, 172/255, 56/255, 1]),
            Vertex(position: [    0,     0, 0, 1], color: [ 0/255, 113/255, 48/255, 1]),
            Vertex(position: [  0.5,     0, 0, 1], color: [ 0/255, 113/255, 48/255, 1]),
            // 幹
            Vertex(position: [-0.125,     0, 0, 1], color: [168/255,  66/255, 0/255, 1]),
            Vertex(position: [-0.125, -0.25, 0, 1], color: [172/255, 106/255, 0/255, 1]),
            Vertex(position: [ 0.125,     0, 0, 1], color: [168/255,  66/255, 0/255, 1]),
            Vertex(position: [ 0.125,     0, 0, 1], color: [168/255,  66/255, 0/255, 1]),
            Vertex(position: [-0.125, -0.25, 0, 1], color: [172/255, 106/255, 0/255, 1]),
            Vertex(position: [ 0.125, -0.25, 0, 1], color: [172/255, 106/255, 0/255, 1]),
        ]
        
        vertexCount = vertices.count
        let vertexBufferLength = vertexCount * MemoryLayout<Vertex>.size
        vertexBuffer = device.makeBuffer(bytes: UnsafeRawPointer(vertices), length: vertexBufferLength, options: .optionCPUCacheModeWriteCombined)
        
        // Vertex shader, Fragment shader を指定する
        let defaultLibrary = device.newDefaultLibrary()
        let vertexFunction = defaultLibrary?.makeFunction(name: "basic_vertex")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "basic_fragment")
        
        let piplineDescriptor = MTLRenderPipelineDescriptor()
        piplineDescriptor.vertexFunction = vertexFunction
        piplineDescriptor.fragmentFunction = fragmentFunction
        
        // Color/Alphaのblendingを指定
        // （一般的なアルファブレンド）
        let colorAttachment = piplineDescriptor.colorAttachments[0]
        colorAttachment?.pixelFormat = .bgra8Unorm
        colorAttachment?.isBlendingEnabled = true
        colorAttachment?.rgbBlendOperation = .add
        colorAttachment?.alphaBlendOperation = .add
        colorAttachment?.sourceRGBBlendFactor = .sourceAlpha
        colorAttachment?.sourceAlphaBlendFactor = .sourceAlpha
        colorAttachment?.destinationRGBBlendFactor = .oneMinusSourceAlpha
        colorAttachment?.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Render pipline を作る
        do {
            piplineState = try device.makeRenderPipelineState(descriptor: piplineDescriptor)
        } catch {
            print("unable to compile render pipline state")
            return
        }
        
        // Command Queue を作る
        commandQueue = device.makeCommandQueue()
    }
    
    private func render() {
        
        // Drawableを取得
        if let drawable = currentDrawable {
            
            // Clear colorを設定
            let renderPassDescriptor = MTLRenderPassDescriptor()
            let colorAttachment = renderPassDescriptor.colorAttachments[0]
            colorAttachment?.texture = drawable.texture
            colorAttachment?.loadAction = .clear
            colorAttachment?.clearColor = MTLClearColorMake(1, 1, 1, 1)
            
            // CommandBufferを生成、三角形を描く
            let commandBuffer = commandQueue.makeCommandBuffer()
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder.setRenderPipelineState(piplineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
            renderEncoder.endEncoding()
            
            // Present
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }

}
