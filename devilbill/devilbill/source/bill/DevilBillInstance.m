//
//  DevilBill.m
//  devilbill
//
//  Created by Mu Young Ko on 2022/06/24.
//

#import "DevilBillInstance.h"
@interface DevilBillInstance()
@property void (^callback)(id res);
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

- (void)requestProduct:(NSArray*)skus callback:(void (^)(id res))callback
{
    self.callback = callback;
    NSSet *productIdentifiers = [NSSet setWithObject:skus];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        if(self.callback != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback(validProduct);
                self.callback = nil;
            });
        } else
            [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
    }
}

-(void)startPurchase:(NSString*)sku callback:(void (^)(id res))callback{
    self.callback = callback;
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:sku]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
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
            case SKPaymentTransactionStatePurchased:
            //this is called when the user has successfully purchased the package (Cha-Ching!)
                
                NSLog(@"Transaction state -> Purchased");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                if(self.callback){
                    self.callback(@{});
                    self.callback = nil;
                }
                
                break;
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
                if(self.callback){
                    self.callback(@{});
                    self.callback = nil;
                }
                
                break;
        }
    }
}

@end
