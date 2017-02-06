<p align="center">
  <img src="https://habrastorage.org/files/3c5/4cd/4e1/3c54cd4e189e4c76b4cb2b39e7c126ec.gif"/>
</p>

<p align="center">
  <b>Your service implementation is a cooperation of your core components</b>
</p>

![Version](https://img.shields.io/badge/version-0.0.2-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Test Coverage](https://img.shields.io/badge/Test%20Coverage-55%25-orange.svg)
![Status](https://img.shields.io/badge/status-alpha-orange.svg)

**COOperation** is a component for organizing and structuring the code of your service layer with the help of *NSOperation*.

         | Key Features
---------|---------------
&#127984; | Design beautiful and reusable business logic
&#128591; | Follow the SOLID principles out of the box
&#127823; | Use the *Compound Operations* concept introduced by Apple at WWDC 2015 ([Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/))
&#9745;   | Write unit and integration tests easily

**COOperation** is written in Objective-C with full Swift interop support. By the way, we are working on a Swift version!

## Installation

### Cocoapods

The preferred installation method for `COOperation` is with [CocoaPods](http://cocoapods.org). Simply add the following to your Podfile:

```ruby
# Latest release of COOperation
pod 'COOperation'
```

## Usage

### Creating your "Chainable Operation"

```swift
import Foundation
import CompoundOperations

/// Chainable operation that performs network request
class NetworkRequestChainableOperation: ChainableOperationBase {
    
    /// Network client (Core-component)
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        
        super.init()
    }
    
    // MARK: Executing
    
    override func inputDataClass() -> AnyClass? {
        return NSURLRequest.self
    }
    
    override func processInputData(inputData: AnyObject?,
                                   completionBlock: ChainableOperationBaseOutputDataBlock) {
        
        let inputRequest = inputData as! NSURLRequest
        
        networkClient.performRequest(inputRequest) { (data, error) in
            completionBlock(data, error)
        }
    }
}
```

### Creating your "Compound Operation"

```swift
    func obtainDataCompoundOperation(withResultBlock resultBlock: CompoundOperationResultBlock?) -> CompoundOperation {
        let networkRequestOperation = NetworkRequestChainableOperation(networkClient: NetworkClientImplementation())
        let deserializationOperation = DeserializationChainableOperation(deserializer: JSONDeserializer)

        let chainableOperations = [
            networkRequestOperation,
            deserializationOperation
        ]
        
        let operation = CompoundOperation.defaultCompoundOperation()
        operation.configureWithChainableOperations(chainableOperations,
                                                   resultBlock: resultBlock)
        
        return operation
    }
```

### Using your "Compound Operation" in your services

```swift
    let compoundOperation = obtainDataCompoundOperation { (data, error) in
        // Process the result
    }
    
    queue.addOperation(compoundOperation) // OR compoundOperation.start()
```

### Author

- Gleb Novik, Egor Tolstoy and the rest of [Rambler.iOS team](https://github.com/orgs/rambler-digital-solutions/teams/ios-team).

### License

MIT

### Thanks

[Sergey Simanov](https://dribbble.com/SlmacH) - impressive logo design.
