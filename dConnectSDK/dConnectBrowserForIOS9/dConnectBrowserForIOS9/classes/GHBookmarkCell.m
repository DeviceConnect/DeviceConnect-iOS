//
//  GHBookmarkCell.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHBookmarkCell.h"

@implementation GHBookmarkCell

/**
 * セルの表示内容をセット
 * @param page Pageモデル
 * @param indexPath indexPath
 * @param controller NSFetchedResultsController
 */
- (void)configureCell:(Page *)page atIndexPath:(NSIndexPath *)indexPath isEditing:(BOOL)isEditing
{
    self.accessoryType = UITableViewCellAccessoryNone;
    self.editingAccessoryType = UITableViewCellAccessoryNone;
    self.myPage = page;

    self.textLabel.text = page.title;

    if ([page.type isEqualToString:TYPE_FAVORITE]) {
        //お気に入り
        self.imageView.image = [UIImage imageNamed:@"star"];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        if (isEditing) {
            self.textLabel.tintColor = [UIColor grayColor];
        }

    }else if ([page.type isEqualToString:TYPE_BOOKMARK]){
        //ブックマーク
        self.imageView.image = [UIImage imageNamed:@"bookmark"];

        //編集中のアクセサリー
        self.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }else if ([page.type isEqualToString:TYPE_FOLDER]){
        //フォルダ
        self.imageView.image = [UIImage imageNamed:@"folder"];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

@end
