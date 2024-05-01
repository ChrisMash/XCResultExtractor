# A script to extract app logs from an .xcresult file
#
# Repo: https://github.com/ChrisMash/XCResultExtractor
# Inspiration: https://stackoverflow.com/a/77989536/1751266
#
# Example usage:
#   Help:
#       python3 xcresult_extractor.py --help
#
#   Extract the app logs (rather than the UI test runner logs):
#       python3 xcresult_extractor.py --file YourTestApp.xcresult --bundleID com.yourapp.bundleid
#
#   Extract the test runner logs:
#       python3 xcresult_extractor.py --file YourTestApp.xcresult

import re
import subprocess
import argparse

# Returns the parsed command line arguments
def parseArgs():
    usage = """
    A script to extract app logs from an .xcresult file

    Inspired by https://stackoverflow.com/a/77989536/1751266

    Example usage:
        Help:
            python3 xcresult_extractor.py --help

        Extract the app logs (rather than the UI test runner logs):
            python3 xcresult_extractor.py --file YourTestApp.xcresult --bundleID com.yourapp.bundleid

        Extract the test runner logs:
            python3 xcresult_extractor.py --file YourTestApp.xcresult
    """
    parser = argparse.ArgumentParser(usage=usage)
    required = parser.add_argument_group('required arguments')
    required.add_argument("-f", "--file", dest="xcresultFilename", help="The path to the .xcresult", type=str, action='store', required=True)
    optional = parser.add_argument_group('optional arguments')
    optional.add_argument("-b", "--bundleID", dest="appBundleID", help="The bundle ID of the app", type=str, action='store', required=False)
    return parser.parse_args()

def fileIDOfAppOutput(xcresultFilename, targetFilename):
    graphOutput = subprocess.Popen(f"xcrun xcresulttool graph --path {xcresultFilename}/",
                                   shell=True, 
                                   stdout=subprocess.PIPE).stdout.read().decode("utf-8")
    if len(graphOutput) == 0:
        raise Exception("Failed to extract graph")
    
    # Example output
    #   + simctl_diagnostics (directory)
    #     * CASTree (file or dir)
    #       - Id: 0~25-SBMpEEjRCXcLwupSdWQBlS8RCau8odsmUGfQPktbOq5wKLXaEGP1EhCOVhImnOlbY8e639n9Ps40t-Yq43Q==
    #       - Size: 116
    #       - Refs: 2
    #       + UITests-CC24B8C3-5437-4F76-8EC4-B78B9C24FEDF (directory)
    #       + scheduling.log (plainFile)
    #         * CASTree (file or dir)
    #           - Id: 0~uEROczRoGKiv0pXR2bm7bBTxCk78-CMEoMo4CPimd7uUXqhLzUiYgR07LcP3ADeW2u7co8_XYO1dGW8WNWjEGQ==
    #           - Size: 225
    #           - Refs: 3
    #           + Session-UITests-2024-04-25_095420-64l3KG.log (plainFile)
    #           + StandardOutputAndStandardError-bundleID.txt (plainFile)
    #           + StandardOutputAndStandardError.txt (plainFile)
    #             * raw
    #               - Id: 0~gd6vWsbdASWKEZ-kYenn_Goqw3ch-M1K-o54sORTGy8uWBshemh8BHuIdowxZS4LajYmGC_9Fnt4wNaz0_pLtQ==
    #               - Size: 1591522
    #             * raw
    #               - Id: 0~-bsNCAVy64x2HZHr39QgRonGOGCQxNXYJczwVIR_r41rUSUz5DBiR1Fi5HJT1S6xBY1XSrZnZZamROY8u4NJZg==
    #               - Size: 81203
    #             * raw
    #               - Id: 0~F9oqjEmeWiMP1_l-TGsGm9k4saHmYS1ZazThs1BtxF6X0P26_3wAo5RwrSUgzvsPmIz6S65rvikikGNiKtEKsw==
    #               - Size: 27791
    #         * raw
    #           - Id: 0~ofsFTwYoMfBSsUhsvdnNS-t77QYX84NEiZh3mbROqQBB4-pCRWBxD59FFMdsNQ_ltBCm-PnaZIGD1Rs9PMp6Ig==
    #           - Size: 547
    #     * CASTree (file or dir)
    #       - Id: 0~4VqMqsI5lOfxRppnud6-VDWcNsU8J7VgFCJfW2dXPwOcAkvU-I8Um5yp9n0Zv6nr3VmcxYggaVMDFfR0U_vjKw==
    #       - Size: 2

    # Extract the relevant graph output
    search = re.search(f"Refs: (\\s|.)*?{targetFilename}((\\s|.)*?)\\* CASTree", graphOutput, re.IGNORECASE)
    if search:
        outputOfInterest = search.group(0)
        # The regex matches from the first "Refs: " (not good enough at regex to avoid that),
        # so we find the lasts one and know that's the start of the detail we're interested in
        idxLastRef = outputOfInterest.rindex("Refs: ")
        # We get the substring from "Refs: " up to the std out filename
        idxStdOut = outputOfInterest.index(targetFilename)
        refs = outputOfInterest[idxLastRef:idxStdOut]
        # And we count the number of "+" characters to find the index of the std out filename in the list
        refNum = refs.count("+")
        # We then take everything after the last "Refs: " and split on the "*" characters,
        # which gives us an array of the file IDs we can index into
        ids = outputOfInterest[idxLastRef:].split("*")
        # We extract the file ID from the correct chunk of the output
        search = re.search("Id: (.*)", ids[refNum], re.IGNORECASE)
        if search:
            fileID = search.group(1)
            return fileID
        else:
            raise Exception("Failed to find file ID")
    else:
        raise Exception("Failed to find relevant graph output")

if __name__ == '__main__':
    args = parseArgs()

    targetFilename = "StandardOutputAndStandardError.txt"
    if args.appBundleID != None:
        targetFilename = f"StandardOutputAndStandardError-{args.appBundleID}.txt"

    print("Searching for file ID...")
    fileID = fileIDOfAppOutput(args.xcresultFilename,
                               targetFilename)

    print("Extracting console logs...")
    outputPath = "./output.txt"
    cmdOutput = subprocess.Popen(f"xcrun xcresulttool export --type file --path {args.xcresultFilename}/ --output-path {outputPath} --id {fileID}", 
                                shell=True, 
                                stdout=subprocess.PIPE).stdout.read().decode("utf-8")
    if len(cmdOutput) == 0:
        print("App output saved to ./output.txt")
    else:
        print(cmdOutput)
