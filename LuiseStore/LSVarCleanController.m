#import "LSVarCleanController.h"
#import "ZFCheckbox.h"
#import "NSJSONSerialization+Comments.h"
#import <LSUtil.h>
#import "LSTheme.h"

@interface LSVarCleanController ()
@property (nonatomic, retain) NSMutableArray *tableData;
@property (nonatomic, retain) NSDictionary *rules;
@end

@implementation LSVarCleanController

+ (instancetype)sharedInstance {
    static LSVarCleanController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    [self setTitle:@"varClean"];

    // Select All as a circular icon button (checkmark.seal.fill).
    UIImage *selectAllImage = [UIImage systemImageNamed:@"checkmark.seal.fill"];
    UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllButton setImage:selectAllImage forState:UIControlStateNormal];
    selectAllButton.tintColor = LSTheme.accentColor;
    selectAllButton.layer.cornerRadius = 18;
    selectAllButton.layer.cornerCurve = kCACornerCurveContinuous;
    selectAllButton.layer.masksToBounds = YES;
    selectAllButton.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.14];
    selectAllButton.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    selectAllButton.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.20].CGColor;
    selectAllButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [selectAllButton.widthAnchor constraintEqualToConstant:36],
        [selectAllButton.heightAnchor constraintEqualToConstant:36],
    ]];
    [selectAllButton addTarget:self action:@selector(batchSelect) forControlEvents:UIControlEventTouchUpInside];
    selectAllButton.accessibilityLabel = @"Select All";
    UIBarButtonItem *selectAllBarItem = [[UIBarButtonItem alloc] initWithCustomView:selectAllButton];
    self.navigationItem.leftBarButtonItem = selectAllBarItem;

    // Clean as a circular icon button (trash.fill).
    UIImage *cleanImage = [UIImage systemImageNamed:@"trash.fill"];
    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cleanButton setImage:cleanImage forState:UIControlStateNormal];
    cleanButton.tintColor = [UIColor systemRedColor];
    cleanButton.layer.cornerRadius = 18;
    cleanButton.layer.cornerCurve = kCACornerCurveContinuous;
    cleanButton.layer.masksToBounds = YES;
    cleanButton.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.14];
    cleanButton.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    cleanButton.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.20].CGColor;
    cleanButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [cleanButton.widthAnchor constraintEqualToConstant:36],
        [cleanButton.heightAnchor constraintEqualToConstant:36],
    ]];
    [cleanButton addTarget:self action:@selector(varClean) forControlEvents:UIControlEventTouchUpInside];
    cleanButton.accessibilityLabel = @"Clean";
    UIBarButtonItem *cleanBarItem = [[UIBarButtonItem alloc] initWithCustomView:cleanButton];
    self.navigationItem.rightBarButtonItem = cleanBarItem;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(manualRefresh) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = refreshControl;

    self.tableData = [self updateData:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoRefresh)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)batchSelect {
    int selected = 0;
    for (NSDictionary *group in self.tableData) {
        for (NSMutableDictionary *item in group[@"items"]) {
            if (![item[@"checked"] boolValue] && ![item[@"ignored"] boolValue]) {
                item[@"checked"] = @YES;
                selected++;
            }
        }
    }
    if (selected == 0) {
        for (NSDictionary *group in self.tableData) {
            for (NSMutableDictionary *item in group[@"items"]) {
                if ([item[@"checked"] boolValue]) {
                    item[@"checked"] = @NO;
                }
            }
        }
    }
    [self.tableView reloadData];
}

- (void)startRefresh:(BOOL)keepState {
    [self.tableView.refreshControl beginRefreshing];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *newData = [self updateData:keepState];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableData = newData;
            [self.tableView reloadData];
            [self.tableView.refreshControl endRefreshing];
        });
    });
}

- (void)manualRefresh {
    [self startRefresh:NO];
}

- (void)autoRefresh {
    [self startRefresh:YES];
}

