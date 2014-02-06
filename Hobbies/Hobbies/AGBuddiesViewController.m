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
#import "DiffMatchPatch.h"

@interface AGBuddiesViewController ()

@end

@implementation AGBuddiesViewController {
    AGSyncPipe* _pipe;
    NSInteger _selectedIndex;
}
@synthesize users = _users;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray* tempUsers = [@[
                    @{
                        @"id": @"123456-4444444",
                        @"content":@{
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
                                }
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
    AGSyncMetaData* document = [AGSyncMetaData wrapContent:tempUsers[0]];
    
    // TODO replace by a read all when available server side
    [_pipe read:document success:^(id responseObject) {
        NSLog(@"Success reading leonardo");
        self.users = [[NSArray array] mutableCopy];
        [self.users addObject:responseObject];
        [self.tableView reloadData];
    } failure:^(NSError *error){
        NSLog(@"First time init: id not present in database");
        [_pipe save:document success:^(id responseObject) {
            NSLog(@"Added Leonardo");
            self.users = [[NSArray array] mutableCopy];
            [self.users addObject:responseObject];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"Failed to init Leonardo");
        } conflict:^(NSError *error, id responseObject, id delta) {
            NSLog(@"Conflict when saving Leonardo");
        }];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... setting the text of our cell's label
    cell.textLabel.text = [[self.users objectAtIndex:indexPath.row] objectForKey:@"content"][@"name"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"viewHobbies"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AGHobbiesTableViewController *hobbiesViewController = (AGHobbiesTableViewController *)segue.destinationViewController;
        
        _selectedIndex = indexPath.row;
        NSArray *tempList = [self.users objectAtIndex:_selectedIndex][@"content"][@"hobbies"];
        hobbiesViewController.hobbies = [tempList mutableCopy];
        [hobbiesViewController.tableView reloadData];
        
    }
}

-(IBAction)unwindToBuddiesContoller:(UIStoryboardSegue *)segue {
    NSLog(@"Save changes");
    AGHobbiesTableViewController* source = segue.sourceViewController;
    
    // Get data from source
    NSArray* hobbies = source.hobbies;
    NSMutableDictionary* temp = [self.users[_selectedIndex] mutableCopy];
    NSMutableDictionary* tempContent = [[NSMutableDictionary alloc] initWithDictionary:temp[@"content"]];
    tempContent[@"hobbies"] = hobbies;
    temp[@"content"] = tempContent;
    AGSyncMetaData* document = [AGSyncMetaData wrapContent:temp];
    // save data in the list
    [_pipe save:document success:^(AGSyncMetaData* responseObject) {
        NSLog(@"sucess in save Buddy");
        self.users[_selectedIndex] = responseObject;
    } failure:^(NSError *error) {
        NSLog(@"failure in save Buddy");
    } conflict:^(NSError *error, AGSyncMetaData* from, AGSyncMetaData* to) {        
        NSData *toData = [NSJSONSerialization dataWithJSONObject:[AGSyncMetaData serialize:to] options:NSJSONWritingPrettyPrinted                                                          error:nil];
        NSString* toString =[[NSString alloc] initWithData:toData encoding:NSUTF8StringEncoding];
        NSData *fromData = [NSJSONSerialization dataWithJSONObject:[AGSyncMetaData serialize:from] options:NSJSONWritingPrettyPrinted                                                          error:nil];
        NSString* fromString =[[NSString alloc] initWithData:fromData encoding:NSUTF8StringEncoding];
        NSLog(@"conflict when saving Buddy./n--> to == %@/ns-->from == %@", toString, fromString);
        DiffMatchPatch *dmp = [[DiffMatchPatch alloc] init];
        NSMutableArray *diffArray = [dmp diff_mainOfOldString:(NSString *)toString andNewString:(NSString *)fromString];
        [dmp diff_cleanupSemantic:diffArray];
        NSLog(@"Pretty diff display == %@", [diffArray description]);
    }];
}
@end
