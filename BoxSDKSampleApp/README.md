BoxSDKSampleApp
===============

This is a sample app that integrates with the Box iOS SDK.

It demonstrates the following:

* Authentication
  * storing credentials
  * automatic login when the user becomes logged out
* Getting a folder's items
* Deleting items and manipulating the trash
* Copying files
* File uploads
* File downloads and preview

To get started:

1. The Box SDK is embedded as a submodule: `git submodule init && git submodule update`
2. Configure the app with your client ID and client secret. There
are `#error`s in the project to help point you in the right direction.
