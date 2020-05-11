//
//  HelperScene.swift
//  Stick Hero
//
//  Created by Jack Ily on 28/11/2019.
//  Copyright © 2019 Jack Ily. All rights reserved.
//

import SpriteKit
import AVFoundation

class HelperScene: SKScene {
    
    //MARK: - Properties
    
    var video: SKVideoNode!
    var playNode: SKSpriteNode!
    
    let clickSound = SKAction.playSoundFileNamed("button.wav", wait: false)
    
    //MARK: - Systems
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        createdVideo()
        createdPlay()
        createdTopNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if playNode.alpha == 1.0 {
            if node.name == ChildName.Clicker {
                video.pause()
                
                if SKAction.effectEnabled {
                    self.run(self.clickSound) {
                        self.setupPresent()
                    }
                    
                } else {
                    self.setupPresent()
                }
            }
        }
    }
}

//MARK: - Configurations

extension HelperScene {
    
    func createdVideo() {
        guard let url = Bundle.main.url(forResource: "helper-video.mov", withExtension: nil) else { return }
        let player = AVPlayer(url: url)
        video = SKVideoNode(avPlayer: player)
        video.zPosition = -1.0
        video.position = CGPoint(x: frame.width/2.0, y: frame.height/2.0 + 300.0)
        addChild(video)
        
        run(.sequence([
            .wait(forDuration: 0.3),
            .run { [unowned self] in
                self.video.play()
            }
        ]))
    }
    
    func createdPlay() {
        playNode = SKSpriteNode(imageNamed: "letPlay")
        playNode.name = ChildName.Clicker
        playNode.anchorPoint = .zero
        playNode.setScale(0.5)
        playNode.zPosition = 1.0
        playNode.position = CGPoint(x: frame.midX - 150.0, y: 150.0)
        playNode.alpha = 0.5
        addChild(playNode)
        
        run(.sequence([
            .wait(forDuration: 5.0),
            .run { [unowned self] in
                self.playNode.run(.fadeAlpha(to: 1.0, duration: 0.1))
            }
        ]))
    }
    
    func createdTopNode() {
        let topNode = SKShapeNode(rectOf: CGSize(width: screenWidth, height: screenHeight * 0.3))
        topNode.position = CGPoint(x: screenWidth/2.0, y: screenHeight)
        topNode.strokeColor = .black
        topNode.fillColor = .black
        addChild(topNode)
        
        let topLbl = SKLabelNode(fontNamed: fontNamed)
        topLbl.text = "HOW TO PLAY?"
        topLbl.fontColor = .white
        topLbl.fontSize = 80.0
        topLbl.verticalAlignmentMode = .center
        topLbl.horizontalAlignmentMode = .center
        topLbl.position = CGPoint(x: frame.midX,
                                  y: frame.height - topNode.frame.height/3.0 + topLbl.frame.height/2.0)
        addChild(topLbl)
    }
    
    func setupPresent() {
        let scene = MainMenu(size: size)
        scene.scaleMode = scaleMode
        view!.presentScene(scene, transition: .fade(withDuration: 0.5))
    }
}
