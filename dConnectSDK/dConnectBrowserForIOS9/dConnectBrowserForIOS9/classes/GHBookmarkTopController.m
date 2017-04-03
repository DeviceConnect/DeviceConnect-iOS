//
//  GHListViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHBookmarkTopController.h"
#import "GHBookmarkCell.h"
#import "GHBookmarkViewController.h"
#import "GHFolderCreateController.h"
#import "GHFoldersListController.h"

@interface GHBookmarkTopController ()
{
    BOOL isEditing;
}
@end

@implementation GHBookmarkTopController

#define CELL_ID @"bookmark"

//--------------------------------------------------------------//
#pragma mark - 初期化
//--------------------------------------------------------------//
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

//--------------------------------------------------------------//
#pragma mark - view cycle
//--------------------------------------------------------------//

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem* close = [[UIBarButtonItem alloc]initWithTitle:@"閉じる"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = close;
    
    self.folderBtn.tintColor = [UIColor colorWithWhite:0 alpha:0];
    isEditing = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    // デバイスプラグインの設定画面で、全体のナビゲーションバーの色を変えられた時のために、Browserデフォルトの色に戻す。
    self.navigationController.navigationBar.barTintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.tintColor =  [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].tintColor = [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    [UITabBar appearance].translucent = NO;
    [UITabBar appearance].barTintColor = [UIColor whiteColor];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000]];
    //ツールバーのボタン非表示
    self.navigationController.toolbarHidden = NO;
    [self setEdiMode:isEditing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//--------------------------------------------------------------//
#pragma mark - ボタン制御
//--------------------------------------------------------------//
- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)addBookmark:(id)sender
{
    GHPageModel *model = [[GHPageModel alloc]init];
    model.title = @"";//[self.manager htmlTitle:self.webview];
    model.url   = @"";//[self.manager htmlURL:self.webview];
    model.type  = TYPE_BOOKMARK;
    
    if (model) {
        //ディレイさせないとモーダルが出ない
        [self performSelector:@selector(showAddBookMarkController:) withObject:model afterDelay:0.75];
    }
}
/**
 * ブックマークの追加controllerを表示
 * @param page 最新の履歴から持ってくる
 */
- (void)showAddBookMarkController:(GHPageModel*)model
{
    GHAddBookmarkController * addbook = [[GHAddBookmarkController alloc]initWithPage:model];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:addbook];
    
//    if ([GHUtils isiPad]) {
//        [self showPopup:nav button:activityBtn];
//    }else{
        [self presentViewController:nav animated:YES completion:nil];
//    }
}
- (IBAction)edit:(id)sender
{
    isEditing = !isEditing;
    [self setEdiMode:isEditing];
}


