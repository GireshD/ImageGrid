//
//  ImageCollectionViewController.swift
//  ImageGrid
//
//  Created by Giresh Dora on 17/04/24.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageCollectionViewController: UICollectionViewController {

    
    var dataSource: UICollectionViewDiffableDataSource<Section, CellItem>! = nil
    
    private var imageObjects = [CellItem]()
    
    private lazy var layout: UICollectionViewLayout = {
        let inset:CGFloat = 2.5
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewSetup()
        fetchCoverages()
    }

    private func collectionViewSetup(){
        collectionView.collectionViewLayout = layout
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, CellItem> { (cell,indexPath,cellItem) in
            var content = UIListContentConfiguration.cell()
            content.directionalLayoutMargins = .zero
            content.axesPreservingSuperviewLayoutMargins = []
            content.imageProperties.cornerRadius = 8
            if cellItem.image == ImageLoader.shared.placeHolderImage{
                content.text = "Loading..."
            }else{
                content.image = cellItem.image
            }
            //Show images on grid
            self.loadImageOnGrid(cellItem: cellItem)
            
            cell.contentConfiguration = content
        }
        
        
        dataSource = UICollectionViewDiffableDataSource<Section,CellItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, cellItem: CellItem) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: cellItem)
        }
        
        
    }
    
    private func loadImageOnGrid(cellItem: CellItem){
        ImageLoader.shared.load(cellItem: cellItem) { [weak self] fetchedItem, image in
            if let img = image, img != fetchedItem.image, let self = self{
                var updatedSnapshot = self.dataSource.snapshot()
                if let dataSourceIndex = updatedSnapshot.indexOfItem(fetchedItem){
                    let item = self.imageObjects[dataSourceIndex]
                    item.image = img
                    updatedSnapshot.reloadItems([item])
                    DispatchQueue.main.async {
                        self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                    }
                }
            }
        }
    }

    private func fetchCoverages(){
        let url = URL(string: "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=100")!
        APIManager.shared.request(url: url, expecting: [Coverage].self) { [weak self] result in
            switch result {
            case .success(let coverages):
                self?.createImageGrid(covers: coverages)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self?.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    private func createImageGrid(covers: [Coverage]){
        if imageObjects.isEmpty {
            self.imageObjects = covers.map { CellItem(image: ImageLoader.shared.placeHolderImage, imageModel: $0.image) }
            var initialSnapshot =  NSDiffableDataSourceSnapshot<Section,CellItem>()
            initialSnapshot.appendSections([.main])
            initialSnapshot.appendItems(self.imageObjects)
            DispatchQueue.main.async { [weak self] in
                self?.dataSource.apply(initialSnapshot, animatingDifferences: true)
            }
        }
    }
}

