//
//  GameScene.swift
//  Stick Hero
//
//  Created by Jack Ily on 22/11/2019.
//  Copyright © 2019 Jack Ily. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameScene: SKScene {
    
    //MARK: - GoogleMobileAds
    
    var bannerView: GADBannerView!
    var rewardedAd: GADRewardedAd!
    
    //MARK: - Properties
    
    var worldNode = SKNode()
    var hero = HeroNode()
    var leftStack = StackNode()
    var rightStack = StackNode()
    var stick: SKSpriteNode!
    var hud = HUD()
    var appleNode: AppleNode!
    
    var stackHeight: CGFloat = 500.0
    var stackMinWidth: CGFloat = 50.0
    var stackMaxWidth: CGFloat = 300.0
    var gapMinWidth: Int = 60
    var nextValueX: CGFloat = 0.0
    var stickHeight: CGFloat = 0.0
    var heroSpeed: CGFloat = 760.0
    
    var isBegin = false
    var isEnd = false
    var isMoveDown = false
    
    var stickNum = 0
    var leftStacks: [StackNode] = []
    
    var earnCount = 0
    var shared = GameManager.sharedInstance
    
    var currentScore: Int = 0 {
        willSet {
            hud.sceneScoreLbl.text = "\(newValue)"
            hud.sceneScoreLbl.run(.sequence([
                .scale(to: 1.5, duration: 0.1),
                .scale(to: 1.0, duration: 0.1)
            ]))
        }
    }
    
    var appleQuantity: Int32 = 0 {
        willSet {
            shared.setAppleQuantity(newValue)
            hud.appleLbl.text = "\(newValue)"
            
            if newValue != 0 {
                hud.appleLbl.run(.sequence([
                    .scale(to: 1.5, duration: 0.1),
                    .scale(to: 1.0, duration: 0.1)
                ]))
            }
        }
    }
    
    var gameState: GameState = .initial {
        didSet {
            hud.setupGameState(oldValue, to: gameState)
        }
    }
    
    var heroKickAnim: SKAction {
        var textures: [SKTexture] = []
        for i in 1...2 {
            textures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_kick\(i)"))
        }
        
        return SKAction.animate(with: textures, timePerFrame: 0.1, resize: true, restore: true)
    }
    
    var heroRunAnim: SKAction {
        var textures: [SKTexture] = []
        textures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_1"))
        textures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_walk1"))
        textures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_3"))
        textures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_walk2"))
        
        let animate = SKAction.animate(with: textures, timePerFrame: 0.25, resize: true, restore: true)
        return SKAction.repeatForever(animate)
    }
    
    var playableRect: CGRect {
        let ratio: CGFloat
        
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        
        let playableWidth = size.height / ratio
        let playableMargin = (size.width - playableWidth) / 2.0
        
        return CGRect(x: playableMargin, y: 0.0, width: playableWidth, height: size.height)
    }
    
    let growSound = SKAction.playSoundFileNamed("stick_grow_loop.wav", wait: true)
    let fallSound = SKAction.playSoundFileNamed("fall.wav", wait: false)
    let victorySound = SKAction.playSoundFileNamed("victory.wav", wait: false)
    let highscoreSound = SKAction.playSoundFileNamed("highScore.wav", wait: false)
    let kickSound = SKAction.playSoundFileNamed("kick.wav", wait: false)
    let perfectSound = SKAction.playSoundFileNamed("touch_mid.wav", wait: false)
    let deadSound = SKAction.playSoundFileNamed("dead.wav", wait: false)
    let appleSound = SKAction.playSoundFileNamed("apple.mp3", wait: false)
    let collisionSound = SKAction.playSoundFileNamed("collision.wav", wait: false)
    let clickSound = SKAction.playSoundFileNamed("button.wav", wait: false)
    
    //MARK: - Systems
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupNodes()
        setupBannerView()
        rewardedAd = crearedRewardedAd()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard gameState != .dead else {
            guard let touch = touches.first else { return }
            let node = atPoint(touch.location(in: self))
            
            if node.name == HUDSettings.Share {
                if SKAction.effectEnabled { run(clickSound) }
                
                let image = UIImage(named: "1024x1024")!
                let items: [Any] = ["Stick Hero", image, "link download"]
                let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
                activity.popoverPresentationController?.sourceView = view
                let vc = view!.window!.rootViewController!
                vc.present(activity, animated: true, completion: nil)
                
            } else if node.name == HUDSettings.Reload {
                bannerView.removeFromSuperview()
                
                if SKAction.effectEnabled {
                    self.run(self.clickSound) {
                        let scene = GameScene(size: self.size)
                        self.presentScene(scene)
                    }
                    
                } else {
                    let scene = GameScene(size: size)
                    self.presentScene(scene)
                }
                
            } else if node.name == HUDSettings.Achievements {
                if SKAction.effectEnabled { run(clickSound) }
                print("Achievements")
                
            } else if node.name == HUDSettings.Home {
                bannerView.removeFromSuperview()
                
                if SKAction.effectEnabled {
                    self.run(self.clickSound) {
                        let scene = MainMenu(size: self.size)
                        self.presentScene(scene)
                    }
                    
                } else {
                    let scene = MainMenu(size: self.size)
                    self.presentScene(scene)
                }
                
            } else if node.name == HUDSettings.Earn {
                let share = hud.bgGameOver.childNode(withName: HUDSettings.Earn) as! SKSpriteNode
                if share.alpha != 0.5 {
                    if rewardedAd.isReady {
                        rewardedAd.present(fromRootViewController: view!.window!.rootViewController!, delegate: self)
                    }
                }
            }
            
            return
        }
        
        if !isBegin && !isEnd {
            isBegin = true
            stick = createdStickNode()

            let resizeAct = SKAction.resize(toHeight: screenHeight - stackHeight, duration: 1.5)
            stick.run(resizeAct, withKey: WithKey.StickResize)
            if SKAction.effectEnabled { stick.run(.repeatForever(growSound), withKey: AudioKey.Grow) }

            let scale = SKAction.sequence([
                .scaleY(to: CGFloat(0.9*0.35), duration: 0.05),
                .scaleY(to: CGFloat(1.0*0.35), duration: 0.05)
            ])

            hero.run(.repeatForever(scale), withKey: WithKey.HeroScale)
        }

        if isMoveDown {
            hero.setupMoveDown()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isBegin && !isEnd {
            isEnd = true
            
            hero.removeAction(forKey: WithKey.HeroScale)
            hero.run(.scaleY(to: 0.35, duration: 0.04))
            
            let rotateAct = SKAction.rotate(toAngle: CGFloat(-90).degreesToRadians(), duration: 0.4, shortestUnitArc: true)
            stick.removeAction(forKey: WithKey.StickResize)
            stick.removeAction(forKey: AudioKey.Grow)
            if SKAction.effectEnabled { stick.run(kickSound) }
            stickHeight = stick.frame.height
            hero.run(heroKickAnim, withKey: WithKey.HeroKickAnim)
            stick.run(.sequence([
                .wait(forDuration: 0.2),
                rotateAct
            ])) { [unowned self] in
                if SKAction.effectEnabled { self.stick.run(self.fallSound) }
                self.hero.removeAction(forKey: WithKey.HeroKickAnim)
                self.heroGo(self.checkPass())
            }
            
            let heroW = hero.frame.width/2.0
            let xUp1: CGFloat = leftStack.position.x + leftStack.frame.width/2.0 + heroW
            let yUp: CGFloat = stackHeight + 20.0
            
            let shapeUp1 = createdShapeMoveDown(CGPoint(x: xUp1, y: yUp))
            shapeUp1.physicsBody!.categoryBitMask = PhysicsCategory.MoveDown
            worldNode.addChild(shapeUp1)
            
            let xUp2: CGFloat = rightStack.position.x - rightStack.frame.width/2.0 - heroW
            let shapeUp2 = createdShapeMoveDown(CGPoint(x: xUp2, y: yUp))
            shapeUp2.physicsBody!.categoryBitMask = PhysicsCategory.MoveUp
            worldNode.addChild(shapeUp2)
            
            let yDown: CGFloat = stackHeight - 20.0
            let shapeDown1 = createdShapeMoveDown(CGPoint(x: xUp1, y: yDown))
            shapeDown1.physicsBody!.categoryBitMask = PhysicsCategory.MoveDown
            worldNode.addChild(shapeDown1)
            
            let shapeDown2 = createdShapeMoveDown(CGPoint(x: xUp2, y: yDown))
            shapeDown2.physicsBody!.categoryBitMask = PhysicsCategory.MoveUp
            worldNode.addChild(shapeDown2)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState == .dead { worldNode.isPaused = true; return }
    }
}

