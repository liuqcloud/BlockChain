var path = require('path');
var fs = require('fs');
var url = require('url');
var express = require('express');
var querystring =require('querystring');

const { getAbi } = require('../interfaces/base');
const utils = require('../nodejs-sdk/packages/api/common/utils');
const Web3jService = require('../nodejs-sdk/packages/api/web3j').Web3jService;

var nodeApi = new Web3jService();
var router = express.Router();

router.get("/listBank", function(req, res, next){
    let contractName = "SupplyChain";
    let contractAddress ="0x4b112b3117688989b47ba84798c57b28604c0739";
    let functionName = "findAllBank";
    let parameters =  [];

    let abi = getAbi(contractName);

    for (let item of abi) {
        if (item.name === functionName && item.type === 'function') {

        functionName = utils.spliceFunctionSignature(item);

        if (item.constant) {
            nodeApi.call(contractAddress, functionName, parameters).then(result => {
                let status = result.result.status;
                let ret = {
                    status: status
                };
                    let output = result.result.output;
                    if (output !== '0x') {
                        ret.output = utils.decodeMethod(item, output);
                    }
                    ret.output['3'] = ret.output['3'].split(",");
                    res.status(200)
                    res.json({
                        message: "success",
                        data: ret
                    })
                });
            } else {
                nodeApi.sendRawTransaction(contractAddress, functionName, parameters).then(result => {
                    let txHash = result.transactionHash;
                    let status = result.status;
                    let ret = {
                        transactionHash: txHash,
                        status: status
                    };
                    let output = result.output;
                    if (output !== '0x') {
                        ret.output = utils.decodeMethod(item, output);
                    }
                    res.status(200)
                    res.json({
                        message: "success",
                        data: ret
                    })
                });
            }
        }
    }
});

module.exports = router;