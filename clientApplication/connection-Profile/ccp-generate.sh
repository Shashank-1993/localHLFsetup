#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $5)
    local CP=$(one_line_pem $6)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s/\${P1PORT}/$4/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.json
}

ORG=iimudaipur
P0PORT=7051
P1PORT=9051
CAPORT=7054
PEERPEM=/home/ubuntu/RecordManagement/fabricNetwork/crypto-config/peerOrganizations/iimudaipur.com/tlsca/tlsca.iimudaipur.com-cert.pem
CAPEM=/home/ubuntu/RecordManagement/fabricNetwork/crypto-config/peerOrganizations/iimudaipur.com/ca/ca.iimudaipur.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $P1PORT $PEERPEM $CAPEM)" > ./ccp-iimudaipur.json
