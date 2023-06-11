# list of recognised applications
# 11 - curl


# colour definitions
RED='\033[0;31m';
BLUE='\033[0;34m';
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
NOCOLOR='\033[0m';


# functions
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
            if [ $1 -eq 0 ]
            then
                echo "connection established";
            else
                if [ $1 -eq 35 ]
                then
                    echo "connection declined for unsupported TLS version";
                else
                    echo "Unexpected return value!";
                fi
            fi
        fi
    fi
    # interpret and colour verdict
    if [ $2 -eq 0 ]
    then
        echo "${BLUE}IRRELEVANT (at the moment)${NOCOLOR}";
    else
        if [ $GENERALERROR -eq 1 ]
        then
            echo "${RED}BAD${NOCOLOR}";
        else
            # wir sind im normalen track
            if [ $1 -eq 0 ] && [ $2 -eq 1 ]
            then
                echo "${GREEN}GOOD${NOCOLOR}";
            else
                if [ $1 -ne 0 ] && [ $2 -eq -1 ];
                then
                    echo "${GREEN}GOOD${NOCOLOR}";
                else
                    echo "${RED}BAD${NOCOLOR}";
                fi
            fi
        fi
    fi
}


# this function expects three arguments: 
# arg1 : return value of previous command 
# arg2 : application id (from list of recognised applications)
# arg3 : sign (-1 - negativ; 0 - neutral; 1 - positive)
return_value_handler()
{
    if [ $2 -eq 11 ]
    then
        curl_handler $1 $3;
    else
        echo "Unknown application to handle return value!";
        echo "returned $1";
        echo "app: $2";
        echo "sign: $3";
    fi
    
}


# main script
DOMAIN=$1;
LOG="log.txt";

# start fresh log with time stamp
date > $LOG;

echo "TLS Test Automator" | tee -a $LOG;

echo "Domain to be tested: $1" | tee -a $LOG;

echo "\nTesting TLS 1.1" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.1 --tls-max 1.1 >>$LOG 2>>$LOG;
return_value_handler $? 11 -1

echo "\nTesting TLS 1.2" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.2 --tls-max 1.2 >>$LOG 2>>$LOG;
return_value_handler $? 11 1

echo "\nTesting TLS 1.3" | tee -a $LOG;
curl https://$DOMAIN --verbose --tlsv1.3 --tls-max 1.3 >>$LOG 2>>$LOG;
return_value_handler $? 11 0
