//
//  ShopCVCell0.swift
//  Stick Hero
//
//  Created by Jack Ily on 28/11/2019.
//  Copyright © 2019 Jack Ily. All rights reserved.
//

import UIKit
import StoreKit

class ShopCVCell0: UICollectionViewCell {
    
    //MARK: - Properties
    
    var containerView = UIView()
    var iconImgView = UIImageView()
    var quantityLbl = UILabel()
    var priceLbl = UILabel()
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            ShopCVCell0.priceFormatter.locale = product.priceLocale
            quantityLbl.text = "+" + product.localizedTitle
            priceLbl.text = ShopCVCell0.priceFormatter.string(from: product.price)
            iconImgView.image = UIImage(named: "apple_\(product.localizedTitle)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addContentForcCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configurations

extension ShopCVCell0 {
    
    func addContentForcCell() {
        containerView.backgroundColor = .white
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10.0
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imgWidth = frame.height
        iconImgView.clipsToBounds = true
        iconImgView.contentMode = .scaleAspectFill
        iconImgView.image = UIImage(named: "apple_template")
        containerView.addSubview(iconImgView)
        iconImgView.translatesAutoresizingMaskIntoConstraints = false
        
        quantityLbl.font = UIFont.boldSystemFont(ofSize: 20.0)
        quantityLbl.text = "+\(400)"
        quantityLbl.textAlignment = .center
        quantityLbl.textColor = UIColor(hex: 0xC8372D)
        addSubview(quantityLbl)
        quantityLbl.translatesAutoresizingMaskIntoConstraints = false
        
        priceLbl.font = UIFont.boldSystemFont(ofSize: 20.0)
        priceLbl.text = "$\(0.99)"
        containerView.addSubview(priceLbl)
        priceLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImgView.widthAnchor.constraint(equalToConstant: imgWidth),
            iconImgView.heightAnchor.constraint(equalToConstant: imgWidth),
            iconImgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10.0),
            iconImgView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            quantityLbl.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -40.0),
            quantityLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            priceLbl.centerYAnchor.constraint(equalTo: centerYAnchor),
            priceLbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0)
        ])
    }
}
