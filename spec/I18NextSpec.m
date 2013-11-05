//
//  I18NextSpec.m
//  i18nextspec
//
//  Created by Jean Regisser on 28/10/13.
//  Copyright (c) 2013 PrePlay, Inc. All rights reserved.
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "Nocilla.h"

#import "I18Next.h"

#import "I18NextSpecHelper.h"

SpecBegin(I18Next)

describe(@"I18Next", ^{
    __block I18Next* i18n = nil;
    __block I18NextOptions* options = nil;
    __block NSDictionary* testStore =
    @{
      @"dev": @{ @"translation": @{ @"simple_dev": @"ok_from_dev" } },
      @"en": @{ @"translation": @{ @"simple_en": @"ok_from_en" } },
      @"en-US": @{ @"translation": @{ @"simple_en-US": @"ok_from_en-US" } },
      };
    
    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });
    
    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    
    beforeEach(^{
        i18n = createDefaultI18NextTestInstance();
        options = [I18NextOptions optionsFromDict:i18n.options];
    });
    
    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });
    
    describe(@"initialisation", ^{
        
        it(@"should return a shared instance", ^{
            I18Next* sharedI18n = [I18Next sharedInstance];
            expect(sharedI18n).toNot.beNil();
            expect(sharedI18n).to.beIdenticalTo([I18Next sharedInstance]);
        });
        
        describe(@"with passed in resources set", ^{
            
            beforeEach(^{
                options.resourcesStore = testStore;
                [i18n loadWithOptions:options.asDictionary completion:nil];
            });
            
            it(@"should provide passed resources for translation", ^{
                expect([i18n t:@"simple_en-US"]).to.equal(@"ok_from_en-US");
                expect([i18n t:@"simple_en"]).to.equal(@"ok_from_en");
                expect([i18n t:@"simple_dev"]).to.equal(@"ok_from_dev");
            });
            
        });
        
        describe(@"loading from server", ^{
            
            xdescribe(@"with static route", ^{
                
            });
            
            xdescribe(@"with dynamic route", ^{
                
            });
        });
            
    });
    
});

SpecEnd
