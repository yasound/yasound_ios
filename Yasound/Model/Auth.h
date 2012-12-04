//
//  Auth.h
//  Yasound
//
//  Created by matthieu campion on 12/15/11.
//  Copyright (c) 2011 Yasound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Auth : NSObject
{
  NSString* username;
}

@property (retain, nonatomic) NSString* username;

- (id)initWithUsername:(NSString*)name;

@end

@interface AuthPassword : Auth 
{
  NSString* password;
}

@property (retain, nonatomic) NSString* password;

- (id)initWithUsername:(NSString *)name andPassword:(NSString*)pwd;
@end

@interface AuthApiKey : Auth 
{
  NSString* apiKey;
}

- (id)initWithUsername:(NSString *)name andApiKey:(NSString*)key;

- (NSArray*)urlParams;
- (NSDictionary*)urlParamsDict;
@end


@interface AuthSocial : Auth 
{
  NSString* _accountType;
  NSString* _uid;
  NSString* _token;
    NSString* _expirationDate;
  NSString* _tokenSecret;
  NSString* _email;
}

//- (id)initWithUsername:(NSString *)name accountType:(NSString*)type uid:(NSString*)uid token:(NSString*)token andEmail:(NSString*)email;
- (id)initWithUsername:(NSString *)name  accountType:(NSString*)type uid:(NSString*)uid token:(NSString*)token expirationDate:(NSString*)expirationDate andEmail:(NSString*)email;
- (id)initWithUsername:(NSString *)name accountType:(NSString*)type uid:(NSString*)uid token:(NSString*)token tokenSecret:(NSString*)tokenSecret andEmail:(NSString*)email;

- (NSArray*)urlParams;
- (NSDictionary*)urlParamsDict;
@end


