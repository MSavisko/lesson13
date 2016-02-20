//
//  ProductsTableViewController.m
//  CoreDataSample
//
//  Created by Sergey Zalozniy on 01/02/16.
//  Copyright © 2016 GeekHub. All rights reserved.
//

#import "CoreDataManager.h"

#import "CDBasket.h"
#import "CDProduct.h"

#import "ProductsTableViewController.h"

@interface ProductsTableViewController () <UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) CDBasket *basket;

@end

@implementation ProductsTableViewController

#pragma mark - Instance initialization

+(instancetype) instanceControllerWithBasket:(CDBasket *)basket {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProductsTableViewController *controller = [sb instantiateViewControllerWithIdentifier:@"ProductsTableViewControllerIdentifier"];
    controller.basket = basket;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProduct:)];
}

#pragma mark - Private methods


-(NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[[CDProduct class] description]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"basket = %@", self.basket];
    request.predicate = predicate;
    NSSortDescriptor *sectionSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"complete" ascending:NO];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sectionSortDescriptor, sortDescriptor];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                    managedObjectContext:context
                                                                      sectionNameKeyPath:@"complete"
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    [_fetchedResultsController performFetch:nil];
    
    return _fetchedResultsController;
}

-(void) addNewProduct:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"New Prodcut" message:@"Enter name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller addAction:action];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeDefault];
        textField.placeholder = @"Product name";
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        textField.placeholder = @"Product price";
    }];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        textField.placeholder = @"Product amount";
    }];
    action = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textFieldName = controller.textFields[0];
        UITextField *textFieldPrice = controller.textFields[1];
        UITextField *textFieldAmount = controller.textFields[2];
        NSDecimalNumber *productPrice = [NSDecimalNumber decimalNumberWithString:textFieldPrice.text];
        NSInteger amount = [textFieldAmount.text integerValue];
        [self createProductWithName:textFieldName.text andPrice:productPrice andAmount:amount];
    }];
    
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:NULL];
}


-(void) createProductWithName:(NSString *)name andPrice:(NSDecimalNumber *)price andAmount:(NSInteger)amount{
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    CDProduct *product = [NSEntityDescription insertNewObjectForEntityForName:[[CDProduct class] description]
                                                     inManagedObjectContext:context];
    product.name = name;
    product.price = price;
    product.amount = amount;
    [self.basket addProductsObject:product];
    [context save:nil];
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CDProduct *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([product.complete boolValue]) {
        product.complete = @NO;
    } else {
        product.complete = @YES;
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    if ([sectionInfo.name isEqualToString:@"0"]) {
        return @"Not bought";
    } else {
        return @"Bought";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    if ([sectionInfo.name isEqualToString:@"0"]) {
        return @"";
    }
    
    NSPredicate * completePredicate = [NSPredicate predicateWithFormat:@"complete = %@", @YES];
    NSArray * boughtProducts = [self.fetchedResultsController.fetchedObjects filteredArrayUsingPredicate:completePredicate];
    
    NSDecimalNumber * totalSum = [NSDecimalNumber zero];
    
    for (int i = 0; i < [boughtProducts count]; i++) {
        CDProduct * product = boughtProducts[i];
        NSDecimalNumber * decimalAmount = [[NSDecimalNumber alloc]initWithUnsignedLong:product.amount];
        NSDecimalNumber * intermediarySum = [product.price decimalNumberByMultiplyingBy:decimalAmount];
        totalSum = [totalSum decimalNumberByAdding:intermediarySum];
        NSLog(@"Total Sum in FOR: %@", totalSum);
    }
    NSLog(@"Total Sum AFTER FOR: %@", totalSum);
    NSString * footer = [NSString stringWithFormat:@"Total Sum: %@", totalSum];
    
    return footer;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    CDProduct *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = product.name;
    if ([product.complete boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CDProduct *product = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[CoreDataManager sharedInstance].managedObjectContext deleteObject:product];
        [[CoreDataManager sharedInstance].managedObjectContext save:nil];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


-(void) controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}


-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationMiddle];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
            //                             withRowAnimation:UITableViewRowAnimationFade];
            //            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            //            if (cell != nil) {
            //                [self configureCell:cell withObject:anObject];
            //            }
            
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
