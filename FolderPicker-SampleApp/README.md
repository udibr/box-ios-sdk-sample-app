This application demonstrates integrating with the Box SDK folder picker.

The folder picker lets you customize how you want your users to interact with their Box accounts.

In order to get started, all you need to do is instantiate a BoxFolderPickerViewController via this method located in `BoxSDK.h`

```objc
- (BoxFolderPickerViewController *)folderPickerWithRootFolderID:(NSString *)rootFolderID 
                                               thumbnailsEnabled:(BOOL)thumbnailsEnabled 
                                           cachedThumbnailsPath:(NSString *)cachedThumbnailsPath
                                           fileSelectionEnabled:(BOOL)fileSelectionEnabled;
```

`rootFolderID` allows you to set the base folder of your folder picker. `@"0"` is the root folder.

`thumbnailsEnabled` allows you to specified if you want thumbnail to be displayed in the folderPicker.

`cachedThumbnailsPath` allows you, if `thumbnailsEnabled` is set to `YES`, to customize the location of your cached thumbnails. You can also set it to nil. In this case, the thumbnails will only be cached in memory and will not be available between multiple browsing sessions in the folder picker.

`fileSelectionEnabled` allows you to specify if the user can select a file.

Implement the `BoxFolderPickerDelegate` protocol to get callbacks for items selection.