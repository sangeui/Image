//
//  SearchPreviewCell.swift
//  Image
//
//  Created by 서상의 on 2021/11/15.
//

import UIKit

class SearchPreviewCell: UICollectionViewCell {
    private let imageView: UIImageView = .init()
    private var loader: URLSessionDataTask? = nil
    var url: URL? = nil {
        didSet {
            self.loader = nil
            
            if let url = self.url {
                self.loader = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data else { return }
                    guard let image = UIImage(data: data) else { return }
                    
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
                
                self.loader?.resume()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        imageView.cancelImageLoad()
    }
    
    func load(url: URL?) {
        guard let url = url else { return }
        
        self.imageView.loadImage(at: url)
    }
}

private extension SearchPreviewCell {
    func setup() {
        self.setupImageView(self.imageView)
    }
    
    func setupImageView(_ imageView: UIImageView) {
        self.contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        imageView.contentMode = .scaleToFill
    }
}

class ImageLoader {
    private var images: ThreadSafeDictionary<URL, UIImage> = .init()
    private var requests: ThreadSafeDictionary<UUID, URLSessionDataTask> = .init()
//    private var images = [URL: UIImage]()
//    private var requests = [UUID: URLSessionDataTask]()
    
    func load(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        if let image = self.images[url] {
            completion(.success(image))
            return nil
        }
        
        let uuid = UUID()
        let request = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {self.requests.removeValue(forKey: uuid) }

            if let data = data, let image = UIImage(data: data) {
              self.images[url] = image
              completion(.success(image))
              return
            }

            guard let error = error else { return }

            guard (error as NSError).code == NSURLErrorCancelled else {
              completion(.failure(error))
              return
            }
        }
        
        request.resume()
        
        self.requests[uuid] = request
        return uuid
    }
    
    func cancel(_ uuid: UUID) {
        requests[uuid]?.cancel()
        requests.removeValue(forKey: uuid)
    }
}

class UIImageLoader {
  static let loader = UIImageLoader()

  private let imageLoader = ImageLoader()
    private var uuidMap: ThreadSafeDictionary<UIImageView, UUID> = .init()
//  private var uuidMap = [UIImageView: UUID]()

  private init() {}

  func load(_ url: URL, for imageView: UIImageView) {
      let token = imageLoader.load(url) { result in
        // 2
        defer { self.uuidMap.removeValue(forKey: imageView) }
        do {
          // 3
          let image = try result.get()
          DispatchQueue.main.async {
            imageView.image = image
          }
        } catch {
          // handle the error
        }
      }

      // 4
      if let token = token {
        uuidMap[imageView] = token
      }
  }

  func cancel(for imageView: UIImageView) {
      if let uuid = uuidMap[imageView] {
        imageLoader.cancel(uuid)
        uuidMap.removeValue(forKey: imageView)
      }
  }
}

extension UIImageView {
  func loadImage(at url: URL) {
      UIImageLoader.loader.load(url, for: self)
  }

  func cancelImageLoad() {
      UIImageLoader.loader.cancel(for: self)
  }
}

class ThreadSafeDictionary<V: Hashable,T>: Collection {

    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(label: "Dictionary Barrier Queue",
                                                attributes: .concurrent)
    var startIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.startIndex
        }
    }

    var endIndex: Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.endIndex
        }
    }

    init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }
    // this is because it is an apple protocol method
    // swiftlint:disable identifier_name
    func index(after i: Dictionary<V, T>.Index) -> Dictionary<V, T>.Index {
        self.concurrentQueue.sync {
            return self.dictionary.index(after: i)
        }
    }
    // swiftlint:enable identifier_name
    subscript(key: V) -> T? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }

    // has implicity get
    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }
    
    func removeValue(forKey key: V) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }

}
