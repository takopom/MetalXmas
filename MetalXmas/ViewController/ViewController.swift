//
//  ViewController.swift
//  MetalXmas
//
//  Created by takopom on 2016/12/02.
//  Copyright © 2016年 takopom. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import QuartzCore

struct Vertex {
    var position: vector_float4
    var color: float4
}

class ViewController: UIViewController {

    // MARK: Properties
    private var device: MTLDevice!
    
    private var metalLayer: CAMetalLayer!
    
    private var vertexBuffer: MTLBuffer!
    
    private var piplineState: MTLRenderPipelineState!
    
    private var commandQueue: MTLCommandQueue!
    
    private var displayLink: CADisplayLink!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMetal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func delete(_ sender: Any?) {
        displayLink.invalidate()
        
        super.delete(sender)
    }

    private func setupMetal() {
        // Metal device を作る
        device = MTLCreateSystemDefaultDevice()
        
        // Metal Layer を作る
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
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
        colorAttachment?.sourceRGBBlendFactor = .sourceColor
        colorAttachment?.sourceAlphaBlendFactor = .sourceAlpha
        colorAttachment?.destinationRGBBlendFactor = .oneMinusSourceColor
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
        
        // Display Link を作る＆描画ループ設定
        displayLink = CADisplayLink.init(target: self, selector: #selector(mainLoop))
        displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
    }

    // 描画ループ
    func mainLoop() {
        autoreleasepool {
            self.render()
        }
    }
    
    // レンダリング
    private func render() {
        // Drawableを取得
        if let drawable = metalLayer.nextDrawable() {
            
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

