//
//  MainMenu.swift
//  Stick Hero
//
//  Created by Jack Ily on 24/11/2019.
//  Copyright © 2019 Jack Ily. All rights reserved.
//

import SpriteKit
import GoogleMobileAds

class MainMenu: SKScene {
    
    //MARK: - Intersitital
    
    var interstitial: GADInterstitial!
    
    //MARK: - Properties
    
    var play: SKSpriteNode!
    var stack: SKShapeNode!
    var helper: SKSpriteNode!
    var sound: SKSpriteNode!
    var apple: SKSpriteNode!
    var character: SKSpriteNode!
    var hero: SKSpriteNode!
    let shared = GameManager.sharedInstance
    
    static var appleQuantityLbl = UILabel()
    static var kView = SetupView()
    static var product = SKProduct()
    
    var containerHeroesV = UIView()
    var containerCVC = UIView()
    var heroesCVC = HeroesCVC(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var isHiddenCV = false
    
    var clickSound = SKAction.playSoundFileNamed("button.wav", wait: false)
    
    private var isPlay = false
    private var isHelper = false
    private var isSound = false
    private var isApple = false
    private var isCharacter = false
    
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
    
    //MARK: - Systems
    
    override func didMove(to view: SKView) {
//        drawPlayableArea()
        createdBackground()
        createdStickHeroLbl()
        createdPlay()
        createdStack()
        createdHero()
        createdHelper()
        createdSound()
        createdApple()
        createdCharacter()
        createdInterstitial()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        guard !isHiddenCV else { return }
        
        if node.name == ChildName.Play {
            if !isPlay { setupBtnAct(play) { self.isPlay = true } }
            
        } else if node.name == ChildName.Helper {
            if !isHelper { setupBtnAct(helper) { self.isHelper = true } }
            
        } else if node.name == ChildName.Sound {
            if !isSound { setupBtnAct(sound) { self.isSound = true } }
            
        } else if node.name == ChildName.Apple {
            if !isApple { setupBtnAct(apple) { self.isApple = true } }
            
        } else if node.name == ChildName.Character {
            if !isCharacter { setupBtnAct(character) { self.isCharacter = true } }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isPlay {
            removeBtnAct(play, isBool: &isPlay) {
                self.setupPresent()
            }
        }
        
        if isHelper {
            removeBtnAct(helper, isBool: &isHelper) {
                let scene = HelperScene(size: self.size)
                scene.scaleMode = self.scaleMode
                self.view!.presentScene(scene)
            }
        }
        
        if isSound {
            removeBtnAct(sound, isBool: &isSound) {
                SKAction.effectEnabled = !SKAction.effectEnabled
                SKTAudio.enabled = !SKTAudio.enabled
                self.sound.texture = SKTexture(imageNamed: SKAction.effectEnabled ? "btn_sound" : "btn_mute")
                
                guard SKAction.effectEnabled else { return }
                self.clickSound = SKAction.playSoundFileNamed("button.wav", wait: false)
                self.run(self.clickSound)
            }
        }
        
        if isApple {
            removeBtnAct(apple, isBool: &isApple) {
                HeroesCVC.isShop = true
                self.setupCollectionView(self.view!, isShop: HeroesCVC.isShop)
            }
        }
        
        if isCharacter {
            removeBtnAct(character, isBool: &isCharacter) {
                HeroesCVC.isShop = false
                self.setupCollectionView(self.view!, isShop: HeroesCVC.isShop)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isPlay {
            let nodePos = play.position
            let nodeF = play.frame
            if location.x >= nodePos.x + nodeF.width || //Right
                location.x <= nodePos.x - nodeF.width || //Left
                location.y >= nodePos.y + nodeF.height || //Up
                location.y <= nodePos.y - nodeF.height { //Down
                handleTouchesMoved(play, isBool: &isPlay)
            }
        }
        
        if isSound {
            let nodePos = sound.position
            let nodeF = sound.frame
            if location.x >= nodePos.x + nodeF.width/2.0 || //Right
                location.x <= nodePos.x - nodeF.width/2.0 || //Left
                location.y >= nodePos.y + nodeF.height/2.0 || //Up
                location.y <= nodePos.y - nodeF.height/2.0 { //Down
                handleTouchesMoved(sound, isBool: &isSound)
            }
        }
        
        if isCharacter {
            let nodePos = character.position
            let nodeF = character.frame
            if location.x >= nodePos.x + nodeF.width/2.0 || //Right
                location.x <= nodePos.x - nodeF.width/2.0 || //Left
                location.y >= nodePos.y + nodeF.height/2.0 || //Up
                location.y <= nodePos.y - nodeF.height/2.0 { //Down
                handleTouchesMoved(character, isBool: &isCharacter)
            }
        }
        
        if isApple {
            let nodePos = apple.position
            let nodeF = apple.frame
            if location.x >= nodePos.x + nodeF.width/2.0 || //Right
                location.x <= nodePos.x - nodeF.width/2.0 || //Left
                location.y >= nodePos.y + nodeF.height/2.0 || //Up
                location.y <= nodePos.y - nodeF.height/2.0 { //Down
                handleTouchesMoved(apple, isBool: &isApple)
            }
        }
        
        if isHelper {
            let nodePos = helper.position
            let nodeF = helper.frame
            if location.x >= nodePos.x + nodeF.width/2.0 || //Right
                location.x <= nodePos.x - nodeF.width/2.0 || //Left
                location.y >= nodePos.y + nodeF.height/2.0 || //Up
                location.y <= nodePos.y - nodeF.height/2.0 { //Down
                handleTouchesMoved(helper, isBool: &isApple)
            }
        }
    }
}

//MARK: - Configurations

extension MainMenu {
    
    func createdBackground() {
        let i = Int.random(range: 1...5)
        let bg = SKSpriteNode(imageNamed: "bg\(i)_2")
        bg.anchorPoint = .zero
        bg.position = .zero
        bg.zPosition = -1.0
        addChild(bg)
    }
    
    func drawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.lineWidth = 4.0
        shape.strokeColor = .red
        shape.zPosition = 50.0
        addChild(shape)
    }
    
    func createdStickHeroLbl() {
        let stickPos = CGPoint(x: frame.midX, y: frame.midY * 1.7)
        let stickLbl = createdLabel("Stick", pos: stickPos)
        addChild(stickLbl)
        
        let frontStick = createdFrontLabel(stickLbl)
        stickLbl.addChild(frontStick)
        
        let heroPos = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        let heroLbl = createdLabel("Hero", pos: heroPos)
        addChild(heroLbl)
        
        let frontHero = createdFrontLabel(heroLbl)
        heroLbl.addChild(frontHero)
    }
    
    func createdLabel(_ text: String, pos: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: fontNamed)
        label.text = text
        label.fontColor = .white
        label.fontSize = 270.0
        label.zPosition = 1.0
        label.position = pos
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
    
    func createdFrontLabel(_ lbl: SKLabelNode) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: fontNamed)
        label.text = lbl.text
        label.fontColor = .black
        label.fontSize = 270.0
        label.zPosition = 1.0
        label.position = CGPoint(x: -6.0, y: -6.0)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
    
    func createdPlay() {
        play = SKSpriteNode(imageNamed: "btn_play")
        play.name = ChildName.Play
        play.zPosition = 100.0
        play.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(play)
        
        play.run(.repeatForever(.sequence([
            .moveBy(x: 0.0, y: 30.0, duration: 1.5),
            .moveBy(x: 0.0, y: -30.0, duration: 1.5)
        ])),
                 withKey: WithKey.PlayAnim)
    }
    
    func createdStack() {
        stack = SKShapeNode(rectOf: CGSize(width: 400.0, height: screenHeight*0.3))
        stack.name = "Stack"
        stack.zPosition = 10.0
        stack.position = CGPoint(x: frame.midX, y: stack.frame.height/2.0)
        stack.strokeColor = .black
        stack.fillColor = .black
        addChild(stack)
    }
    
    func createdHero() {
        hero = SKSpriteNode(imageNamed: "hero\(shared.getHeroIndex())_wait1")
        hero.setScale(0.5)
        hero.zPosition = 10.0
        let y = stack.frame.height + hero.frame.height/2.0 - 2.0
        hero.position = CGPoint(x: stack.frame.midX, y: y)
        addChild(hero)
        
        var waitTextures: [SKTexture] = []
        for i in 1...5 {
            waitTextures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_wait\(i)"))
        }
        
        waitTextures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_wait4"))
        waitTextures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_wait3"))
        
        var jumpTextures: [SKTexture] = []
        jumpTextures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_wait1"))
        
        for i in 1...2 {
            jumpTextures.append(SKTexture(imageNamed: "hero\(shared.getHeroIndex())_jump\(i)"))
        }
        
        let waitAct = SKAction.animate(with: waitTextures, timePerFrame: 0.33)
        let delay = SKAction.wait(forDuration: 0.5)
        let jumpAct = SKAction.animate(with: jumpTextures, timePerFrame: 0.33, resize: true, restore: true)
        hero.run(.repeatForever(.sequence([waitAct, delay, jumpAct])))
    }
    
    func createdHelper() {
        helper = SKSpriteNode(imageNamed: "btn_help")
        helper.zPosition = 100.0
        helper.name = ChildName.Helper
        
        let x = playableRect.minX + helper.frame.width/2.0 + 10.0
        let y = stack.frame.height
        helper.position = CGPoint(x: x, y: y)
        addChild(helper)
    }
    
    func createdSound() {
        sound = SKSpriteNode(imageNamed: SKAction.effectEnabled ? "btn_sound" : "btn_mute")
        sound.zPosition = 100.0
        sound.name = ChildName.Sound
        
        let x = playableRect.minX + sound.frame.width/2.0 + 10.0
        let y = stack.frame.height - sound.frame.height - 50.0
        sound.position = CGPoint(x: x, y: y)
        addChild(sound)
    }
    
    func createdApple() {
        apple = SKSpriteNode(imageNamed: "btn_apple")
        apple.zPosition = 100.0
        apple.name = ChildName.Apple
        
        let x = playableRect.maxX - apple.frame.width/2.0 - 10.0
        let y = stack.frame.height
        apple.position = CGPoint(x: x, y: y)
        addChild(apple)
    }
    
    func createdCharacter() {
        character = SKSpriteNode(imageNamed: "btn_character")
        character.zPosition = 100.0
        character.name = ChildName.Character
        
        let x = playableRect.maxX - character.frame.width/2.0 - 10.0
        let y = stack.frame.height - character.frame.height - 50.0
        character.position = CGPoint(x: x, y: y)
        addChild(character)
    }
    
    func setupAudio() {
        guard SKAction.effectEnabled else { return }
        run(clickSound)
    }
    
    func setupPresent() {
        play.removeAction(forKey: WithKey.PlayAnim)
        
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        view!.presentScene(scene, transition: .fade(withDuration: 0.5))
    }
    
    func setupBtnAct(_ node: SKSpriteNode, completion: @escaping () -> Void) {
        node.alpha = 0.80
        node.setScale(0.95)
        handleEffectEnabled(completion: completion)
    }
    
    func handleEffectEnabled(completion: @escaping () -> Void) {
        clickSound = SKAction.playSoundFileNamed("button.wav", wait: false)
        if SKAction.effectEnabled {
            run(clickSound) { completion() }
            
        } else {
            completion()
        }
    }
    
    func removeBtnAct(_ node: SKSpriteNode, isBool: inout Bool, completion: @escaping () -> Void) {
        node.alpha = 1.0
        node.setScale(1.0)
        isBool = false
        completion()
    }
    
    func handleTouchesMoved(_ node: SKSpriteNode, isBool: inout Bool) {
        node.alpha = 1.0
        node.setScale(1.0)
        isBool = false
    }
}

//MARK: - UICollectionView

extension MainMenu {
    
    func setupCollectionView(_ view: SKView, isShop: Bool) {
        //ContainerView
        containerHeroesV.frame = view.frame
        containerHeroesV.backgroundColor = UIColor(hex: 0x000000, alpha: 0.6)
        view.addSubview(containerHeroesV)
        
        //ContainerCollectionView
        let viewF = view.frame
        let width: CGFloat = viewF.width * 0.8
        let height: CGFloat = viewF.height * 0.6
        let point = CGPoint(x: viewF.width/2.0 - width/2.0, y: viewF.height/2.0 - height/2.0)
        containerCVC.frame = CGRect(origin: point, size: CGSize(width: width, height: height))
        containerCVC.backgroundColor = UIColor(hex: 0xFFECB8)
        containerCVC.clipsToBounds = true
        containerCVC.layer.cornerRadius = 16.0
        containerCVC.layer.masksToBounds = false
        containerCVC.layer.shadowColor = UIColor.black.cgColor
        containerCVC.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        containerCVC.layer.shadowRadius = 3.0
        containerCVC.layer.shadowOpacity = 0.3
        containerCVC.layer.shouldRasterize = true
        containerCVC.layer.rasterizationScale = UIScreen.main.scale
        view.addSubview(containerCVC)
        
        //TopView
        let topView = UIView()
        topView.backgroundColor = .clear//UIColor(hex: 0xD4F7DD)
        topView.frame = CGRect(origin: .zero, size: CGSize(width: width, height: 60.0))
        containerCVC.addSubview(topView)

        let corner: UIRectCorner = [.topLeft, .topRight]
        let cornerSize = CGSize(width: 20.0, height: 20.0)
        let path = UIBezierPath(roundedRect: topView.frame, byRoundingCorners: corner, cornerRadii: cornerSize)
        let topLayer = CAShapeLayer()
        topLayer.path = path.cgPath
        topLayer.strokeColor = UIColor(hex: 0xD4F7DD).cgColor
        topLayer.fillColor = UIColor(hex: 0xD4F7DD).cgColor
        topView.layer.addSublayer(topLayer)
        
        //HeroLbl
        let heroLbl = UILabel()
        heroLbl.font = UIFont(name: fontNamed, size: 40.0)
        heroLbl.text = isShop ? "SHOP" : "HEROES"
        heroLbl.textColor = .black
        heroLbl.frame = CGRect(origin: CGPoint(x: 20.0, y: 10.0), size: CGSize(width: 200.0, height: 50.0))
        containerCVC.insertSubview(heroLbl, aboveSubview: topView)
        
        //Apple Template
        let appleImgView = UIImageView()
        appleImgView.clipsToBounds = true
        appleImgView.contentMode = .scaleAspectFill
        appleImgView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        appleImgView.image = UIImage(named: "apple_template")
        appleImgView.frame = CGRect(origin: CGPoint(x: topView.frame.width - 60.0, y: 10.0),
                                    size: CGSize(width: 40.0, height: 40.0))
        containerCVC.insertSubview(appleImgView, aboveSubview: topView)
        
        //Apple Quantity
        MainMenu.appleQuantityLbl.font = UIFont(name: fontNamed, size: 40.0)
        MainMenu.appleQuantityLbl.text = "\(GameManager.sharedInstance.getAppleQuantity())"
        MainMenu.appleQuantityLbl.textColor = .black
        MainMenu.appleQuantityLbl.textAlignment = .right
        
        let lblPoint = CGPoint(x: topView.frame.width - 70.0 - 200.0, y: 10.0)
        let lblSize = CGSize(width: 200.0, height: 50.0)
        MainMenu.appleQuantityLbl.frame = CGRect(origin: lblPoint, size: lblSize)
        containerCVC.insertSubview(MainMenu.appleQuantityLbl, aboveSubview: topView)
        
        //CollectionView
        let cvcPoint = CGPoint(x: 0.0, y: 60.0)
        heroesCVC.frame = CGRect(origin: cvcPoint, size: CGSize(width: width, height: height - 60.0 - 30.0))
        containerCVC.addSubview(heroesCVC)
        
        heroesCVC.kDelegate = self
        heroesCVC.backgroundColor = UIColor(hex: 0xFFECB8)
        
        if isShop {
            heroesCVC.register(ShopCVCell0.self, forCellWithReuseIdentifier: "ShopCVCell0")
            heroesCVC.register(ShopCVCell1.self, forCellWithReuseIdentifier: "ShopCVCell1")
            
        } else {
            heroesCVC.register(HeroesCVCell.self, forCellWithReuseIdentifier: "HeroesCVCell")
        }
        
        heroesCVC.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        heroesCVC.showsHorizontalScrollIndicator = false
        heroesCVC.showsVerticalScrollIndicator = false

        let layout = heroesCVC.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        heroesCVC.reloadData()
        
        //UITapGestureRecognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(containerViewDidTap))
        tap.cancelsTouchesInView = false
        containerHeroesV.isUserInteractionEnabled = true
        containerHeroesV.addGestureRecognizer(tap)
        
        isHiddenCV = true
        isPaused = true
    }
    
    @objc func containerViewDidTap() {
        isPaused = false
        isHiddenCV = false
        containerHeroesV.removeFromSuperview()
        containerCVC.removeFromSuperview()
    }
}

//MARK: - HeroesCVCDelegate

extension MainMenu: HeroesCVCDelegate {
    
    func handleHero() {
        self.hero.removeFromParent()
        self.createdHero()
    }
    
    func buyProduct(_ product: SKProduct) {
        let isPurchase = StickHeroProducts.store.isPrPurchase(product.productIdentifier)
        if isPurchase || IAPHelper.canMakePayments() {
            MainMenu.product = SKProduct()
            MainMenu.product = product
            StickHeroProducts.store.buyPr(product)
            
        } else {
            let alert = UIAlertController(title: "Purchase", message: "In-app purchases are not allowed", preferredStyle: .alert)
            let act = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(act)
            self.view!.window!.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func restorePurchase() {
        StickHeroProducts.store.restorePurchase()
    }
}

//MARK: - Ad Interstitial

extension MainMenu {
    
    func createdInterstitial() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.loadInterstitial {
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
            interstitial.delegate = self
            interstitial.load(GADRequest())
            
            run(.sequence([
                .wait(forDuration: 1.5),
                .run {
                    if self.interstitial.isReady {
                        self.interstitial.present(fromRootViewController: self.view!.window!.rootViewController!)
                    }
                }
            ]))
            
            appDelegate.loadInterstitial = false
        }
    }
}

//MARK: - Ad Interstitial

extension MainMenu: GADInterstitialDelegate {
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {}
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {}
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {}
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {}
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {}
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {}
}