//MARK: - Configurations

extension GameScene {
    
    func setupNodes() {
        if gameState == .initial {
            addChild(worldNode)
//            drawPlayableArea()
            createdBackground()
            leftStack = createdStacks(false, xPos: playableRect.minX)
            removeMidStack(true, left: true)
            createdHero()
            
            let maxGap = Int(playableRect.width - stackMaxWidth - leftStack.frame.width)
            let gap = CGFloat(Int.random(range: gapMinWidth...maxGap))
            rightStack = createdStacks(false, xPos: nextValueX + gap)
            
            createdObstacle()
            setupHUD()
            setupPhysics()
//            createdAppleNode(false)
            appleQuantity = shared.getAppleQuantity()
            
            earnCount = shared.getRewardedLoaded()
            earnCount += 1
            shared.setRewardedLoaded(earnCount)
            
            gameState = .start
        }
    }
    
    func drawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.lineWidth = 4.0
        shape.strokeColor = .red
        shape.zPosition = 50.0
        worldNode.addChild(shape)
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -100.0)
        physicsWorld.contactDelegate = self
    }
    
    func setupHUD() {
        addChild(hud)
        hud.createdScoreLbl(currentScore)
        hud.createdAppleLbl(shared.getAppleQuantity())
        hud.createdNotification()
        
        hud.notiLbl.run(.sequence([
            .wait(forDuration: 0.5),
            .fadeAlpha(to: 1.0, duration: 0.5)
        ]))
    }
}

