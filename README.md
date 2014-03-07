DOBCaptureViewController
========================

This class initialises a QR or Barcode reader View in iOS7 and provides a reusable ViewController in order to display it modally wherever you want.

It is based on [this tutorial from invasivecode](http://weblog.invasivecode.com/post/63692508105/machine-readable-code-ios-7)

Right now is just a proof of concept. I have in mind add more options like selecting the type of codes you want, select if you want flash and vibration switch or not and others...

## How does it work

`DOBCaptureViewController` is a `UIViewController` subclass that adds a layer controlling the device's back camera in order to read QR and barcodes through Apple's native API.

It will return the data through `codeCaptured:` method in `DOBCaptureDelegate`


## Sample

In order to open the `DOBCaptureViewController` as modal view just add this piece of code

```objectivec

        _captureViewController = [[DOBCaptureViewController alloc] init];
        [_captureViewController setCloseAfterRead:YES];
        [_captureViewController setDelegate:self];

        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeCapture:)];
        [_captureViewController.navigationItem setLeftBarButtonItem:button];

        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:_captureViewController];
        [nav.navigationBar setTranslucent:NO];
        [self presentViewController:nav animated:YES completion:nil];

```

In the `closeCapture:` method is up to you to dismiss the view.

The view has the option `setCloseAfterRead` that will automatically dismiss the view for you when the code has been read and returned.


## Requirements
* ARC
* iOS 7

## License
The code is licensed under the MIT license. See the file `LICENSE` for details.