- (void)setEdiMode:(BOOL)edit
{
    [self.tableView setEditing:isEditing animated:YES];
    self.tableView.allowsSelectionDuringEditing = YES;
    
    if (isEditing) {
    
        //編集モード
        self.doneBtn.tintColor = [UIColor colorWithWhite:0 alpha:0];
        self.doneBtn.enabled = NO;
        self.folderBtn.tintColor = nil;
        self.folderBtn.enabled = YES;
        [self.editBtn setTitle:@"完了"];
    }else{
        //通常
        self.doneBtn.tintColor = nil;
        self.doneBtn.enabled = YES;
        self.folderBtn.tintColor = [UIColor colorWithWhite:0 alpha:0];
        self.folderBtn.enabled = NO;
        [self.editBtn setTitle:@"編集"];
    }

    //iPadは常に完了ボタンを非表示
    if ([GHUtils isiPad]) {
        self.doneBtn.enabled = NO;
        self.doneBtn.tintColor = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}


//--------------------------------------------------------------//
#pragma mark - Table view data source
//--------------------------------------------------------------//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (GHBookmarkCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHBookmarkCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    Page* page = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureCell:page atIndexPath:indexPath isEditing:isEditing];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //page.typeを見て遷移する先を選ぶ （お気に入り、履歴、ブックマーク、フォルダ）
    Page* page = [self.fetchedResultsController objectAtIndexPath:indexPath];

    //編集中はブックマークのみ処理
    if (isEditing) {
        if ([page.type isEqualToString:TYPE_BOOKMARK]) {
            //移動先を選択
            [self showFolderSelection:page];
        }
    }else{
        if ([page.type isEqualToString:TYPE_BOOKMARK]){
            page.latest_opened_date = [NSDate date];

            //ブックマーク
            NSDictionary* dict = @{PAGE_URL:page.url};
            [GHUtils postNotification:dict withKey:SHOW_WEBPAGE];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            if ([page.type isEqualToString:TYPE_FAVORITE] || [page.type isEqualToString:TYPE_FOLDER]) {
                //お気に入り & フォルダ
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Bookmark" bundle:[NSBundle mainBundle]];
                GHBookmarkViewController *bookmark = (GHBookmarkViewController*)[storyboard instantiateInitialViewController];
                
                bookmark.parent = page;
                
                if ([page.type isEqualToString:TYPE_FAVORITE]) {
                    //お気に入り
                    bookmark.listType = kListType_favorite;
                }else if ([page.type isEqualToString:TYPE_FOLDER]){
                    bookmark.listType = kListType_folder;
                }
                
                
                [self.navigationController pushViewController:bookmark animated:YES];
                
            }
        }

    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

//編集中にセルをハイライトしない
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEditing) {
        Page* page = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if ([page.type isEqualToString:TYPE_BOOKMARK]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}



/**
 * 移動先のフォルダ選択
 * @param page 移動するPageモデル
 */
- (void)showFolderSelection:(Page*)page
{
    //フォルダ選択
    __weak Page* _page = page;
    GHFoldersListController *folder = [[GHFoldersListController alloc]init];
    [folder setInitialSelection:page.parent];
    
    //フォルダ選択後のコールバック
    [folder setSelectFolder:^(Page* folder){
        _page.parent = folder;
        _page.priority = @([folder.children count] + PRIORITY);
    }];
    
    [self.navigationController pushViewController:folder animated:YES];
}


//--------------------------------------------------------------//
#pragma mark - Fetched results controller
//--------------------------------------------------------------//

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *managedObjectContext = [[GHDataManager shareManager] managedObjectContext];
    
     NSArray* bookmark = [[GHDataManager shareManager]getModelDataByPredicate:[NSPredicate predicateWithFormat:@"type = %@", TYPE_BOOKMARK_FOLDER] withEntityName:@"Page" context:nil];
    
    //categoryが最上位のものを取得
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(parent = nil or parent = %@) and type != %@ ", [bookmark firstObject], TYPE_BOOKMARK_FOLDER];
    NSFetchRequest *fetchRequest = [[GHDataManager shareManager]fetchRequest:pred withEntityName:@"Page"];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:managedObjectContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    LOG(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            GHBookmarkCell *cell = (GHBookmarkCell *)[tableView cellForRowAtIndexPath:indexPath];
            Page* page = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [cell configureCell:page atIndexPath:indexPath isEditing:isEditing];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    [self.tableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (indexPath.row < 2) {
         return NO;
     }
     
     return YES;
 }


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_METHOD
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Page *delete = (Page*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [[GHDataManager shareManager]deleteEntity:delete];
        [[GHDataManager shareManager]save];
    }
}



 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
     Page* fromPage = [self.fetchedResultsController objectAtIndexPath:fromIndexPath];
     NSNumber *fromPriority = fromPage.priority;
     
     Page* toPage   = [self.fetchedResultsController objectAtIndexPath:toIndexPath];
     NSNumber *toPriority = toPage.priority;
     
     fromPage.priority = toPriority;
     toPage.priority = fromPriority;
     
     [[GHDataManager shareManager]save];
 }



 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (indexPath.row < 2) {
         return NO;
     }
     
     return YES;
     
 }


//特定のセルのみを固定
- (NSIndexPath*)tableView:(UITableView*)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath
      toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath
{
    if (  (proposedDestinationIndexPath.row > 1) && (proposedDestinationIndexPath.section == sourceIndexPath.section)) {
        return proposedDestinationIndexPath;
    } else {
        return sourceIndexPath;
    }
}



//--------------------------------------------------------------//
#pragma mark - segue
//--------------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Page*)page
{
    if ([[segue identifier] isEqualToString:TYPE_BOOKMARK]) {
        GHBookmarkViewController *bookmark = segue.destinationViewController;
        bookmark.parent = page;
        
        if ([page.type isEqualToString:TYPE_FAVORITE]) {
            //お気に入り
            bookmark.listType = kListType_favorite;
        }else if ([page.type isEqualToString:TYPE_FOLDER]){
            bookmark.listType = kListType_folder;
        }
    }
}




@end