//MARK: - Background

extension GameScene {
    
    func createdBackground() {
        for i in 0...2 {
            let bg = setupBackground()
            bg.zPosition = -1.0
            bg.name = ChildName.Background
            bg.position = CGPoint(x: CGFloat(i)*bg.frame.width, y: 0.0)
            worldNode.addChild(bg)
        }
    }
    
    func setupBackground() -> SKSpriteNode {
        let bg = SKSpriteNode()
        bg.anchorPoint = .zero
        bg.name = ChildName.Background
        
        let i = Int.random(range: 1...5)
        let bg1 = SKSpriteNode(imageNamed: "bg\(i)_1")
        bg1.anchorPoint = .zero
        bg1.position = .zero
        bg.addChild(bg1)
        
        let bg2 = SKSpriteNode(imageNamed: "bg\(i)_2")
        bg2.anchorPoint = .zero
        bg2.position = CGPoint(x: bg1.frame.width, y: 0.0)
        bg.addChild(bg2)
        
        let bg3 = SKSpriteNode(imageNamed: "bg\(i)_3")
        bg3.anchorPoint = .zero
        bg3.position = CGPoint(x: bg1.frame.width*2.0, y: 0.0)
        bg.addChild(bg3)
        
        bg.size = CGSize(width: bg1.frame.width*3, height: bg1.frame.height)
        return bg
    }
}

//MARK: - Setup Hero

extension GameScene {
    
    func createdHero() {
//        let x: CGFloat
//        if leftStack.frame.width <= 70.0 {
//            x = nextValueX - hero.frame.width/2.0 + 5.0
//
//        } else {
//            x = nextValueX - hero.frame.width/2.0 - 14.0
//        }
        
        let x = leftStack.position.x - 15.0
        let y: CGFloat = stackHeight + hero.frame.height/2.0 - 2.0
        hero.position = CGPoint(x: x, y: y)
        worldNode.addChild(hero)
    }
    