static NSArray *GetDirectoryContents(NSString *path) {
    NSError *error = nil;
    NSArray *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:&error];
    if (!contents) {
        NSLog(@"contentsOfDirectoryAtPath: %@ : %@", path, error);
        return nil;
    }

    NSMutableArray *result = [NSMutableArray new];
    for (NSString *item in contents) {
        NSString *fullPath = [path stringByAppendingPathComponent:item];
        BOOL isDirectory = NO;
        BOOL exists = [NSFileManager.defaultManager fileExistsAtPath:fullPath isDirectory:&isDirectory];
        [result addObject:@{
            @"name": item,
            @"isDirectory": @(exists && isDirectory),
        }];
    }
    return result;
}

- (void)updateForRules:(NSDictionary *)rules
              customed:(NSMutableDictionary *)customedRules
               newData:(NSMutableArray *)newData
             keepState:(BOOL)keepState {
    for (NSString *path in rules) {
        NSMutableArray *folders = [[NSMutableArray alloc] init];
        NSMutableArray *files = [[NSMutableArray alloc] init];

        NSDictionary *ruleItem = rules[path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *contents = GetDirectoryContents(path);

        NSArray *whiteList = ruleItem[@"whitelist"];
        NSArray *blackList = ruleItem[@"blacklist"];

        NSDictionary *customedRuleItem = customedRules[path];
        NSArray *customedWhiteList = customedRuleItem[@"whitelist"];
        NSArray *customedBlackList = customedRuleItem[@"blacklist"];
        [customedRules removeObjectForKey:path];

        NSMutableDictionary *tableGroup = @{
            @"group": path,
            @"items": @[],
        }.mutableCopy;

        for (NSDictionary *item in contents ?: @[]) {
            NSString *file = item[@"name"];

            BOOL checked = NO;
            BOOL ignored = NO;

            if ([self checkFileInList:file List:blackList]) {
                if ([self checkFileInList:file List:customedWhiteList]) {
                    ignored = YES;
                    checked = NO;
                } else {
                    checked = YES;
                }
            } else if ([self checkFileInList:file List:customedBlackList]) {
                checked = YES;
            } else if ([self checkFileInList:file List:whiteList]) {
                continue;
            } else if ([ruleItem[@"default"] isEqualToString:@"blacklist"]) {
                if ([self checkFileInList:file List:customedWhiteList] ||
                    [customedRuleItem[@"default"] isEqualToString:@"whitelist"]) {
                    ignored = YES;
                    checked = NO;
                } else {
                    checked = YES;
                }
            } else if ([ruleItem[@"default"] isEqualToString:@"whitelist"]) {
                if ([customedRuleItem[@"default"] isEqualToString:@"blacklist"]) {
                    checked = YES;
                } else {
                    continue;
                }
            } else {
                if ([self checkFileInList:file List:customedWhiteList] ||
                    [customedRuleItem[@"default"] isEqualToString:@"whitelist"]) {
                    ignored = YES;
                    checked = NO;
                } else if ([customedRuleItem[@"default"] isEqualToString:@"blacklist"]) {
                    checked = YES;
                } else {
                    checked = NO;
                }
            }

            if (keepState) {
                for (NSDictionary *group in self.tableData) {
                    if (![group[@"group"] isEqualToString:path]) {
                        continue;
                    }

                    for (NSDictionary *existingItem in group[@"items"]) {
                        if ([existingItem[@"name"] isEqualToString:file]) {
                            if (!ignored) {
                                checked = [existingItem[@"checked"] boolValue];
                            }
                            break;
                        }
                    }
                    break;
                }
            }

            NSString *fullPath = [path stringByAppendingPathComponent:file];
            BOOL isFolder = [item[@"isDirectory"] boolValue];

            NSMutableDictionary *tableItem = @{
                @"name": file,
                @"path": fullPath,
                @"isFolder": @(isFolder),
                @"checked": @(checked),
                @"ignored": @(ignored),
            }.mutableCopy;

            if (isFolder) {
                [folders addObject:tableItem];
            } else {
                [files addObject:tableItem];
            }
        }

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                         ascending:YES
                                                                          selector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *sortedFolders = [folders sortedArrayUsingDescriptors:@[sortDescriptor]];
        NSArray *sortedFiles = [files sortedArrayUsingDescriptors:@[sortDescriptor]];

        tableGroup[@"error"] = @(!contents && [fileManager fileExistsAtPath:path]);
        tableGroup[@"items"] = [[sortedFolders arrayByAddingObjectsFromArray:sortedFiles] mutableCopy];
        [newData addObject:tableGroup];
    }
}

- (NSMutableArray *)updateData:(BOOL)keepState {
    NSLog(@"updateData...");
    NSMutableArray *newData = [[NSMutableArray alloc] init];

    NSDictionary *rules = self.rules;
    if (!rules) {
        NSString *jsonPath = [NSBundle.mainBundle pathForResource:@"VarCleanRules" ofType:@"json"];
        if (jsonPath) {
            NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
            rules = [NSJSONSerialization JSONObjectWithCommentedData:jsonData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        }
        self.rules = rules;
    }
    NSMutableDictionary *customedRules = [NSMutableDictionary new];

    [self updateForRules:rules customed:customedRules newData:newData keepState:keepState];
    [self updateForRules:customedRules customed:nil newData:newData keepState:keepState];

    NSComparator sorter = ^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        if ([a[@"items"] count] != 0 && [b[@"items"] count] == 0) {
            return NSOrderedAscending;
        }
        if ([a[@"items"] count] == 0 && [b[@"items"] count] != 0) {
            return NSOrderedDescending;
        }
        return [a[@"group"] compare:b[@"group"]];
    };
    [newData sortUsingComparator:sorter];
    return newData;
}

- (BOOL)checkFileInList:(NSString *)fileName List:(NSArray *)list {
    for (NSObject *item in list) {
        if ([item isKindOfClass:NSString.class]) {
            if ([fileName isEqualToString:(NSString *)item]) {
                return YES;
            }
        } else if ([item isKindOfClass:NSDictionary.class]) {
            NSDictionary *condition = (NSDictionary *)item;
            NSString *name = condition[@"name"];
            NSString *match = condition[@"match"];

            if ([match isEqualToString:@"include"]) {
                if ([fileName rangeOfString:name].location != NSNotFound) {
                    return YES;
                }
            } else if ([match isEqualToString:@"regexp"]) {
                NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:name options:0 error:nil];
                NSUInteger result = [regex numberOfMatchesInString:fileName options:0 range:NSMakeRange(0, fileName.length)];
                if (result != 0) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)performClean {
    [self.tableView.refreshControl beginRefreshing];

    // Collect checked paths first, then remove via the root helper:
    // this app runs as mobile, so files owned by root (e.g. /var/root,
    // /var/db) would otherwise fail to delete.
    NSMutableArray *pathsToDelete = [NSMutableArray new];
    for (NSDictionary *group in self.tableData) {
        for (NSDictionary *item in group[@"items"]) {
            if ([item[@"checked"] boolValue]) {
                [pathsToDelete addObject:item[@"path"]];
            }
        }
    }

    if (pathsToDelete.count) {
        NSMutableArray *args = [NSMutableArray arrayWithObject:@"clean-paths"];
        [args addObjectsFromArray:pathsToDelete];
        NSString *stdOut = nil;
        int ret = spawnRoot(rootHelperPath(), args, &stdOut, nil);
        if (ret != 0) {
            // stdOut contains the paths that failed to delete
            for (NSString *failedPath in [stdOut componentsSeparatedByString:@"\n"]) {
                if (failedPath.length == 0) continue;
                NSLog(@"[varClean] failed to delete %@", failedPath);
                for (NSDictionary *group in self.tableData) {
                    for (NSMutableDictionary *item in group[@"items"]) {
                        if ([item[@"path"] isEqualToString:failedPath]) {
                            item[@"checked"] = @NO;
                            break;
                        }
                    }
                }
            }
        }

        [self.tableView.refreshControl endRefreshing];
        self.tableData = [self updateData:NO];
        [self.tableView reloadData];

        if (ret != 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Some items could not be deleted"
                                                                           message:@"The remaining items were unchecked. Check the console for details."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [self.tableView.refreshControl endRefreshing];
    }
}

- (void)varClean {
    NSMutableString *deletionList = [NSMutableString stringWithString:@"You are about to delete the following items:\n"];

    for (NSDictionary *group in self.tableData) {
        for (NSDictionary *item in group[@"items"]) {
            if ([item[@"checked"] boolValue]) {
                [deletionList appendFormat:@"%@\n", item[@"path"]];
            }
        }
    }

    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@",
                              @"Are you sure you want to clean selected items?",
                              deletionList];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(__unused UIAlertAction *action) {
        [self performClean];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableData[section][@"group"];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    NSDictionary *groupData = self.tableData[section];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];

    if ([groupData[@"error"] boolValue]) {
        header.textLabel.textColor = UIColor.systemRedColor;
    } else if ([groupData[@"items"] count] > 0) {
        header.textLabel.textColor = UIColor.secondaryLabelColor;
    } else {
        header.textLabel.textColor = UIColor.tertiaryLabelColor;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseID];
        cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    }

    cell.backgroundView = nil;

    NSDictionary *item = self.tableData[indexPath.section][@"items"][indexPath.row];
    cell.textLabel.text = item[@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.textLabel.textColor = [item[@"ignored"] boolValue] ? UIColor.tertiaryLabelColor : UIColor.labelColor;
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    // folder vs file icon + size hint for files
    BOOL isFolder = [item[@"isFolder"] boolValue];
    if (isFolder) {
        cell.imageView.image = [UIImage systemImageNamed:@"folder.fill"];
        cell.imageView.tintColor = [UIColor systemBlueColor];
        cell.detailTextLabel.text = @"Folder";
    } else {
        cell.imageView.image = [UIImage systemImageNamed:@"doc.fill"];
        cell.imageView.tintColor = [UIColor systemGrayColor];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:item[@"path"] error:nil];
        long long size = [attrs fileSize];
        cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    cell.backgroundColor = [UIColor clearColor];

    ZFCheckbox *checkbox = [[ZFCheckbox alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    checkbox.userInteractionEnabled = NO;
    [checkbox setSelected:[item[@"checked"] boolValue]];
    cell.accessoryView = checkbox;

    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
    [cell.contentView addGestureRecognizer:gesture];
    gesture.view.tag = indexPath.row | indexPath.section << 32;
    gesture.minimumPressDuration = 1;

    return cell;
}

- (void)cellLongPress:(UIGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    long tag = recognizer.view.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag & 0xFFFFFFFF inSection:tag >> 32];
    NSDictionary *item = self.tableData[indexPath.section][@"items"][indexPath.row];
    NSString *path = item[@"path"];

    UIPasteboard.generalPasteboard.string = path;
    NSString *encodedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    for (NSString *prefix in @[@"filzer://view", @"filza://view"]) {
        NSURL *url = [NSURL URLWithString:[prefix stringByAppendingString:encodedPath]];
        if (url && [UIApplication.sharedApplication canOpenURL:url]) {
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
            return;
        }
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Path copied to clipboard"
                                                                   message:path
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ZFCheckbox *checkbox = (ZFCheckbox *)cell.accessoryView;
    BOOL newState = !checkbox.selected;
    [checkbox setSelected:newState animated:YES];

    NSMutableDictionary *item = self.tableData[indexPath.section][@"items"][indexPath.row];
    item[@"checked"] = @(newState);
}

@end
