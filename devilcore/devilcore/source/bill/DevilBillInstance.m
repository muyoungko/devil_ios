//
//  DevilBill.m
//  devilbill
//
//  Created by Mu Young Ko on 2022/06/24.
//

#import "DevilBillInstance.h"
#import "WildCardConstructor.h"
#import "DevilDebugView.h"

@interface DevilBillInstance()
@property void (^callback)(id res);
@property void (^purchaseCallback)(id res);
@end

@implementation DevilBillInstance

+(DevilBillInstance*)sharedInstance{
    static DevilBillInstance *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DevilBillInstance alloc] init];
    });
    return sharedInstance;
}

- (void)requestProduct:(NSArray*)skus callback:(void (^)(id res))callback {
    self.callback = callback;
    NSSet *productIdentifiers = [NSSet setWithArray:skus];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    if(self.callback != nil){
        id list = [@[] mutableCopy];
        id r = @{@"r":@TRUE, @"list":list};
        id skus = [@[] mutableCopy];
        for(SKProduct* product in response.products) {
            NSLog(@"Product title: %@" , product.localizedTitle);
            NSLog(@"Product description: %@" , product.localizedDescription);
            NSLog(@"Product price: %@" , product.price);
            NSLog(@"Product sku: %@" , product.productIdentifier);
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *formattedString = [numberFormatter stringFromNumber:product.price];
            
            [skus addObject: product.productIdentifier];
            [list addObject:[@{
                @"type" : (product.subscriptionPeriod?@"subscribe":@"normal"),
                @"title" : product.localizedTitle,
                @"desc" : product.localizedDescription,
                @"price" : product.price,
                @"sku" : product.productIdentifier,
                @"price_text" : formattedString,
            } mutableCopy]];
        }

        
        [self checkSkuPurchase:skus callback:^(id res2) {
            if(res2 && res2[@"r"]) {
                id recipe_list = res2[@"list"];
                for(id recipe in recipe_list) {
                    for(id product in list) {
                        if([product[@"sku"] isEqualToString:recipe[@"sku"]]) {
                            product[@"valid"] = recipe[@"valid"];
                            product[@"expire"] = recipe[@"expire"];
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback(r);
                self.callback = nil;
            });
        }];
        
    } else if(self.purchaseCallback) {
        if([response.products count] > 0) {
            SKProduct* product = response.products[0];
            [self purchaseSKProduct:product];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.purchaseCallback(@{@"r":@FALSE});
                self.purchaseCallback = nil;
            });
        }
    }
}

- (void)purchase:(NSString*)sku callback:(void (^)(id res))callback {
    
    self.purchaseCallback = callback;
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:sku]];
    productsRequest.delegate = self;
    [productsRequest start];
}


- (void)purchaseSKProduct:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)requestPurchasedProduct:(id)param callback:(void (^)(id res))callback {
    NSString* sku = param[@"sku"];
    self.callback = callback;
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:sku]];
    productsRequest.delegate = self;
    [productsRequest start];
}


- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");

            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
            
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        //if you have multiple in app purchases in your app,
        //you can get the product identifier of this transaction
        //by using transaction.payment.productIdentifier
        //
        //then, check the identifier against the product IDs
        //that you have defined to check which product the user
        //just purchased

        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased: {
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                
                NSLog(@"Transaction state -> Purchased");
                /**
                 transaction.transactionIdentifier 2000000101908674
                 transaction.payment.productIdentifier month
                 */
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                if(self.purchaseCallback){
                    self.purchaseCallback(@{
                        @"r":@TRUE,
                        @"order_id": transaction.transactionIdentifier,
                        @"sku": transaction.payment.productIdentifier,
                        @"receipt":[transaction.transactionReceipt base64EncodedStringWithOptions:0],
                    });
                    self.purchaseCallback = nil;
                }
                
                break;
            }
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                if(self.purchaseCallback){
                    self.purchaseCallback(@{@"r":@FALSE});
                    self.purchaseCallback = nil;
                }
                
                break;
        }
    }
}


