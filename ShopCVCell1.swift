//
//  ShopCVCell1.swift
//  Stick Hero
//
//  Created by Jack Ily on 28/11/2019.
//  Copyright © 2019 Jack Ily. All rights reserved.
//

import UIKit

class ShopCVCell1: UICollectionViewCell {
    
    var containerView = UIView()
    var titleLbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addContentForCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Configurations

extension ShopCVCell1 {
    
    func addContentForCell() {
        containerView.backgroundColor = bgCVColor
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10.0
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLbl.font = UIFont.boldSystemFont(ofSize: 25.0)
        titleLbl.text = ""
        titleLbl.textColor = .white
        titleLbl.textAlignment = .center
        containerView.addSubview(titleLbl)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLbl.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLbl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
