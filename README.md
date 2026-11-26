# [luciqai-gRPC](https://github.com/luciqai/luciqai-gRPC)
These are gRPC interceptors that log gRPC requests with Luciq.

## Compatibility
`Luciq_gRPC_Swift` is a Swift framework for Swift projects. `Luciq_gRPC_ObjC` is for Objective-C projects.

## Installation

### CocoaPods

Add `pod 'Luciq-gRPC-Swift'` or `pod 'Luciq-gRPC-ObjC'` to your `Podfile`.

- `Luciq-gRPC-Swift` needs `use_frameworks!` or `use_modular_headers!` in your `Podfile`.
- `Luciq-gRPC-ObjC` does not include a gRPC transport. If your app does not already use the `gRPC` or `gRPC-ProtoRPC` pod, add `pod 'gRPC'`.

Some gRPC dependencies set an iOS or tvOS deployment target below 15.0. Xcode 27 rejects it with an error such as `'IPHONEOS_DEPLOYMENT_TARGET' is set to 10.0`. Add this hook to your `Podfile` to raise it. CocoaPods allows only one `post_install` hook, so if your `Podfile` already has one, add the loop to it:

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

The Swift package contains only the Swift interceptor. For the Objective-C interceptor, use CocoaPods.

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

- iOS version >= 15.0
- tvOS version >= 15.0
- Luciq version >= 18.0.0 and < 20.0.0
- With Swift Package Manager: grpc-swift version >= 1.27.6 and < 2.0.0, and Xcode version >= 16.3

## Swift Example
1. Import gRPC and our interceptor: `import GRPC` and `import Luciq_gRPC_Swift`
2. Create an interceptor factory that conforms to the interceptor factory protocol that you have in your `.grpc.swift` file
3. Make sure to return a new instance of our interceptor `LuciqClientInterceptor()` in the methods that you need us to log
4. You can optionally pass the port to `LuciqClientInterceptor` as `LuciqClientInterceptor(port:)` to see it on the dashboard

`LuciqClientInterceptor` measures the size of each request message and each response message. Your models do not need to conform to a protocol. `LuciqGRPCDataProtocol` is deprecated and has no effect.
 
### Sample code 

```swift
import GRPC
import Luciq_gRPC_Swift

final class ExampleClientInterceptorFactory: Echo_EchoClientInterceptorFactoryProtocol {
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
```

And finally pass `ExampleClientInterceptorFactory()` to your client like this


```swift
let client = Echo_EchoNIOClient(channel: channel, interceptors: ExampleClientInterceptorFactory())
```

## Objective-C Example
1. Import our interceptor: `#import "LuciqClientInterceptor.h"`
2. Create a class that conforms to the `GRPCInterceptorFactory` protocol
3. Implement `createInterceptorWithManager:` in that class and return a new `LuciqClientInterceptor`
4. Set `interceptorFactories` of your call options to an array with an instance of that class
5. Pass the options to your call. The methods of a generated service take them as `callOptions:`

### Sample code

```objc
#import "LuciqClientInterceptor.h"

@interface GRPCFactory : NSObject <GRPCInterceptorFactory>
@end

@implementation GRPCFactory

- (GRPCInterceptor *)createInterceptorWithManager:(GRPCInterceptorManager *)interceptorManager {
    dispatch_queue_t queue = dispatch_queue_create("ai.luciq.grpc-interceptor", DISPATCH_QUEUE_SERIAL);
    return [[LuciqClientInterceptor alloc] initWithInterceptorManager:interceptorManager dispatchQueue:queue];
}

@end
```

And finally pass the options to your call like this

```objc
GRPCMutableCallOptions *options = [[GRPCMutableCallOptions alloc] init];
options.interceptorFactories = @[[GRPCFactory new]];

GRPCCall2 *call = [[GRPCCall2 alloc] initWithRequestOptions:requestOptions
                                            responseHandler:responseHandler
                                                callOptions:options];
[call start];
```

## Migration from Instabug-gRPC

Move your app from the Instabug SDK to the Luciq SDK. Then:

1. Replace the `Instabug-gRPC-Swift` pod with `Luciq-gRPC-Swift`, and the `Instabug-gRPC-ObjC` pod with `Luciq-gRPC-ObjC`
2. Replace `import Instabug_gRPC_Swift` with `import Luciq_gRPC_Swift`. In Objective-C, import `LuciqClientInterceptor.h` in place of `InstabugClientInterceptor.h`
3. Replace `InstabugClientInterceptor` with `LuciqClientInterceptor`
4. Remove the conformances to `InstabugGRPCDataProtocol`

## Release

Set the new version in both podspecs and in the package line above, and push a tag with the same version, for example `0.3.0`. Swift Package Manager and `pod trunk push` read the tag.

`pod lib lint` and `pod trunk push` need the settings in `pod-lint.xcconfig`, because Xcode 27 rejects the deployment targets of some gRPC pods, and because lint fails on documentation warnings in the headers of dependencies. Run them with `scripts/pod.sh`, which passes that file to `xcodebuild`:

```sh
scripts/pod.sh lib lint Luciq-gRPC-Swift.podspec
scripts/pod.sh trunk push Luciq-gRPC-Swift.podspec
```

Do the same for `Luciq-gRPC-ObjC.podspec`.