    func heroGo(_ checkPass: Bool) {
        guard checkPass else {
            let dis = stick.position.x + stickHeight
            let gap = nextValueX - rightStack.frame.width/2.0 - abs(hero.position.x)
            let duration = TimeInterval(gap/heroSpeed)
            let moveAct = SKAction.moveTo(x: dis, duration: duration)
            hero.removeAction(forKey: WithKey.HeroAnim)
            hero.run(heroRunAnim, withKey: WithKey.HeroRunAnim)
            hero.run(moveAct) { [unowned self] in
                self.stick.run(.rotate(toAngle: CGFloat(-180.0).degreesToRadians(), duration: 0.3))
                self.hero.removeAction(forKey: WithKey.HeroRunAnim)
                self.hero.physicsBody!.affectedByGravity = true
                self.hero.physicsBody!.collisionBitMask = PhysicsCategory.None
                self.hero.physicsBody!.contactTestBitMask = PhysicsCategory.None
                
                if SKAction.effectEnabled { self.hero.run(self.deadSound) }
                
                self.hud.notiLbl.run(.sequence([
                    .fadeAlpha(to: 0.0, duration: 0.2),
                    .removeFromParent()
                ]))
                
                self.removeObstacle()
                
                let amount = CGPoint(x: 0.0, y: 10.0)
                self.worldNode.run(.screenShakeWithNode(self.worldNode, amount: amount, oscillations: 5, duration: 0.3))
                self.run(.wait(forDuration: 0.5)) { [unowned self] in
                    self.hero.removeFromParent()
                    if self.shared.getRewardedLoaded() >= 5 {
                        self.hud.isEarn = true
                        
                    } else {
                        self.hud.isEarn = false
                    }
                    
                    self.gameState = .dead
                    self.setupScore()
                }

                self.removeAppleNode()
                self.removeShapeMoveDown()
            }
            
            return
        }
        
        let dis: CGFloat = nextValueX - hero.frame.width/2.0 - 14.0
        let gap = nextValueX - rightStack.frame.width/2.0 - abs(hero.position.x)
        let duration = TimeInterval(gap/heroSpeed)
        let moveAct = SKAction.moveTo(x: dis, duration: duration)
        hero.removeAction(forKey: WithKey.HeroAnim)
        hero.run(heroRunAnim, withKey: WithKey.HeroRunAnim)
        hero.run(moveAct) { [unowned self] in
            self.removeObstacle()
            self.hero.removeAction(forKey: WithKey.HeroRunAnim)
            self.hero.run(self.hero.heroAnim(), withKey: WithKey.HeroAnim)
            self.moveAndCreateNewStack()
            self.currentScore += 1
            
            self.hud.notiLbl.run(.sequence([
                .wait(forDuration: 0.5),
                .fadeAlpha(to: 0.0, duration: 0.5)
            ]))
            
            if SKAction.effectEnabled { self.hero.run(self.victorySound) }
        }
    }
    
    func checkPass() -> Bool {
        guard stick.position.x + stickHeight < nextValueX else { return false }
        guard leftStack.frame.intersects(stick.frame) &&
            rightStack.frame.intersects(stick.frame) else { return false }
        checkMidStack()
        return true
    }
}

//MARK: - Created Stack

extension GameScene {
    
    //TODO: - Stacks
    func createdStacks(_ animation: Bool, xPos: CGFloat) -> StackNode {
        let min = Int(stackMinWidth/10)
        let max = Int(stackMaxWidth/10)
        let width = CGFloat(Int.random(range: min...max)) * 10.0
        let size = CGSize(width: width, height: stackHeight)
        let stack = StackNode(rectOf: size)
        
        if animation {
            stack.position = CGPoint(x: screenWidth, y: stackHeight/2.0)
            
            let moveAct = SKAction.moveTo(x: xPos + width/2.0, duration: 0.3)
            stack.run(moveAct) { [unowned self] in
                self.createdObstacle()
                self.isBegin = false
                self.isEnd = false
                self.isMoveDown = false
                self.spawnAppleNode()
            }
            
        } else {
            stack.position = CGPoint(x: xPos + width/2.0, y: stackHeight/2.0)
        }
        
        createdMidStack(stack)
        nextValueX = xPos + width
        worldNode.addChild(stack)
        return stack
    }
    
    //TODO: - MidStack
    func createdMidStack(_ stack: StackNode) {
        let shape = SKShapeNode(circleOfRadius: 10.0)
        shape.strokeColor = .red
        shape.fillColor = .red
        shape.name = ChildName.MidStack
        let y: CGFloat = stack.frame.height/2.0 - shape.frame.height/2.0
        shape.position = CGPoint(x: 0.0, y: y)
        stack.addChild(shape)
    }
    
