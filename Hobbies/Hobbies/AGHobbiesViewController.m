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

#import "AGHobbiesViewController.h"

@interface AGHobbiesViewController ()

@end

@implementation AGHobbiesViewController
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
    self.users = @[
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
                                    @"description": @"Eat pizza"
                                }
                            ]
                        },
                   ];
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

@end
