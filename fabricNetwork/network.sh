Value=$1
#echo "$Value"
function generatefiles(){

echo "============================= step1: create crypto-config folder ==========================="

cryptogen generate --config=./crypto-config.yaml

mkdir channel-artifacts
echo "=========================== step2: create genesis file ======================"

export FABRIC_CFG_PATH=$PWD

configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

echo "============================= step3: create channel.tx ======================="

export CHANNEL_NAME=iimchannel  && configtxgen -profile OneOrgsChannel -outputCreateChannelTx ./channel-artifacts/iimchannel.tx -channelID $CHANNEL_NAME


echo "======================================= step4 create anchor.tx file ==========================="

configtxgen -profile OneOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/iimudaipurMSPanchors.tx -channelID $CHANNEL_NAME -asOrg iimudaipurMSP

}

function networkfiles(){

cd docker
echo "======================================== CA ====================================="
docker-compose -f docker-compose-ca.yaml up -d
sleep 5
echo "=============================================== Cli ======================================"
docker-compose -f docker-compose-cli.yaml up -d
sleep 5
echo "======================================== Peer's and Orderer's =================================="
docker-compose -f docker-compose-couchdb.yaml -f docker-compose-test-net.yaml up -d
sleep 5
echo "============================================== Display Runing containers=========================="
docker ps 

}

function dismantial(){
echo "================================== Delete crypto-config Folder ========================================"
rm -rf crypto-config
echo "======================================= Delete channel-artifacts Folder ===================================="
rm -rf channel-artifacts
echo "======================================= Remove all containers ===================================="
docker rm -f $(docker ps -qa)
echo " ============================================= Reomve all the Volumes =================================="
docker system  prune --volumes
}

function Createchannel(){
    cd ../scripts/
    ./channel.sh
}

function deployChaincode(){
    cd ./scripts/
    ./deployCC.sh
}


if  [ "$Value" == "up" ]; then
  generatefiles
  sleep 5
  networkfiles
elif [ "$Value" == "createChannel" ]; then
  
  generatefiles
  sleep 5
  networkfiles
  sleep 5
  Createchannel
elif [ "$Value" == "down" ]; then
  
  dismantial 
elif [ "$Value" == "deployCC" ]; then
  deployChaincode   
else
  echo "===============================Error Occured========================================="
fi