//
//  ViewController.swift
//  ElVacio
//
//  Created by Mac on 10/11/16.
//  Copyright © 2016 SrM. All rights reserved.
//

import UIKit
import Metal
import QuartzCore


class ViewController: UIViewController  {
    //        There are 7 steps to set up metal:
    //
    //        Create a MTLDevice
    //        Create a CAMetalLayer
    //        Create a Vertex Buffer
    //        Create a Vertex Shader
    //        Create a Fragment Shader
    //        Create a Render Pipeline
    //        Create a Command Queue
    
    var mtlDevice       : MTLDevice!              = nil
    var mtlLayer        : CAMetalLayer!           = nil
    var vertexData      : [Float]                 = []
    var vertexBuffer    : MTLBuffer!              = nil
    var pipelineState   : MTLRenderPipelineState! = nil
    var commandQueue    : MTLCommandQueue!        = nil
    var renderTimer     : CADisplayLink!          = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Device
        mtlDevice = MTLCreateSystemDefaultDevice()
        
        // Layer
        mtlLayer                 = CAMetalLayer()
        mtlLayer.device          = mtlDevice
        mtlLayer.pixelFormat     = .bgra8Unorm
        mtlLayer.framebufferOnly = true
        mtlLayer.frame           = view.layer.frame

        // Vertex Data (coordinates) [ x0, y0, z0 , x1, y1, z1 ... ]
        vertexData = [ 0.0,  1.0, 0.0,
                      -1.0, -1.0, 0.0,
                       1.0, -1.0, 0.0]
        
        // Vertex Buffer
        let vertexDataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = mtlDevice.makeBuffer(bytes: vertexData, length: vertexDataSize, options: MTLResourceOptions.storageModeShared)
        
        
        // Render PipeLine
        let defaultShadersLibrary = mtlDevice.newDefaultLibrary()
        let vertexProgram         = defaultShadersLibrary!.makeFunction(name:"basic_vertex")  // defined in Shaders.metal
        let fragmentProgram       = defaultShadersLibrary!.makeFunction(name:"basic_fragment")
        
        let pipelineDescriptor                             = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction                  = vertexProgram
        pipelineDescriptor.fragmentFunction                = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
        pipelineState = try! mtlDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        if( pipelineState != nil ){ print("no funciona") }
        
    
        // Command Queue
        commandQueue = mtlDevice.makeCommandQueue()
        
        // Render Timere
        renderTimer = CADisplayLink(target: self, selector: #selector(ViewController.playLoop))
        renderTimer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
        
        
        //view
        view.layer.addSublayer(mtlLayer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func render() {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture    = mtlLayer.nextDrawable()?.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        
        let commandBuffer    = commandQueue.makeCommandBuffer()
        let renderEncoderOpt = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        let renderEncoder    = renderEncoderOpt
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            renderEncoder.endEncoding()
        
        commandBuffer.present(mtlLayer.nextDrawable()!)
        commandBuffer.commit()
    }

    func playLoop() {
        autoreleasepool {
            self.render()
            
        }
    }

}

