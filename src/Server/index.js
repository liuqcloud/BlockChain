const fs = require('fs');
const path = require('path');
var url = require('url')
var express = require('express');
var bodyParser = require('body-parser');//解析,用req.body获取post参数
const isJSON = require('./nodejs-sdk/node_modules/is-json');

// 配置外部账户等信息
const Configuration = require('./nodejs-sdk/packages/api/common/configuration').Configuration;
Configuration.setConfig(path.join(__dirname, './conf/config.json'));
Configuration.account
const config = new Configuration();
console.log(config.account)
console.log(config.privateKey)

var contractRouter = require('./routes/contract');
var userRouter = require('./routes/user');
var enterpriseRouter = require('./routes/enterprise');
var financeApplyRouter = require('./routes/financeApply');
var receiptRouter = require('./routes/receipt');
var transactionRouter = require('./routes/transaction');
var thirdPartyRouter = require('./routes/thirdParty');

var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

//设置跨域访问
app.all('*',function(req,res,next) {
  res.header('Access-Control-Allow-Origin', '*'); 
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header("Access-Control-Allow-Methods", "PUT,POST,GET,DELETE,OPTIONS");
  res.header("X-Powered-By", ' 3.2.1');
  res.header("Content-Type", "application/json;charset=utf-8");
  next();
})

// 合约相关接口
app.use('/api/contract', contractRouter);
app.use('/api/user', userRouter);
app.use('/api/enterprise', enterpriseRouter);
app.use('/api/financeApply', financeApplyRouter);
app.use('/api/receipt', receiptRouter);
app.use('/api/transaction', transactionRouter);
app.use('/api/thirdParty', thirdPartyRouter);


// 404
app.use(function(req, res) {
    let currentTime = new Date();
    res.type('text/plain');
    res.status(404);
    res.send('404 - 你访问的页面可能去了火星\n' + currentTime);
  });
   
   
  // 500
  app.use(function(err, req, res, next) {
    let currentTime = new Date();
    let errInfo = err.stack;
    res.type('text/plain');
    res.status(500);
    res.send('500 - 服务器发生错误\n' + 'errInfo:' + errInfo + '\n' + 'currentTime:' + currentTime);
  });

var server = app.listen(3000, function(){
    var port = server.address().port;
    console.log('app listening at http://localhost:%s', port);
})
