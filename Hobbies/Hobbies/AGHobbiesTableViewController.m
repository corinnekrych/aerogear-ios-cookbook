/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGHobbiesTableViewController.h"


@implementation AGHobbiesTableViewController {
    NSMutableDictionary *_newHobby;
}
@synthesize hobbies;
@synthesize tableView;
@synthesize editButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.tableView.allowsSelectionDuringEditing = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath {
    NSString *description = [[self.hobbies objectAtIndex:indexPath.row] objectForKey:@"description"];
    if ([description isEqualToString:@"new"]) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
    
}

- (void)tableView: (UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath

{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.hobbies removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [self.tableView reloadData];
        [self.tableView setEditing:NO animated:YES];
        [self.hobbies removeObject:_newHobby];
        [self.tableView reloadData];
    }
    
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        //_newHobby = [self.hobbies objectAtIndex:indexPath.row];
        NSString *oid = [[NSUUID UUID] UUIDString];
        NSString *description = [_newHobby objectForKey:@"description"];
        description = [NSString stringWithFormat:@"new %@", oid];
        [_newHobby setObject:oid forKey:@"id"];
        [_newHobby setObject:description forKey:@"description"];

        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
        
    }
    
}
- (IBAction)addNewDescription:(id)sender {

}
- (IBAction)enterEditMode:(id)sender {
    
    if ([self.tableView isEditing]) {
        [self.hobbies removeObject:_newHobby];
        [self.tableView reloadData];
        [self.tableView setEditing:NO animated:YES];
    }
    else {
        // Turn on edit mode
        _newHobby = [NSMutableDictionary dictionary];
        _newHobby[@"description"] = @"new";
        [self.hobbies addObject:_newHobby];
        [self.tableView reloadData];
        [self.tableView setEditing:YES animated:YES];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [self.hobbies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Where we configure the cell in each row
    
    static NSString *CellIdentifier = @"HobbiesCell";
    UITableViewCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... setting the text of our cell's label
    cell.textLabel.text = [[self.hobbies objectAtIndex:indexPath.row] objectForKey:@"description"];
    return cell;
}

@end
