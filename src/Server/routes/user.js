var Web3EthAccounts = require('web3-eth-accounts');
var express = require('express');
var router = express.Router();

var account = new Web3EthAccounts('ws://localhost:20200');
const {  getAbi } = require('../interfaces/base');
const utils = require('../nodejs-sdk/packages/api/common/utils');
const Web3jService = require('../nodejs-sdk/packages/api/web3j').Web3jService;
const { CRUDService, Table, Condition, Entry } = require('../nodejs-sdk/packages/api');
let crudService = new CRUDService();

var nodeApi = new Web3jService();
var userTableName = "test3"


router.get("/detail", function(req, res, next){
    let contractName = "SupplyChain";
    let contractAddress ="0x4b112b3117688989b47ba84798c57b28604c0739";
    let functionName = "getUserInfo";
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

router.post("/registerEnterprise", function(req, res, next){
    let contractName = "SupplyChain";
    let contractAddress ="0x4b112b3117688989b47ba84798c57b28604c0739";
    let functionName = "newEnterprise";
    let parameters =  [];
    for(let key in req.body){
        parameters.push(req.body[key]);
    }
    console.log(parameters);
    
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
                    if(ret.output['0'] == "true"){
                        res.status(200)
                        res.json({
                            message: "failed",
                            data: ret
                        })
                    }else{
                        res.status(200)
                        res.json({
                            message: "success",
                            data: ret
                        })
                    }
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
                    if(!ret.output['0']){
                        res.status(200)
                        res.json({
                            message: "failed",
                            data: ret
                        })
                    }else{
                        res.status(200)
                        res.json({
                            message: "success",
                            data: ret
                        })
                    }
                });
            }
        }
    }
});

router.post("/registerThirdParty", function(req, res, next){
    let contractName = "SupplyChain";
    let contractAddress ="0x4b112b3117688989b47ba84798c57b28604c0739";
    let functionName = "newThirdParty";
    let parameters =  [];
    for(let key in req.body){
        parameters.push(req.body[key]);
    }
    console.log(parameters);
    
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
                    if(ret.output['0'] == "true"){
                        res.status(200)
                        res.json({
                            message: "failed",
                            data: ret
                        })
                    }else{
                        res.status(200)
                        res.json({
                            message: "success",
                            data: ret
                        })
                    }
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
                    if(!ret.output['0']){
                        res.status(200)
                        res.json({
                            message: "failed",
                            data: ret
                        })
                    }else{
                        res.status(200)
                        res.json({
                            message: "success",
                            data: ret
                        })
                    }
                });
            }
        }
    }
});









// // 注册
// router.post("/signUp", function(req, res, next){
    
//     var newAccount = account.create();
//     console.log(newAccount)

//     let entries = req.body.password.toString() + "," + newAccount.address;
//     entries = entries.trim();
//     console.log(entries);

//     // let commandInfo = interfaces.find(value => value.name == "insert");
//     // commandInfo.handler({
//     //     tableName: userTableName,
//     //     key:  req.body.username,
//     //     entry: entry
//     // });

//        crudService.desc(userTableName).then(tableInfo => {
//         let table = new Table(tableInfo.tableName, req.body.username, tableInfo.valueFields, tableInfo.optional);

//         let fieldNames = tableInfo.valueFields.split(',');
//         let fieldValues = entries.split(',');

//         if (fieldNames.length !== fieldValues.length) {
//             throw new Error(`unmatch number of fields, expected ${fieldNames.length} but got ${fieldValues.length}`);
//         }

//         let entry = new Entry();
//         for (let index in fieldNames) {
//             entry.put(fieldNames[index], fieldValues[index]);
//         }

//         crudService.insert(table, entry).then(result=>{
//             console.log(result);
//             res.status(200)
//             res.json({
//                     message: "success",
//                     data: {
//                         address: newAccount.address,
//                         // privateKey: newAccount.privateKey
//                     }
//             })
//         }).catch(reason => {
//             process.exitCode = -1;

//             if (reason instanceof Error) {
//                 console.error(chalk.red(reason.stack));
//             } else {
//                 if (reason instanceof Object) {
//                     if (isJSON(reason, true)) {
//                         reason = JSON.stringify(reason);
//                     }
//                 }
//                 console.error(chalk.red(reason));
//             }
//         });
//     });
// });

// router.post("/signIn", function(req, res, next){

//     let condition = "password=" + req.body.password; 
//     condition = parseCondition(condition);

//     crudService.desc(userTableName).then(tableInfo => {
//         let table = new Table(tableInfo.tableName, req.body.username, tableInfo.valueFields, tableInfo.optional);

//         crudService.select(table, condition).then(result=>{
//             console.log(result);
//             if(result.length == 0){
//                 res.status(404)
//                 res.json({
//                         message: "failed",
//                         data: result
//                 })
//             }else{
//                 res.status(200)
//                 res.json({
//                         message: "success",
//                         data: result
//                 })
//             }
//         }).catch(reason => {
//             process.exitCode = -1;

//             if (reason instanceof Error) {
//                 console.error(reason.stack);
//             } else {
//                 if (reason instanceof Object) {
//                     if (isJSON(reason, true)) {
//                         reason = JSON.stringify(reason);
//                     }
//                 }
//                 console.error(reason);
//             }
//         });
//     });
// });


// function parseCondition(condition) {
//     let ops = ['!=', '>=', '<=', '>', '<', '='];

//     for (let op of ops) {
//         let pos = condition.indexOf(op);
//         if (pos >= 0) {
//             let key = condition.substring(0, pos);
//             let value = condition.substring(pos + 1);
//             let ret = new Condition();

//             switch (op) {
//                 case '!=':
//                     ret.ne(key, value);
//                     return ret;
//                 case '>=':
//                     ret.ge(key, value);
//                     return ret;
//                 case '<=':
//                     ret.le(key, value);
//                     return ret;
//                 case '>':
//                     ret.gt(key, value);
//                     return ret;
//                 case '<':
//                     ret.lt(key, value);
//                     return ret;
//                 case '=':
//                     ret.eq(key, value);
//                     return ret;
//                 default:
//                     throw new Error('impossible to here');
//             }
//         }
//     }

//     throw new Error('illegal condition expression');
// }

module.exports = router;
