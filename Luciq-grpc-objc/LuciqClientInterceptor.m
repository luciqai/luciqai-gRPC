//
//  LuciqClientInterceptor.m
//  Luciq-grpc-objc
//
//  Created by Hussein Kishk on 27/01/2022.
//

#import "LuciqClientInterceptor.h"

@interface GRPCNetworkLog : NSObject
@property NSString *url;
@property NSInteger requestBodySize;
@property NSInteger responseBodySize;
@property NSInteger statusCode;
@property NSMutableDictionary<NSString *, NSString *> *requestHeaders;
@property NSMutableDictionary<NSString *, NSString *> *responseHeaders;
@property NSString *contentType;
@property NSString *errorDomain;
@property NSInteger errorCode;
@property NSTimeInterval duration;
@property NSString *gRPCMethod;
@property NSString *serverErrorMessage;
@property NSTimeInterval startTime;
@property BOOL receivedInitialMetadata;
@end

@implementation GRPCNetworkLog

@end

@implementation LuciqClientInterceptor {
    GRPCNetworkLog *_networkLog;
}

- (void)startWithRequestOptions:(GRPCRequestOptions *)requestOptions callOptions:(GRPCCallOptions *)callOptions {
    GRPCCallOptions *updatedCallOptions = [self addExternalTraceHeaderWithCallOptions:callOptions];
    _networkLog = [[GRPCNetworkLog alloc] init];
    
    _networkLog.url = [NSString stringWithFormat:@"grpc://%@/%@",[requestOptions host], [requestOptions path].pathComponents[1]];
    _networkLog.gRPCMethod = [requestOptions path].pathComponents[2];
    _networkLog.startTime = [[NSDate date] timeIntervalSince1970];
    _networkLog.requestHeaders = [updatedCallOptions.initialMetadata mutableCopy] ?: [NSMutableDictionary dictionary];
    if (_networkLog.requestHeaders[@"content-type"] == nil) {
        [_networkLog.requestHeaders setObject:@"application/grpc" forKey:@"content-type"];
    }
    [super startWithRequestOptions:requestOptions callOptions:updatedCallOptions];
}

- (void)writeData:(id)data {
    _networkLog.requestBodySize += [data length];
    [super writeData:data];
}

- (void)didReceiveData:(id)data {
    _networkLog.responseBodySize += [data length];
    [super didReceiveData:data];
}

- (void)didReceiveInitialMetadata:(NSDictionary *)initialMetadata {
    _networkLog.responseHeaders = [initialMetadata mutableCopy];
    _networkLog.receivedInitialMetadata = YES;
    [super didReceiveInitialMetadata:initialMetadata];
}

- (void)didCloseWithTrailingMetadata:(NSDictionary *)trailingMetadata error:(NSError *)error {
    _networkLog.duration = [[NSDate date] timeIntervalSince1970] - _networkLog.startTime;
    [_networkLog.responseHeaders addEntriesFromDictionary:trailingMetadata];
    if (error == nil) {
        _networkLog.statusCode = 0;
        if (_networkLog.responseHeaders[@"content-type"] == nil) {
            [_networkLog.responseHeaders setObject:@"application/grpc" forKey:@"content-type"];
        }
    } else {
        _networkLog.statusCode = error.code;
        if (_networkLog.receivedInitialMetadata) {
            _networkLog.serverErrorMessage = error.description;
            if (_networkLog.responseHeaders[@"content-type"] == nil) {
                [_networkLog.responseHeaders setObject:@"application/grpc" forKey:@"content-type"];
            }
        } else {
            _networkLog.errorCode = error.code;
            _networkLog.errorDomain = error.description;
        }
    }

    _networkLog.contentType = _networkLog.responseHeaders[@"content-type"];

    [LCQNetworkLogger addGrpcNetworkLogWithUrl:_networkLog.url
                               requestBodySize:_networkLog.requestBodySize
                              responseBodySize:_networkLog.responseBodySize
                                  responseCode:_networkLog.statusCode
                                requestHeaders:_networkLog.requestHeaders
                               responseHeaders:_networkLog.responseHeaders
                                   contentType:_networkLog.contentType
                                     startTime:_networkLog.startTime * USEC_PER_SEC
                                   errorDomain:_networkLog.errorDomain
                                     errorCode:_networkLog.errorCode
                                      duration:_networkLog.duration * USEC_PER_SEC
                                    gRPCMethod:_networkLog.gRPCMethod
                            serverErrorMessage:_networkLog.serverErrorMessage];
    
    [super didCloseWithTrailingMetadata:trailingMetadata error:error];
}

// MARK: - Helpers

- (GRPCCallOptions *)addExternalTraceHeaderWithCallOptions:(GRPCCallOptions *)originalCallOptions {
    NSDictionary *externalTraceIDHeader = [LCQNetworkLogger newExternalTraceIDHeader];
    if (externalTraceIDHeader == nil) {
        return originalCallOptions;
    }
    
    GRPCMetadataDictionary *updatedInitialMetadata = [self addEntriesToMetadata:originalCallOptions.initialMetadata
                                                                 fromDictionary:externalTraceIDHeader];
    
    GRPCMutableCallOptions *mutableCallOptions = [originalCallOptions mutableCopy];
    mutableCallOptions.initialMetadata = updatedInitialMetadata;
    
    return [mutableCallOptions copy];
}

- (GRPCMetadataDictionary *)addEntriesToMetadata:(GRPCMetadataDictionary * _Nullable)originalInitialMetadata
                                  fromDictionary:(NSDictionary *)dictionary {
    
    NSMutableDictionary *mutableInitialMetadata;
    if (originalInitialMetadata != nil) {
        mutableInitialMetadata = [originalInitialMetadata mutableCopy];
    } else {
        mutableInitialMetadata = [[NSMutableDictionary alloc] init];
    }
    
    [mutableInitialMetadata addEntriesFromDictionary:dictionary];
    return [mutableInitialMetadata copy];
}

@end
