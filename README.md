# [luciqai-gRPC](https://github.com/luciqai/luciqai-gRPC)
This is a destination for Luciq to support logging gRPC requests.

## Compatibility
There's `Luciq_gRPC_Swift` which is a Swift framework and intended to be used with Swift projects. And there's `Luciq_gRPC_ObjC` which intended to be used with Objective-C projects

## Installation

### CocoaPods

Add pod `Luciq-gRPC-Swift` or pod `'Luciq-gRPC-ObjC'` to your `podfile`

Some gRPC dependencies set an iOS or tvOS deployment target below 15.0. Xcode 27 rejects it with an error such as `'IPHONEOS_DEPLOYMENT_TARGET' is set to 10.0`. Add this hook to your `podfile` to raise it:

```ruby
post_install do |installer|
  installer.generated_projects.flat_map(&:targets).each do |target|
    target.build_configurations.each do |config|
      ['IPHONEOS_DEPLOYMENT_TARGET', 'TVOS_DEPLOYMENT_TARGET'].each do |setting|
        current = config.build_settings[setting]
        config.build_settings[setting] = '15.0' if current && current.to_f < 15.0
      end
    end
  end
end
```

### Swift Package Manager

Swift Package Manager ships only the Swift interceptor. For the Objective-C interceptor, use CocoaPods.

Add the package to your `Package.swift`, or add its URL in Xcode:

```swift
.package(url: "https://github.com/luciqai/luciqai-gRPC.git", from: "0.3.0")
```

Then add the `Luciq-gRPC-Swift` product to your target, and use `import Luciq_gRPC_Swift`:

```swift
.product(name: "Luciq-gRPC-Swift", package: "luciqai-gRPC")
```

The package adds Luciq from `https://github.com/luciqai/luciq-ios-sdk.git`, version 18.0.0 up to, but not including, 20.0.0. If your app adds Luciq itself, add it with Swift Package Manager and use a version in this range.

## Requirements

iOS version >= 15.0
tvOS version >= 15.0
Luciq version >= 18.0.0 and < 20.0.0

## Swift Example
1. Make sure you import our destination first: `import Luciq_gRPC_Swift`
2. Create Interceptor factory that confirms to the interceptor factory protocol that you have in your .grpc file
3. Make sure to return new instance of our Interceptor `LuciqClientInterceptor()` in the methods that you need us to log
4. Conform on `LuciqGRPCDataProtocol` for request and response models which requires that you expose your models as `Data`
5. You can convert your model to `Data` by conforming to `Encodable`
6. You can pass the port optional in `LuciqClientInterceptor` as `LuciqClientInterceptor(port:)` to see it on the dashboard
 
### Sample code 

```
class ExampleClientInterceptorFactory: Echo_EchoClientInterceptorFactoryProtocol {
  // Returns an array of interceptors to use for the 'Get' RPC.
  func makeGetInterceptors() -> [ClientInterceptor<Echo_EchoRequest, Echo_EchoResponse>] {
    return [LuciqClientInterceptor()]
  }

  // Returns an array of interceptors to use for the 'Expand' RPC.
  func makeExpandInterceptors() -> [ClientInterceptor<Echo_EchoRequest, Echo_EchoResponse>] {
    return [LuciqClientInterceptor()]
  }

  // Returns an array of interceptors to use for the 'Collect' RPC.
  func makeCollectInterceptors() -> [ClientInterceptor<Echo_EchoRequest, Echo_EchoResponse>] {
    return [LuciqClientInterceptor()]
  }

  // Returns an array of interceptors to use for the 'Update' RPC.
  func makeUpdateInterceptors() -> [ClientInterceptor<Echo_EchoRequest, Echo_EchoResponse>] {
    return [LuciqClientInterceptor()]
  }
}

extension GrpcAutomation_RepeaterRequest: LuciqGRPCDataProtocol, Encodable {
    enum CodingKeys: String, CodingKey {
        case message, unknownFields
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
    }
    
    public var gRPCRequestData: Data? {
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(self)
        return data
    }
}
```

And finally pass `ExampleClientInterceptorFactory()` to your client like this


```
let client = Echo_EchoClient(channel: channel, interceptors: ExampleClientInterceptorFactory())
```

## ObjectiveC Example
1. Create an array of `GRPCInterceptorFactory`
2. Create a class that conforms to `GRPCInterceptorFactory` protocol

	```
	@interface GRPCFactory : NSObject <GRPCInterceptorFactory>
	```

3. Override `createInterceptorWithManager` in `GRPCFactory` and return `LuciqClientInterceptor `

	```
	- (nonnull GRPCInterceptor *)createInterceptorWithManager:(nonnull GRPCInterceptorManager *)interceptorManager {
	    LuciqClientInterceptor *interceptor = [[LuciqClientInterceptor alloc] initWithInterceptorManager:interceptorManager dispatchQueue:dispatch_get_main_queue()];
	    return  interceptor;
	}
	```
4. Create a new instance from `GRPCFactory` then add it to the interceptors array
5. Create a new instance of `GRPCInterceptorManager` with the `interceptorFactories` array
6. Then pass the manager to the factory instance then 
7. Finally pass `interceptorFactories` to `options.interceptorFactories`

### Sample code

```
    GRPCMutableCallOptions *options = [[GRPCMutableCallOptions alloc] init];
    
    NSMutableArray<id<GRPCInterceptorFactory>> *interceptorFactories = [NSMutableArray new];
  
    GRPCFactory *factory = [GRPCFactory new];
    [interceptorFactories addObject:factory];
    GRPCInterceptorManager *manager = [[GRPCInterceptorManager alloc] initWithFactories:interceptorFactories
                                                                    previousInterceptor:nil
                                                                            transportID:GRPCDefaultTransportImplList.core_insecure];

    [factory createInterceptorWithManager:manager];
    options.interceptorFactories = interceptorFactories;

```

## Release

`pod lib lint` and `pod trunk push` need the settings in `pod-lint.xcconfig`, because Xcode 27 rejects the deployment targets of some gRPC pods. Run them with `scripts/pod.sh`, which passes that file to `xcodebuild`:

```sh
scripts/pod.sh lib lint Luciq-gRPC-Swift.podspec
scripts/pod.sh trunk push Luciq-gRPC-Swift.podspec
```

Do the same for `Luciq-gRPC-ObjC.podspec`.
