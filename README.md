# XCResultExtractor

A Python script to extract app console logs from an `.xcresult `, rather than just the 
test runner's logs you usually see (but it can extract those too).

Inspired by both a long term struggle with the logs missing from CI test runs and [henrique](https://stackoverflow.com/a/77989536/1751266)'s solution on StackOverflow.

## Usage

To extract the app's console logs from an `.xcresult` pass it the path to it and specify
your app's bundle ID. It'll output the logs to a file in the same directory called `output.txt`.

```bash
python3 xcresult_extractor.py --file YourTestApp.xcresult --bundleID com.yourapp.bundleid
```

To extract the test runner logs simply omit the `bundleID` arg

```bash
python3 xcresult_extractor.py --file YourTestApp.xcresult
```

## Getting an `.xcresult`

There's an example `.xcresult` in this repo (generated from the test app in the repo) that you can try the script with, or if you want to get your own from Xcode:

* Run your UI tests
* Select the Product -> Show build folder in finder menu option
* Navigate to Logs/Tests/ and you should see your `.xcresult` file(s) there
