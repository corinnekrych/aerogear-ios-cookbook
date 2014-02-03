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

#import "AGBuddiesViewController.h"
#import "AGHobbiesTableViewController.h"
#import "AGSyncPipe.h"
#import "AGSyncPipeConfiguration.h"
#import "AGSyncMetaData.h"

@interface AGBuddiesViewController ()

@end

@implementation AGBuddiesViewController {
    AGSyncPipe* _pipe;
}
@synthesize users = _users;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableArray* tempUsers = [@[
                   @{
                        @"id": @"123456-654321",
                        @"name": @"Luke Skywalker",
                        @"profession": @"Jedi",
                        @"hobbies": @[
                                    @{
                                        @"id":[[NSUUID UUID] UUIDString],
                                        @"description": @"Fighting the Dark Side"
                                    },
                                    @{
                                         @"id": [[NSUUID UUID] UUIDString],
                                        @"description": @"going into Tosche Station to pick up some power converters"
                                    },
                                    @{
                                        @"id": [[NSUUID UUID] UUIDString],
                                        @"description": @"Kissing his sister"
                                    },
                                    @{
                                        @"id": [[NSUUID UUID] UUIDString],
                                        @"description": @"Bulls eyeing Womprats on his T-16"
                                    }
                                ]
                     },
                    @{
                        @"id": @"123456-4444444",
                        @"name": @"Leonardo",
                        @"profession": @"Ninja",
                        @"hobbies": @[
                                @{
                                    @"id":[[NSUUID UUID] UUIDString],
                                    @"description": @"Fighting the Dark Side"
                                },
                                @{
                                    @"id": [[NSUUID UUID] UUIDString],
                                    @"description": @"Eating pizza"
                                }
                            ]
                        },
                   ] mutableCopy];
    AGSyncPipeConfiguration* config = [[AGSyncPipeConfiguration alloc] init];
    [config setBaseURL:[NSURL URLWithString:@"http://localhost:8080"]];
    [config setName:@"buddies"];
    // high delay to not get in my way when debugging
    [config setTimeout:1000];
    
    _pipe = [AGSyncPipe pipeWithConfig:config];
    
    // DB intialization
    // Tweak: for now server-side doesn't support CREATE, so use UPDATE (ie:put an id)
    // but no rev to create an initial record+rev
    AGSyncMetaData* document = [AGSyncMetaData wrapContent:tempUsers[1]];
    
    [_pipe read:document success:^(id responseObject) {
        NSLog(@"Success reading leonardo");
        self.users = [[NSArray array] mutableCopy];
        [self.users addObject:responseObject[@"content"]];
        [self.tableView reloadData];
    } failure:^(NSError *error){
        NSLog(@"First time init: id not present in database");
        [_pipe save:document success:^(id responseObject) {
            NSLog(@"Added Leonardo");
            self.users = [[NSArray array] mutableCopy];
            [self.users addObject:responseObject[@"content"]];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"Failed to init Leonardo");
        } conflict:^(NSError *error, id responseObject, id delta) {
            NSLog(@"Conflict when saving Leonardo");
        }];;
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Where we configure the cell in each row
    
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... setting the text of our cell's label
    cell.textLabel.text = [[self.users objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"viewHobbies"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AGHobbiesTableViewController *hobbiesViewController = (AGHobbiesTableViewController *)segue.destinationViewController;
        
        NSDictionary *temp = [self.users objectAtIndex:indexPath.row];
        NSArray *tempList = [temp objectForKey:@"hobbies"];
        hobbiesViewController.hobbies = [tempList mutableCopy];
        [hobbiesViewController.tableView reloadData];
        
    } else if ([segue.identifier isEqualToString:@"addUser"]) {
//        AGAddRecipeViewController *addRecipeViewController = segue.destinationViewController;
//        addRecipeViewController.delegate = self;
    }
}
@end
