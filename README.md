# TLS Testing
Scripts for TLS Test Automation

The shell script in this repository performs different tests against chosen servers. A list of performed tests and their purpose can be found in the table below.

## Requirements
The given script assumes the following packages to be installed:
* tee
* curl (tested: 7.81.0, 7.88.1)
* OpenSSL (tested: 3.0.2, 3.1.1)

__Note:__ LibreSSL is not an adequate substitute for OpenSSL with regard to its behaviour when using it as a tls-client (s_client option) to download certificates! It will not neccessarily run into errors but produce varying output when fetching certificates from servers with more than one virtual host. Not sure if this is the server's fault (tested with nginx) or LibreSSL's, yet using openssl produces output as expected.

The script should be fine with the standard shell (sh). Yet, it has only been tested with bash and zsh.

## Tests

| # | Name    | Description                                                               | Intended Outcome                                                            |
|---|---------|---------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| 1 | TLS 1.1 | This test checks whether the targeted TLS server supports TLS version 1.1. | TLS 1.1 connections must be declined by the server for this test to succeed. |
| 2 | TLS 1.2 | This test checks whether the targeted TLS server supports TLS version 1.2. | TLS 1.2 connections must be accepted by the server for this test to succeed. |
| 3 | TLS 1.3 | This test checks whether the targeted TLS server supports TLS version 1.3. | TLS 1.3 is neither required, nor forbidden. Yet, support for TLS 1.3 may be nice to know. |
| 4 | TLS 1.2 ECC-1 | This test checks whether the targeted TLS server supports TLS version 1.2 using the cipher suite TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256 | Cipher suite must be accepted by the server for this test to succeed. |
| 5 | TLS 1.2 ECC-2 | This test checks whether the targeted TLS server supports TLS version 1.2 using the cipher suite TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 | Cipher suite must be accepted by the server for this test to succeed. |
| 6 | x509 fetch | Ability to fetch the x509 certificate is not a test but a pre-condition for subsequent tests for parameters | Download must be successfull for subsequent checks |
| 7 | x509 pubkey algorithm | Checks the x.509 certificate's public key algorithm by grepping for the respective expression when printing the certificate using openssl (ToDO: This should be turned into a check for OID in the ASN.1 representation) | Expression 'Public Key Algorithm: id-ecPublicKey' must be found exactly once |

## Usage
Currently, the behaviour of this script cannot be altered through passing parameters as arguments or dedicated config files. The only argument that the script expects is the domain name of the server to be tested.

```
# assuming you want to test the server at https://test.my.domain
sh ./tls-test.sh test.my.domain
```
## Output
The script will print a summary of interpeted results on the console. For an in-depth analysis of what happened, stdout and stderr of all calls are written to log.txt in the directory from where the script is called.