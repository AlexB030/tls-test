# TLS Testing
Scripts for TLS Test Automation

The shell script in this repository performs different tests against chosen servers. A list of performed tests and their purpose can be found in the table below.

## Requirements
The given script assumes the following packages to be installed:
* tee
* curl (tested: 7.81.0, 7.88.1)
* suported SSL library, e.g. OpenSSL (tested: 3.0.2) or LibreSSL (tested: 3.3.6)

The script should be fine with the standard shell (sh). Yet, it has only been tested with bash and zsh.

## Tests

| # | Name    | Description                                                               | Intended Outcome                                                            |
|---|---------|---------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| 1 | TLS 1.1 | This test checks whether the targeted TLS server supports TLS version 1.1. | TLS 1.1 connections must be declined by the server for this test to succeed. |
| 2 | TLS 1.2 | This test checks whether the targeted TLS server supports TLS version 1.2. | TLS 1.2 connections must be accepted by the server for this test to succeed. |
| 3 | TLS 1.3 | This test checks whether the targeted TLS server supports TLS version 1.3. | TLS 1.3 is neither required, nor forbidden. Yet, support for TLS 1.3 may be nice to know. |

## Usage
Currently, the behaviour of this script cannot be altered through passing parameters as arguments or dedicated config files. The only argument that the script expects is the domain name of the server to be tested.

```
# assuming you want to test the server at https://test.my.domain
sh ./tls-test.sh test.my.domain
```
## Output
The script will print a summary of interpeted results on the console. For an in-depth analysis of what happened, stdout and stderr of all calls are written to log.txt in the directory from where the script is called.