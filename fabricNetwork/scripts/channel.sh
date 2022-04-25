export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../crypto-config/ordererOrganizations/iimudaipur.com/orderers/orderer.iimudaipur.com/msp/tlscacerts/tlsca.iimudaipur.com-cert.pem
export PEER0_iimudaipur_CA=${PWD}/../crypto-config/peerOrganizations/iimudaipur.com/peers/peer0.iimudaipur.com/tls/ca.crt
export PEER1_iimudaipur_CA=${PWD}/../crypto-config/peerOrganizations/iimudaipur.com/peers/peer1.iimudaipur.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../config/
# export PEER0_rta_CA=${PWD}/../crypto-config/peerOrganizations/rta.vlm.com/peers/peer0.rta.vlm.com/tls/ca.crt

export CHANNEL_NAME=iimchannel

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

createChannel(){
    echo "-------------------- Creating Channel ...------------------------"
     setGlobalsForPeer0iimudaipur
    
    # Replace localhost with your orderer's vm IP address
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.iimudaipur.com \
    -f ./../channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./../channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    echo "-------------------- Channel created------------------------"
}

joinChannel(){
    echo "-------------------- peer0 joining Channel ...------------------------"
    setGlobalsForPeer0iimudaipur
    peer channel join -b ./../channel-artifacts/$CHANNEL_NAME.block
    echo "-------------------- peer0 joined Channel ------------------------"

    echo "-------------------- peer1 joining Channel ...------------------------"
    setGlobalsForPeer1iimudaipur
    peer channel join -b ./../channel-artifacts/$CHANNEL_NAME.block
    echo "-------------------- peer1 joined Channel ------------------------"
    
    
}

updateAnchorPeers(){

    echo "-------------------- peer0 updating as AnchorPeer...------------------------"
    setGlobalsForPeer0iimudaipur
    # Replace localhost with your orderer's vm IP address
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.iimudaipur.com -c $CHANNEL_NAME -f ./../channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

createChannel
joinChannel
updateAnchorPeers