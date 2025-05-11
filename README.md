# [XCResultExtractor](https://github.com/ChrisMash/XCResultExtractor)

A tool to extract all console logs from an `.xcresult `, rather than just the 
test runner's logs you usually see in Xcode (but it can extract those too).

Driven by both a long term struggle with the logs missing from CI test runs and [henrique](https://stackoverflow.com/a/77989536/1751266)'s solution on StackOverflow.

## Usage

### Python [DEPRECATED]

Note: The Python version is deprecated and won't see further development as it's being replaced by a Swift version

To extract the app's console logs from an `.xcresult` pass it the path to it and specify
your app's bundle ID. It'll output the logs to a file in the same directory called `output.txt`.

So in the `Python` folder you can run:

```bash
python3 xcresult_extractor.py --file ../TestApp.xcresult --bundleID com.chrismash.TestApp
```

To extract the test runner logs simply omit the `bundleID` arg

```bash
python3 xcresult_extractor.py --file ../TestApp.xcresult
```

### Swift

This version is a bit more advanced. It extracts all the logs from the `.xcresult` without needing a bundle ID.

You can try it out in the `Swift/XCResultExtractor` folder by running:

```shell
swift run XCResultExtractor ../../TestApp.xcresult
```

## Getting an `.xcresult`

There's an example `.xcresult` in this repo (generated from the test app in the repo) that you can try the script with, or if you want to get your own from Xcode:

* Run your UI tests
* Select the Product -> Show build folder in finder menu option
* Navigate to Logs/Tests/ and you should see your `.xcresult` file(s) there
