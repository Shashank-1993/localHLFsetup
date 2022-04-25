'use strict';

const { Contract } = require('fabric-contract-api');
const crypto = require("crypto");

var QueryUtil = require('./QueryUtils.js');
var QueryUtils = new QueryUtil();

class RecordManagement extends Contract {

    async initLedger(ctx) {
        console.info('chaincode initialised');
    }

    //Query Student Record by Roll number
    async queryRecordByRollno(ctx, roll_Number) {

        let queryString = {};
        queryString.selector = {};
        queryString.selector.rollNumber = roll_Number;
        let data = await QueryUtils.GetQueryResultForQueryString(ctx, JSON.stringify(queryString))
        
        let items = JSON.parse(data.toString());
        console.log(items)

        return items;
    }

    //Query Student Record by hashCode
    async queryRecordByHashCode(ctx, certificateHash) {

        let queryString = {};
        queryString.selector = {};
        queryString.selector.certificateHash = certificateHash;
        let data = await QueryUtils.GetQueryResultForQueryString(ctx, JSON.stringify(queryString))
        
        let items = JSON.parse(data.toString());
        console.log(items)

        return items;
    }

    async createRecord(ctx, rollNumber, studentName, yearPassing, programName, 
        durationProgram,certificateHash,documentFormat,documentType) {
        console.info('============= START : Create Record ===========');
        
        const recordKey = crypto.randomBytes(16).toString("hex");

        console.log("key"+recordKey);

        const studentData = {
            "rollNumber" : rollNumber,
            "studentName" : studentName,
            "yearPassing" : yearPassing,
            "programName" : programName,
            "durationProgram" : durationProgram,
            "certificateHash" : certificateHash,
            "documentFormat" : documentFormat,
            "documentType" : documentType
        };
    
        await ctx.stub.putState(recordKey, Buffer.from(JSON.stringify(studentData)));
        console.info('============= END : Create Records ===========');
    }

    async queryAllRecords(ctx) {
        const startKey = '';
        const endKey = '';
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange(startKey, endKey)) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: key, Record: record });
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

    // async changeCarOwner(ctx, carNumber, newOwner) {
    //     console.info('============= START : changeCarOwner ===========');

    //     const carAsBytes = await ctx.stub.getState(carNumber); // get the car from chaincode state
    //     if (!carAsBytes || carAsBytes.length === 0) {
    //         throw new Error(`${carNumber} does not exist`);
    //     }
    //     const car = JSON.parse(carAsBytes.toString());
    //     car.owner = newOwner;

    //     await ctx.stub.putState(carNumber, Buffer.from(JSON.stringify(car)));
    //     console.info('============= END : changeCarOwner ===========');
    // }

}

module.exports = RecordManagement;


//Pending

// Couchdb selector Query formation to query by 
// rollNumber
// certificateHash