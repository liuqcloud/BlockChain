var path = require('path');
var fs = require('fs');
var url = require('url');
var express = require('express');
var querystring =require('querystring');

const { ContractsDir, ContractsOutputDir } = require('../constant');
const {  getAbi } = require('../interfaces/base');
const utils = require('../nodejs-sdk/packages/api/common/utils');
const   Web3jService = require('../nodejs-sdk/packages/api/web3j').Web3jService;

var nodeApi = new Web3jService();
var router = express.Router();


/* 部署合约 */
router.get("/deploy", function(req, res, next){
    let contractName = "SupplyChain";
    if (!contractName.endsWith('.sol')) {
        contractName += '.sol';
    }

    let contractPath = path.join(ContractsDir, contractName);
    if (!fs.existsSync(contractPath)) {
        throw new Error(`${contractName} doesn't exist`);
    }
    let outputDir = ContractsOutputDir;

    nodeApi.deploy(contractPath, outputDir).then(result => {
        let contractAddress = result.contractAddress;
        if (result.status === '0x0') {
            let addressPath = path.join(outputDir, `.${path.basename(contractName, '.sol')}.address`);

            try {
                fs.appendFileSync(addressPath, contractAddress + '\n');
            } catch (error) { }
        }
        res.status(200)
        res.json({
            message: "success",
            data: {
                contractAddress: result.contractAddress,
                status: result.status,
                deployer: result.from
             }
        })
    });
});

module.exports = router;