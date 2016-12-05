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
            Vertex(position: [0, 1, 0, 1], color: [1, 1, 0, 1]),
            Vertex(position: [-1, -1, 0, 1], color: [1, 0, 1, 1]),
            Vertex(position: [1, -1, 0, 1], color: [0, 1, 1, 1]),
            ]
        
        let vertexBufferLength = vertices.count * MemoryLayout<Vertex>.size
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
            colorAttachment?.clearColor = MTLClearColorMake(1, 0, 0, 1)
            
            // CommandBufferを生成、三角形を描く
            let commandBuffer = commandQueue.makeCommandBuffer()
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            renderEncoder.setRenderPipelineState(piplineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            renderEncoder.endEncoding()
            
            // Present
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }

}
