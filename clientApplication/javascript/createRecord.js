'use strict';

const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');
async function main(rollNumber,studentName,yearPassing,programName,durationProgram,certificateHash,documentFormat,documentType) {

    try {
      
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..','connection-Profile', 'ccp-iimudaipur.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('admin');
        if (!identity) {
            console.log('An identity for the user "admin" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: 'admin', discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('iimchannel');

        // Get the contract from the network.
        const contract = network.getContract('recordManagement');

        // Submit the specified transaction
        await contract.submitTransaction("createRecord", rollNumber,studentName,yearPassing,programName,durationProgram,certificateHash,documentFormat,documentType);
        console.log('Transaction has been submitted');

        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        console.error(`Failed to submit transaction: ${error}`);
        process.exit(1);
    }
}

module.exports.execute = main

