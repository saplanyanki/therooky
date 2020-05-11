//
//  HeroesCVC.swift
//  Stick Hero
//
//  Created by Jack Ily on 25/11/2019.
//  Copyright © 2019 Jack Ily. All rights reserved.
//

import SpriteKit
import UIKit
import CoreData
import StoreKit

protocol HeroesCVCDelegate: class {
    func handleHero()
    func buyProduct(_ product: SKProduct)
    func restorePurchase()
}

class HeroesCVC: UICollectionView {
    
    var coreDataStack = CoreDataStack(modelName: "AppleDM")
    
    lazy var viewContext: NSManagedObjectContext = {
        return coreDataStack.managedObjectContext
    }()
    
    var apples: [Apple] = []
    weak var kDelegate: HeroesCVCDelegate?
    
    var products: [SKProduct] = []
    
    static var isShop = false
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        
        reload()
        fetchRequest()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperNotification, object: nil)
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let prID = notification.object as? String,
            let index = products.firstIndex(where: { (product) -> Bool in
                product.productIdentifier == prID
            })
            else { return }
        
        self.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload() {
        products = []
        reloadData()
        
        StickHeroProducts.store.requestPrs({ [weak self] success, products in
//            print("***Success: \(success)")
//            print("***PrCount: \(products?.count)")
            
            guard let `self` = self else { return }
            if success {
                self.products = products!.sorted(by: { $0.price.floatValue < $1.price.floatValue })
                DispatchQueue.main.async {
                    self.reloadData()
                    print("***Count: \(self.products.count)")
                }
            }
        })
        
        reloadData()
    }
    
    func fetchRequest() {
        loadData()
        
        let request: NSFetchRequest<Apple> = Apple.fetchRequest()
        
        do {
            apples = try viewContext.fetch(request)
            apples.sort(by: { $0.quantity < $1.quantity })
            self.reloadData()
            
        } catch let error as NSError {
            print("Fetch error: \(error.localizedDescription)")
        }
    }
    
    func loadData() {
        let request: NSFetchRequest<Apple> = Apple.fetchRequest()
        let apples = try! viewContext.fetch(request)
        var arrayID: [String] = []
        
        apples.forEach({
            arrayID.append($0.id)
        })
        
        guard let path = Bundle.main.path(forResource: "AppleSample", ofType: "plist"),
            let array = NSArray(contentsOfFile: path) else { return }
        var arraySampleID: [String] = []
        
        for dict in array {
            if let dict = dict as? [String : Any] {
                let id = dict["id"] as! String
                arraySampleID.append(id)
                
                if !arrayID.contains(id) {
                    let apple = Apple(context: viewContext)
                    apple.id = id
                    apple.quantity = (dict["quantity"] as! NSNumber).int32Value
                    apple.showHeroIMG = dict["showHeroIMG"] as! Bool
                    apple.heroIMG = dict["heroIMG"] as! String
                    apple.newItem = dict["newItem"] as! Bool
                    
                    let colorDict = dict["bgColor"] as! [String : Any]
                    apple.bgColor = UIColor.color(colorDict)
                    coreDataStack.saveContext()
                }
            }
        }
        
        apples.forEach({
            if !arraySampleID.contains($0.id) {
                viewContext.delete($0 as NSManagedObject)
                coreDataStack.saveContext()
            }
        })
        
//        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
//        print(urls[0].absoluteString)
    }
}

//MARK: - UICollectionViewDataSource

extension HeroesCVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if HeroesCVC.isShop {
            return 2

        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if HeroesCVC.isShop {
            if section == 0 {
                return products.count
                
            } else {
                return 1
            }
            
        } else {
            return apples.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if HeroesCVC.isShop {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCVCell0", for: indexPath) as! ShopCVCell0
                cell.product = products[indexPath.row]
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCVCell1", for: indexPath) as! ShopCVCell1
                cell.titleLbl.text = "RESTORE IN-APP"
                return cell
            }
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroesCVCell", for: indexPath) as! HeroesCVCell
            cell.apple = apples[indexPath.item]
            return cell
        }
        
    }
}

//MARK: - UICollectionViewDelegate

extension HeroesCVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if HeroesCVC.isShop {
            if indexPath.section == 0 {
                handleSoundBtn {
                    let product = self.products[indexPath.row]
                    self.kDelegate?.buyProduct(product)
                }
                
            } else {
                handleSoundBtn {
                    self.kDelegate?.restorePurchase()
                }
            }
            
        } else {
            handleSoundBtn {
                let apple = self.apples[indexPath.item]
                let quantity = GameManager.sharedInstance.getAppleQuantity()
                
                if quantity >= apple.quantity {
                    if !apple.showHeroIMG {
                        let remainder = quantity - apple.quantity
                        GameManager.sharedInstance.setAppleQuantity(remainder)
                        MainMenu.appleQuantityLbl.text = "\(GameManager.sharedInstance.getAppleQuantity())"
                        
                        GameManager.sharedInstance.setHeroIndex(indexPath.item)
                        self.kDelegate?.handleHero()
                        apple.bgColor = UIColor.white
                        apple.showHeroIMG = true
                        self.coreDataStack.saveContext()
                        self.reloadData()
                    }
                }
            }
        }
    }
    
    func handleSoundBtn(completion: @escaping () -> Void) {
        if SKTAudio.enabled {
            SKTAudio.sharedInstance().playSoundEffect("button.wav")
            completion()
            
        } else {
            completion()
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension HeroesCVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if HeroesCVC.isShop {
            let width: CGFloat = collectionView.bounds.width - 20.0
            return CGSize(width: width, height: width * 0.2)
            
        } else {
            let width: CGFloat = (collectionView.bounds.width - 30.0)/2.0
            return CGSize(width: width, height: width * 0.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if HeroesCVC.isShop {
            return CGSize(width: collectionView.frame.width, height: 10.0)
            
        } else {
            return .zero
        }
    }
}
