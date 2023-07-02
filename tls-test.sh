# list of recognised applications
# 11 - curl tls-client
# 21 - openssl tls-client
# 31 - grep


# colour definitions
RED='\033[0;31m';
BLUE='\033[0;34m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
NOCOLOR='\033[0m';

GENERALERROR=0;

# functions
grep_handler()
{
    echo "Grep return value handler";
    echo "returned $1";
    echo "sign: $2";
    GENERALERROR=0;

    # start return value handling using nested IFs as per category
    if [ $1 -eq 0 ]
    then
        echo "found expression...";
        if [ $3 -eq $4 ]
        then
            echo "in desired number";
        else
            echo "NOT in desired number";
            GENERALERROR=1;
        fi
    else
        echo "could not find expression";
    fi
}

openssl_handler()
{
    echo "Openssl return value handler";
    echo "returned $1";
    echo "sign: $2";
    GENERALERROR=0;

    # start return value handling using nested IFs as per category
    if [ $1 -eq 0 ]
    then
        echo "certificate fetched";
    else
        echo "could not fetch certificate";
        GENERALERROR=1;
    fi
}

curl_handler()
{
    echo "Curl return value handler";
    echo "returned $1";
    echo "sign: $2";
    GENERALERROR=0;

    # start return value handling using nested IFs as per category
    if [ $1 -eq 3 ]
    then
        echo "bad domain";
        GENERALERROR=1;
    else
        if [ $1 -eq 4 ]
        then
            echo "unsupported feature - this is an error of your environment!";
            GENERALERROR=1;
        else
            if [ $1 -eq 6 ]
            then
                echo "bad domain";
                GENERALERROR=1;
            else
                if [ $1 -eq 0 ]
                then
                    echo "connection established";
                else
                    if [ $1 -eq 35 ]
                    then
                        echo "connection declined for unsupported TLS version or cipher suite";
                    else
                        echo "Unexpected return value!";
                    fi
                fi
            fi
        fi
    fi
}


# this function expects three arguments: 
# arg1 : return value of previous command 
# arg2 : application id (from list of recognised applications)
# arg3 : sign (-1 - negative; 0 - neutral; 1 - positive)
# arg<n> : test specific purpose
return_value_handler()
{
    if [ $2 -eq 11 ]
    then
        curl_handler $1 $3;
    else
        if [ $2 -eq 21 ]
        then
            openssl_handler $1 $3;
        else
            if [ $2 -eq 31 ]
            then
                grep_handler $1 $3 $4 $5;
            else
                echo "Unknown application to handle return value!";
                echo "returned $1";
                echo "app: $2";
                echo "sign: $3";
            fi
        fi
    fi
    # interpret and colour verdict
    if [ $3 -eq 0 ]
    then
        echo "${BLUE}IRRELEVANT (at the moment)${NOCOLOR}";
    else
        if [ $GENERALERROR -eq 1 ]
        then
            echo "${RED}BAD${NOCOLOR}";
        else
            if [ $1 -eq 0 ] && [ $3 -eq 1 ]
            then
                echo "${GREEN}GOOD${NOCOLOR}";
            else
                if [ $1 -ne 0 ] && [ $3 -eq -1 ];
                then
                    echo "${GREEN}GOOD${NOCOLOR}";
                else
                    echo "${RED}BAD${NOCOLOR}";
                fi
            fi
        fi
    fi
}


# main script
DOMAIN=$1;
LOG="log.txt";

# start fresh log with time stamp
date > $LOG;

echo "TLS Test Automator" | tee -a $LOG;

echo "Domain to be tested: $1" | tee -a $LOG;

echo "\n01. Testing TLS 1.1" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.1 --tls-max 1.1 >>$LOG 2>>$LOG;
return_value_handler $? 11 -1

echo "\n02. Testing TLS 1.2" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.2 --tls-max 1.2 >>$LOG 2>>$LOG;
return_value_handler $? 11 1

echo "\n03. Testing TLS 1.3" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.3 --tls-max 1.3 >>$LOG 2>>$LOG;
return_value_handler $? 11 0

echo "\n04. Testing TLS 1.2 using TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.2 --tls-max 1.2 --ciphers ECDHE-ECDSA-AES128-GCM-SHA256 >>$LOG 2>>$LOG;
return_value_handler $? 11 1

echo "\n05. Testing TLS 1.2 using TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.2 --tls-max 1.2 --ciphers ECDHE-ECDSA-AES256-GCM-SHA384 >>$LOG 2>>$LOG;
return_value_handler $? 11 1

echo "\n06. Fetching x509 certificate" | tee -a $LOG;
CERTIFICATE=$(openssl s_client -showcerts -connect $DOMAIN:443 </dev/null 2>>$LOG | openssl x509 -noout -text);
return_value_handler $? 21 1
echo "$CERTIFICATE" >>$LOG;

# this should be done using the OID
echo "\n07. Checking public key algorithm of x509 certificate" | tee -a $LOG;
OCCURENCES=$(echo "$CERTIFICATE" | grep -c 'Public Key Algorithm: id-ecPublicKey');
return_value_handler $? 31 1 $OCCURENCES 1
