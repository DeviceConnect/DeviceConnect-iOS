//
//  ShareViewController.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <BookmarkDBFramework/GHURLManager.h>

@interface ShareViewController ()
@property (nonatomic, strong) Page* directory;
@property (nonatomic) NSArray* favorites;
@property (nonatomic) NSUInteger directoryCount;
#pragma mark - UI Parts
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UIPickerView *folderPlacePicker;

#pragma mark - Constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *folderWidthSize;

@end

@implementation ShareViewController

#pragma mark - ViewController Delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
    _folderPlacePicker.delegate = self;
    _folderPlacePicker.dataSource = self;
    
    [self rotateOrientation];
    [self scanHTMLInfo];
    [self readDirectoryList];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self rotateOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}
- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

#pragma mark - bar button event

- (IBAction)addBookmark:(id)sender {
    if (self.titleField.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"dConnectBrowser"
                                                                                 message:@"タイトルを入力してください"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    } else if (self.urlField.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"dConnectBrowser"
                                                                                 message:@"URLを入力してください"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //DBへ保存処理
    [GHURLManager addBookMark:self.titleField.text url:self.urlField.text parent:self.directory];
    
    [self.extensionContext cancelRequestWithError:nil];
}
- (IBAction)cancel:(id)sender {
    [self.extensionContext cancelRequestWithError:nil];
}

#pragma mark - private method
- (void)rotateOrientation
{
    CGSize screen = [UIScreen mainScreen].bounds.size;
    CGFloat size = screen.width;
    if (size < screen.height) {
        size = screen.height;
    }
    _titleWidthSize.constant = (size / 2) - 33;
    _urlWidthSize.constant = (size / 2) - 33;
    _folderWidthSize.constant = (size / 2) - 33;
    [self.view setNeedsUpdateConstraints];
}

- (void)scanHTMLInfo
{
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *jsDict, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *jsPreprocessingResults = jsDict[NSExtensionJavaScriptPreprocessingResultsKey];
                        NSString *selectedText = jsPreprocessingResults[@"selection"];
                        NSString *pageTitle = jsPreprocessingResults[@"title"];
                        NSString *url = jsPreprocessingResults[@"URL"];
                        NSString *showMessage = @"";
                        if ([selectedText length] > 0) {
                            showMessage = selectedText;
                        } else if ([pageTitle length] > 0) {
                            showMessage = pageTitle;
                        }
                        _titleField.text = showMessage;
                        _urlField.text = url;
                    });
                }];
                
                break;
            }
        }
        
    }

}

- (void)readDirectoryList
{
    //初期位置はお気に入り
    _favorites = [[GHDataManager shareManager] getModelDataByPredicate:[NSPredicate predicateWithFormat:@"type = %@ OR type = %@ OR type = %@", TYPE_FAVORITE, TYPE_BOOKMARK_FOLDER, TYPE_FOLDER] withEntityName:@"Page" context:nil];
    
    _directoryCount = [_favorites count];
    if ([_favorites count] > 0) {
        self.directory = [_favorites firstObject];
    }
}

#pragma mark - Picker Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView*)pickerView
numberOfRowsInComponent:(NSInteger)component{
    
    return _favorites.count;
}

-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    Page *page = _favorites[row];
    return page.title;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _directory = _favorites[row];
}
@end