    func removeMidStack(_ animate: Bool, left: Bool) {
        let stack = left ? leftStack : rightStack
        let midStack = stack.childNode(withName: ChildName.MidStack) as! SKShapeNode
        
        if animate {
            midStack.alpha = 0.0
            
        } else {
            midStack.removeFromParent()
        }
    }
    
    func checkMidStack() {
        let dis = stick.position.x + stickHeight
        let midStack = rightStack.childNode(withName: ChildName.MidStack) as! SKShapeNode
        let newPoint = midStack.convert(CGPoint(x: -10.0, y: 10.0), to: self)
        
        if dis >= newPoint.x && dis <= newPoint.x  + 20.0 {
            loadPerfect()
            if SKAction.effectEnabled { run(perfectSound) }
            currentScore += 1
        }
    }
    
    func moveAndCreateNewStack() {
        let xRight = playableRect.minX + rightStack.frame.width/2.0 - 4.0
        let moveRightAct = SKAction.moveTo(x: xRight, duration: 0.5)
        rightStack.run(moveRightAct) { [unowned self] in
            if self.stickNum == 2 {
                for child in self.worldNode.children {
                    if child.name == "Stick1" {
                        child.removeFromParent()
                    }
                }
            }
        }
        
        worldNode.enumerateChildNodes(withName: ChildName.Background) { (node, _) in
            let bg = node as! SKSpriteNode
            bg.run(.moveBy(x: -100.0, y: 0.0, duration: 0.6))

            if bg.position.x + bg.frame.width < -self.frame.width {
                bg.position.x += bg.position.x + bg.frame.width*3
            }
        }
        
        let xHero = playableRect.minX + rightStack.frame.width - hero.frame.width/2.0 - 16.0
        let moveHeroAct = SKAction.moveTo(x: xHero, duration: 0.5)
        hero.run(moveHeroAct)
        removeMidStack(true, left: false)
        removeShapeMoveDown()
        
        let stickX = -stickHeight + playableRect.minX + 10.0
        stick.run(.moveTo(x: stickX, duration: 0.5)) { [unowned self] in
            if self.stickNum == 2 {
                self.stickNum = 1
                self.stick.name = "Stick\(self.stickNum)"
            }
        }
        
        self.removeAppleNode()
        
        if self.leftStacks.count != 0 {
            self.leftStacks[0].run(.moveTo(x: -self.leftStacks[0].frame.width, duration: 0.3)) {
                self.leftStacks[0].removeFromParent()
            }
        }
        
        let leftX: CGFloat
        switch leftStack.frame.width {
        case 0...100: leftX = leftStack.frame.width/2.0
        default: leftX = 0; break
        }
        
        leftStack.run(.moveTo(x: leftX, duration: 0.6)) { [unowned self] in
            self.leftStacks.removeAll()
            self.leftStacks.append(self.leftStack.copy() as! StackNode)
            self.leftStacks[0] = StackNode(rectOf: self.leftStack.frame.size)
            self.leftStacks[0].position = self.leftStack.position
            self.worldNode.addChild(self.leftStacks[0])
            self.leftStack.removeFromParent()
            self.leftStack = self.rightStack
            
            let rightW = self.rightStack.frame.width
            let maxGap = Int(self.playableRect.width - rightW - self.stackMaxWidth)
            let gap = CGFloat(Int.random(range: self.gapMinWidth...maxGap))
            let xPos = self.playableRect.minX + rightW + gap
            self.rightStack = self.createdStacks(true, xPos: xPos)
        }
    }
}

//MARK: - StickNode

extension GameScene {
    
    func createdStickNode() -> SKSpriteNode {
        let stick = SKSpriteNode(texture: nil, color: .black, size: CGSize(width: 12.0, height: 1.0))
        stickNum += 1
        stick.zPosition = 5.0
        stick.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        stick.name = "Stick\(stickNum)"
        
        let x: CGFloat = leftStack.position.x + leftStack.frame.width/2.0 - 10.0
        let y: CGFloat = hero.position.y - hero.frame.height/2.0
        stick.position = CGPoint(x: x, y: y)
        worldNode.addChild(stick)
        return stick
    }
}

