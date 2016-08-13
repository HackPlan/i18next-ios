//
//  I18NextConnection.m
//  i18next
//
//  Created by Jean Regisser on 07/11/13.
//  Copyright (c) 2013 PrePlay, Inc. All rights reserved.
//

#import "I18NextConnection.h"

@interface I18NextConnection ()

@property (nonatomic, strong) NSURLSession* session;
@property (nonatomic, strong) NSURLSessionTask* task;
@property (nonatomic, strong) NSURLResponse* response;
@property (nonatomic, strong) NSMutableData* responseData;

@end

@implementation I18NextConnection

+ (instancetype)asynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue
                      completionHandler:(void(^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler {
    return [[self alloc] initWithRequest:request queue:queue completionHandler:completionHandler startImmediately:NO];
}

+ (instancetype)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue
                      completionHandler:(void(^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler {
    return [[self alloc] initWithRequest:request queue:queue completionHandler:completionHandler startImmediately:YES];
}

- (instancetype)initWithRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue
              completionHandler:(void(^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler
               startImmediately:(BOOL)start {
    self = [super init];
    if (self) {
        self.request = request;
        self.queue = queue;
        self.completionHandler = completionHandler;
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue: queue];
        if (start) {
            [self start];
        }
    }
    return self;
}

- (void)dealloc {
    [self cancel];
}

- (void)start {
    self.task = [self.session
        dataTaskWithRequest:self.request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            self.task = nil;
            self.responseData = [NSMutableData dataWithData:data];
            self.response = response;
            [self completeWithResponse:self.response data:self.responseData error:error];
        }];
}

- (void)cancel {
    [self.task cancel];
    self.task = nil;
    
    NSDictionary *userInfo = nil;
    if (self.request.URL) {
        userInfo = @{ NSURLErrorFailingURLErrorKey: self.request.URL };
    }
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
    [self completeWithResponse:self.response data:self.responseData error:error];
}

- (void)completeWithResponse:(NSURLResponse*)response data:(NSData*)data error:(NSError*)error {
    if (self.completionHandler) {
        void(^b)(NSURLResponse *response, NSData *data, NSError *error) = self.completionHandler;
        self.completionHandler = nil;
        [self.queue addOperationWithBlock:^{b(response, data, error);}];
    }
}

@end