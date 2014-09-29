//
//  PurchaceViewController.m
//  OnlinerUP
//
//  Created by Alex Kardash on 9/28/14.
//
//

#import "PurchaceViewController.h"
#import "MyAdTableViewController.h"

@interface PurchaceViewController ()
@property (strong, nonatomic) MyAdTableViewController *myAdViewController;

@end

@implementation PurchaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self setEdgesForExtendedLayout:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight];
    [super viewDidLoad];
    _buyButton.enabled = NO;
    _restoreButton.enabled = NO;
    [[SKPaymentQueue defaultQueue]
     addTransactionObserver:self];
//    [self getProductInfo:self.productName];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getProductInfo:(NSString*) ProductID
{
    NSLog(@"User requests to remove ads");
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:ProductID]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}


#pragma mark -
#pragma mark SKProductsRequestDelegate

#pragma mark - in-app purchaces

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//    SKProduct *validProduct = nil;
//    int count = [response.products count];
//    if(count > 0){
//        validProduct = [response.products objectAtIndex:0];
//        NSLog(@"Products Available!");
//        [self purchase:validProduct];
//    }
//    else if(!validProduct){
//        NSLog(@"No products available");
//        //this is called if your product id is not valid, this shouldn't be called unless that happens.
//    }
    
    NSArray *products = response.products;
    
    if (products.count != 0)
    {
        _product = products[0];
        _buyButton.enabled = YES;
        _restoreButton.enabled = YES;
        _productTitle.text = _product.localizedTitle;
        _productDescription.text = _product.localizedDescription;
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:_product.priceLocale];
        [_buyButton setTitle:[NSString stringWithFormat:@"Купить за %@",[numberFormatter stringFromNumber:_product.price]] forState:UIControlStateNormal];
    } else {
     _productTitle.text = @"Product not found";
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restore
{
    //this is called when the user restores purchases, you should hook this up to a button
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    if (queue.transactions.count > 0) {
        for (SKPaymentTransaction *transaction in queue.transactions)
        {
            if(SKPaymentTransactionStateRestored){
                NSLog(@"Transaction state -> Restored");
                //called when the user successfully restores a purchase
                if ([self.productName isEqualToString:@"removeAds"]) {
                    [self doRemoveAds];
                } else [self doUnlockUp];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Спасибо" message:@"Покупка успешно осуществлена" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
        }
    } else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Услуга не была куплена ранее" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.buyButton.enabled = YES;
        self.restoreButton.enabled = YES;
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    self.buyButton.enabled = YES;
    self.restoreButton.enabled = YES;
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                if ([self.productName isEqualToString:@"removeAds"]) {
                    [self doRemoveAds];
                } else [self doUnlockUp];
                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                if ([self.productName isEqualToString:@"removeAds"]) {
                    [self doRemoveAds];
                } else [self doUnlockUp];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                if ([self.productName isEqualToString:@"removeAds"]) {
                    [self doRemoveAds];
                } else [self doUnlockUp];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)doRemoveAds{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForIsAdsRemoved];
    //use NSUserDefaults so that you can load wether or not they bought it
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:NO];
    
}

- (void)doUnlockUp
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForIsUpUnlocked];
    //use NSUserDefaults so that you can load wether or not they bought it
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)buyProduct:(id)sender {
    [self purchase:self.product];
    self.buyButton.enabled = NO;
    self.restoreButton.enabled = NO;
}

- (IBAction)restoreProduct:(id)sender {
    [self restore];
    self.buyButton.enabled = NO;
    self.restoreButton.enabled = NO;
}

@end