//MARK: - Obstacle

extension GameScene {
    
    func createdObstacle() {
        let obstacle = Obstacle()
        let x = rightStack.position.x - rightStack.frame.width/2.0 + obstacle.frame.width/2.0
        obstacle.position = CGPoint(x: x, y: rightStack.position.y)
        worldNode.addChild(obstacle)
    }
    
    func removeObstacle() {
        if let obstacle = worldNode.childNode(withName: ChildName.Obstacle) as? Obstacle {
            obstacle.physicsBody = nil
            obstacle.removeFromParent()
        }
    }
}

//MARK: - Perfect

extension GameScene {
    
    func loadPerfect() {
        defer {
            let label = worldNode.childNode(withName: ChildName.Perfect) as! SKLabelNode
            let fade = SKAction.sequence([
                .fadeAlpha(to: 1.0, duration: 0.3),
                .fadeAlpha(to: 0.0, duration: 0.3)
            ])
            
            let scale = SKAction.sequence([
                .scale(to: 1.4, duration: 0.3),
                .scale(to: 1.0, duration: 0.3)
            ])
            
            let sequence = SKAction.sequence([.group([scale, fade]), .removeFromParent()])
            label.run(sequence)
        }
        
        guard let _ = worldNode.childNode(withName: ChildName.Perfect) else {
            let pos = CGPoint(x: frame.midX, y: frame.midY)
            let label = SKLabelNode(fontNamed: fontNamed)
            label.name = ChildName.Perfect
            label.zPosition = 100.0
            label.fontSize = 70.0
            label.fontColor = UIColor(hex: 0xC8372D)
            label.text = "Perfect"
            label.position = pos
            worldNode.addChild(label)
            return
        }
    }
}

//MARK: - Move Up-Down

extension GameScene {
    
    func createdShapeMoveDown(_ pos: CGPoint) -> SKShapeNode {
        let shape = SKShapeNode(rectOf: CGSize(width: 20.0, height: 20.0))
        shape.name = ChildName.UpDown
        shape.strokeColor = .clear
        shape.fillColor = .clear
        shape.position = pos
        shape.physicsBody = SKPhysicsBody(rectangleOf: shape.frame.size)
        shape.physicsBody!.isDynamic = false
        shape.physicsBody!.affectedByGravity = false
        shape.physicsBody!.collisionBitMask = PhysicsCategory.None
        shape.physicsBody!.contactTestBitMask = PhysicsCategory.Hero
        return shape
    }
    
    func removeShapeMoveDown() {
        worldNode.enumerateChildNodes(withName: ChildName.UpDown) { (node, _) in
            node.removeFromParent()
        }
    }
}

//MARK: - AppleNode

extension GameScene {
    
    func spawnAppleNode() {
        switch Int.random(100) {
        case 0...80: break
        default: createdAppleNode(true); break
        }
    }
    
    func createdAppleNode(_ animation: Bool) {
        let scale: CGFloat
        if arc4random_uniform(2) == 0 {
            scale = 1.0
            
        } else {
            scale = -1.0
        }
        
        appleNode = AppleNode()
        
        let min: CGFloat = leftStack.position.x + leftStack.frame.width/2.0 + 30.0
        let max: CGFloat = rightStack.position.x - rightStack.frame.width/2.0 - 30.0
        let x: CGFloat = CGFloat.random(min: min, max: max)
        let y: CGFloat = stackHeight + (hero.frame.height/2.0 * scale)
        
        if animation {
            appleNode.position = CGPoint(x: screenWidth, y: y)
            appleNode.alpha = 0.0
            appleNode.run(.group([.moveTo(x: x, duration: 0.3), .fadeAlpha(by: 1.0, duration: 0.3)]))
            
        } else {
            appleNode.position = CGPoint(x: x, y: y)
        }
        
        let fullMove = SKAction.sequence([
            .moveTo(y: appleNode.position.y + 8.0, duration: 1.0),
            .moveTo(y: appleNode.position.y - 8.0, duration: 1.0)
        ])
        
        let fullScale = SKAction.sequence([
            .scale(to: 1.1, duration: 0.25),
            .scale(to: 0.7, duration: 0.25)
        ])
        
        let repeatScale = SKAction.repeat(fullScale, count: 2)
        appleNode.run(.repeatForever(.sequence([fullMove, .wait(forDuration: 0.25), repeatScale])))
        
        appleNode.setupPhysics()
        worldNode.addChild(appleNode)
    }
    
