export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../crypto-config/ordererOrganizations/iimudaipur.com/orderers/orderer.iimudaipur.com/msp/tlscacerts/tlsca.iimudaipur.com-cert.pem
export PEER0_iimudaipur_CA=${PWD}/../crypto-config/peerOrganizations/iimudaipur.com/peers/peer0.iimudaipur.com/tls/ca.crt
export PEER1_iimudaipur_CA=${PWD}/../crypto-config/peerOrganizations/iimudaipur.com/peers/peer1.iimudaipur.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../config/
# export PEER0_rta_CA=${PWD}/../crypto-config/peerOrganizations/rta.vlm.com/peers/peer0.rta.vlm.com/tls/ca.crt

export CHANNEL_NAME=iimchannel

export CC_RUNTIME_LANGUAGE="node"
export VERSION="1"
export SEQUENCE="1"
export CC_SRC_PATH="${PWD}/../../chaincode/javascript"
export CC_NAME="recordManagement"

setGlobalsForPeer0iimudaipur(){
    export CORE_PEER_LOCALMSPID="iimudaipurMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_iimudaipur_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../crypto-config/peerOrganizations/iimudaipur.com/users/Admin@iimudaipur.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1iimudaipur(){
    export CORE_PEER_LOCALMSPID="iimudaipurMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_iimudaipur_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../crypto-config/peerOrganizations/iimudaipur.com/users/Admin@iimudaipur.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

presetup() {
    echo Installing Node dependencies ...
    pushd $CC_SRC_PATH
    npm install
    popd
    echo Installed Node dependencies Successfully
}

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0iimudaipur
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
    echo "===================== Installing chaincode on peer0.iimudaipur ===================== "
    setGlobalsForPeer0iimudaipur
    # sleep 2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.iimudaipur ===================== "

    echo "===================== Installing chaincode on peer1.iimudaipur ===================== "
    setGlobalsForPeer1iimudaipur
    # sleep 2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.iimudaipur ===================== "

}

queryInstalled() {
    setGlobalsForPeer0iimudaipur
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    export PACKAGE_ID=$(sed -n "/$CC_NAME_$VERSION/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo "===================== Query installed successful  ===================== "
}

approveByIIMUdaipur() {
    setGlobalsForPeer0iimudaipur
    # set -x
    # Replace localhost with your orderer's vm IP address

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.iimudaipur.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --sequence ${SEQUENCE} --package-id ${PACKAGE_ID}\
        --init-required  
    # set +x

    echo "===================== chaincode approved by IIMUdaipur ===================== "

}

checkCommitReadyness() {
    echo "===================== checking commit readyness ===================== "
    setGlobalsForPeer0iimudaipur
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${SEQUENCE} --output json --init-required
    
}

commitChaincodeDefination() {
    echo "===================== Commiting Chaincode ===================== "
    setGlobalsForPeer0iimudaipur
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.iimudaipur.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_iimudaipur_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required
}

# commitChaincodeDefinationonpeer1() {
#     echo "===================== Commiting Chaincode ===================== "
#     setGlobalsForPeer0iimudaipur
#     peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.iimudaipur.com \
#         --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
#         --channelID $CHANNEL_NAME --name ${CC_NAME} \
#         --peerAddresses localhost:9051 --tlsRootCertFiles $PEER1_iimudaipur_CA \
#         --version ${VERSION} --sequence ${SEQUENCE} --init-required
# }

queryCommitted() {
    setGlobalsForPeer0iimudaipur
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvokeInit() {
    setGlobalsForPeer0iimudaipur
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.iimudaipur.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_iimudaipur_CA \
        --isInit -c '{"Args":[]}'

}

chaincodeInvokeinitLedger() {
    setGlobalsForPeer0iimudaipur
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.iimudaipur.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_iimudaipur_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER1_iimudaipur_CA \
        -c '{"function":"initLedger","Args":[]}'

}

presetup
packageChaincode
installChaincode
queryInstalled
approveByIIMUdaipur
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 3
chaincodeInvokeinitLedger

