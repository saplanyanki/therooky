//
//  HeroesCVCell.swift
//  Stick Hero
//
//  Created by Jack Ily on 25/11/2019.
//  Copyright © 2019 Jack Ily. All rights reserved.
//

import UIKit

class HeroesCVCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var containerView = UIView()
    var quantityLbl = UILabel()
    var appleImgView = UIImageView()
    var heroImgView = UIImageView()
    var stackView = UIStackView()
    var newImgView = UIImageView()
    
    var apple: Apple! {
        didSet {
            if let bgColor = apple.bgColor as? UIColor {
                containerView.backgroundColor = bgColor
            }
            
            if apple.showHeroIMG {
                heroImgView.isHidden = false
                heroImgView.image = UIImage(named: apple.heroIMG)
                stackView.isHidden = true
                
            } else {
                heroImgView.isHidden = true
                stackView.isHidden = false
            }
            
            quantityLbl.text = "\(apple.quantity)"
            newImgView.isHidden = !apple.newItem
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addContentForCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configures

extension HeroesCVCell {
    
    func addContentForCell() {
        //ContainerView
        containerView.backgroundColor = UIColor(hex: 0xFBC333)
        containerView.clipsToBounds = true
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
        let fontSize: CGFloat
        let imgHeight: CGFloat
        
        let heroImg = UIImage(named: "hero0_1")!
        let heroW: CGFloat
        let heroH: CGFloat
        
        let newH: CGFloat
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            fontSize = 40.0
            imgHeight = 60.0
            newH = 84.51
            
            containerView.layer.cornerRadius = 16.0
            newImgView.image = UIImage(named: "new1")
            heroW = heroImg.size.width*0.2
            heroH = heroImg.size.height*0.2
            
        } else {
            containerView.layer.cornerRadius = 10.0
            newImgView.image = UIImage(named: "new2")
            heroW = heroImg.size.width*0.1
            heroH = heroImg.size.height*0.1
            newH = 42.0
            
            switch UIScreen.main.nativeBounds.width {
            case 0...640:
                fontSize = 20.0
                imgHeight = 35.0
            default:
                fontSize = 30.0
                imgHeight = 40.0
                break
            }
        }
        
        //New
        newImgView.clipsToBounds = true
        newImgView.contentMode = .scaleAspectFill
        newImgView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        containerView.addSubview(newImgView)
        newImgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newImgView.widthAnchor.constraint(equalToConstant: newH),
            newImgView.heightAnchor.constraint(equalToConstant: newH),
            newImgView.topAnchor.constraint(equalTo: containerView.topAnchor),
            newImgView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        newImgView.isHidden = true
        
        //QuantityLable
        quantityLbl.font = UIFont(name: fontNamed, size: fontSize)
        quantityLbl.textColor = .white
        quantityLbl.text = "\(1000)"
        quantityLbl.sizeToFit()
        
        //AppleImageView
        appleImgView.clipsToBounds = true
        appleImgView.contentMode = .scaleAspectFill
        appleImgView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        appleImgView.image = UIImage(named: "apple_template")
        appleImgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appleImgView.widthAnchor.constraint(equalToConstant: imgHeight),
            appleImgView.heightAnchor.constraint(equalToConstant: imgHeight),
        ])
        
        //StackView
        stackView.spacing = 5.0
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.addArrangedSubview(quantityLbl)
        stackView.addArrangedSubview(appleImgView)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10.0),
            stackView.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: 10.0)
        ])
        
        //HeroImageView
        heroImgView.clipsToBounds = true
        heroImgView.contentMode = .scaleAspectFill
        heroImgView.image = heroImg
        addSubview(heroImgView)
        heroImgView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heroImgView.centerXAnchor.constraint(equalTo: centerXAnchor),
            heroImgView.centerYAnchor.constraint(equalTo: centerYAnchor),
            heroImgView.widthAnchor.constraint(equalToConstant: heroW),
            heroImgView.heightAnchor.constraint(equalToConstant: heroH)
        ])
        
        heroImgView.isHidden = true
    }
}