    func removeAppleNode() {
        if let node = worldNode.childNode(withName: ChildName.Score) as? AppleNode {
            node.removeFromParent()
        }
    }
    
    func presentScene(_ scene: SKScene) {
        scene.scaleMode = self.scaleMode
        self.view!.presentScene(scene, transition: .fade(withDuration: 0.5))
    }
}

//MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Hero ?
            contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.Obstacle:
            if let node = other.node {
                if SKAction.effectEnabled {
                    hero.run(collisionSound) {
                        self.hero.removeAllActions()
                    }
                    
                } else {
                    hero.removeAllActions()
                }
                
                hero.physicsBody!.affectedByGravity = true
                hero.physicsBody!.collisionBitMask = PhysicsCategory.None
                hero.physicsBody!.contactTestBitMask = PhysicsCategory.None
                node.physicsBody = nil
                node.removeFromParent()
                run(.wait(forDuration: 0.5)) {
                    if self.shared.getRewardedLoaded() >= 5 {
                        self.hud.isEarn = true
                        
                    } else {
                        self.hud.isEarn = false
                    }
                    
                    self.gameState = .dead
                    self.setupScore()
                }
            }
        case PhysicsCategory.Apple:
            if let node = other.node as? AppleNode {
                node.removeFromParent()
                if SKAction.effectEnabled { run(appleSound) }
                appleQuantity += 1
            }
            
        case PhysicsCategory.MoveDown:
            if let node = other.node {
                node.removeFromParent()
                isMoveDown = true
            }
        case PhysicsCategory.MoveUp:
            if let node = other.node {
                node.removeFromParent()
                isMoveDown = false
            }
        default: break
        }
    }
    
    func setupScore() {
        let highscore = shared.getHighscore()
        if currentScore > highscore {
            shared.setHighscore(currentScore)
        }
        
        hud.currentScoreLbl.text = "\(currentScore)"
        hud.highscoreLbl.text = "\(shared.getHighscore())"
    }
}

//MARK: - GoogleMobileAds

extension GameScene {
    
    func setupBannerView() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            bannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
            
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        }
        
        bannerView.adUnitID = bannerID
        bannerView.rootViewController = view!.window!.rootViewController
        bannerView.delegate = self
        bannerView.load(GADRequest())
        addBannerViewToView(bannerView)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        let bannerW: CGFloat = bannerView.frame.width
        let bannerH: CGFloat = bannerView.frame.height
        view!.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.widthAnchor.constraint(equalToConstant: bannerW),
            bannerView.heightAnchor.constraint(equalToConstant: bannerH),
            bannerView.centerXAnchor.constraint(equalTo: view!.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view!.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func crearedRewardedAd() -> GADRewardedAd {
        let rewardedAd = GADRewardedAd(adUnitID: rewardID)
        rewardedAd.load(GADRequest()) { (error) in
            if let error = error {
                print("Ad error loaded: \(error.localizedDescription)")
                
            } else {
                print("Ad successfully loaded")
            }
        }
        
        return rewardedAd
    }
}

//MARK: - GADBannerViewDelegate

extension GameScene: GADBannerViewDelegate {
    
    //Ad request loaded an ad
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {}
    
    //Ad request failed
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {}
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {}
    
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {}
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {}
}

//MARK: - GADRewardedAdDelegate

extension GameScene: GADRewardedAdDelegate {
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        var quantity = shared.getAppleQuantity()
        quantity += reward.amount.int32Value - 5
        shared.setAppleQuantity(quantity)
        hud.isEarn = false
        earnCount = 0
        shared.setRewardedLoaded(earnCount)
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {}
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if hud.isEarn {
          self.rewardedAd = crearedRewardedAd()
        }
        
        let share = hud.bgGameOver.childNode(withName: HUDSettings.Earn) as! SKSpriteNode
        share.alpha = 0.5
        share.removeAllActions()
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        if hud.isEarn {
          self.rewardedAd = crearedRewardedAd()
        }
    }
}