/**
 {
     "expires_date" = "2022-07-10 16:51:28 Etc/GMT";
     "expires_date_ms" = 1657471888000;
     "expires_date_pst" = "2022-07-10 09:51:28 America/Los_Angeles";
     "in_app_ownership_type" = PURCHASED;
     "is_in_intro_offer_period" = false;
     "is_trial_period" = false;
     "original_purchase_date" = "2022-07-10 15:51:30 Etc/GMT";
     "original_purchase_date_ms" = 1657468290000;
     "original_purchase_date_pst" = "2022-07-10 08:51:30 America/Los_Angeles";
     "original_transaction_id" = 2000000101911988;
     "product_id" = monthly;
     "purchase_date" = "2022-07-10 15:51:28 Etc/GMT";
     "purchase_date_ms" = 1657468288000;
     "purchase_date_pst" = "2022-07-10 08:51:28 America/Los_Angeles";
     quantity = 1;
     "transaction_id" = 2000000101911988;
     "web_order_line_item_id" = 2000000007214271;
 },
 {
     "expires_date" = "2022-07-10 17:51:28 Etc/GMT";
     "expires_date_ms" = 1657475488000;
     "expires_date_pst" = "2022-07-10 10:51:28 America/Los_Angeles";
     "in_app_ownership_type" = PURCHASED;
     "is_in_intro_offer_period" = false;
     "is_trial_period" = false;
     "original_purchase_date" = "2022-07-10 15:51:30 Etc/GMT";
     "original_purchase_date_ms" = 1657468290000;
     "original_purchase_date_pst" = "2022-07-10 08:51:30 America/Los_Angeles";
     "original_transaction_id" = 2000000101911988;
     "product_id" = monthly;
     "purchase_date" = "2022-07-10 16:51:28 Etc/GMT";
     "purchase_date_ms" = 1657471888000;
     "purchase_date_pst" = "2022-07-10 09:51:28 America/Los_Angeles";
     quantity = 1;
     "transaction_id" = 2000000101920780;
     "web_order_line_item_id" = 2000000007214272;
 }
 )
 */
-(void)checkSkuPurchase:(NSArray*)skus callback:(void (^)(id res))callback {
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    //[InAppReceiptManager shared]
    if (!receipt) {
        NSLog(@"no receipt");
        callback(@{@"r":@TRUE, @"list":@[]});
    } else {
        /* Get the receipt in encoded format */
        NSString *encodedReceipt = [receipt base64EncodedStringWithOptions:0];
        [self requestReceipt:encodedReceipt callback:^(id  _Nonnull res) {
            id list = [@[] mutableCopy];
            NSMutableDictionary* r = res;
            long now = (long)[NSDate date].timeIntervalSince1970;
            //receipt > in_app > expires_date_ms, product_id
            id in_app = r[@"receipt"][@"in_app"];
            for(id d in in_app){
                long expire = [d[@"expires_date_ms"] longLongValue]/ 1000;
                
                for(NSString* sku in skus) {
                    if([d[@"product_id"] isEqualToString:sku] && now < expire){
                        [list addObject:@{
                            @"sku":sku,
                            @"valid":@TRUE,
                            @"expire": d[@"expires_date_ms"],
                        }];
                        break;
                    }
                }
            }
            callback(@{@"r":@TRUE, @"list":list});
        }];
    }
}

-(void)requestReceipt:(NSString*)encodedReceipt callback:(void (^)(id res))callback {
    id headers = [@{
        @"Accept": @"application/json",
        @"Content-Type": @"application/json"
    } mutableCopy];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id devilConfig = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString* password = [devilConfig[@"InAppPurchasePassword"] stringValue];
    
    id params = @{
        @"receipt-data":encodedReceipt,
        @"password": password,
    };
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSString* url = @"https://buy.itunes.apple.com/verifyReceipt";
    if([[receiptURL lastPathComponent] isEqualToString:@"sandboxReceipt"])
        url = @"https://sandbox.itunes.apple.com/verifyReceipt";
    
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestPost:url header:headers json:params success:^(NSMutableDictionary *responseJsonObject) {
        
        if(responseJsonObject == nil)
            responseJsonObject = [@{} mutableCopy];
        else if([responseJsonObject isMemberOfClass:[NSError class]]){
            NSString* error = [NSString stringWithFormat:@"%@", responseJsonObject];
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:url log:@{error:error}];
        } else
            [[DevilDebugView sharedInstance] log:DEVIL_LOG_RESPONSE title:url log:responseJsonObject];
        
        callback(responseJsonObject);
    }];
}
@end