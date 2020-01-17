pragma solidity ^0.4.23;

contract hello {

    /*------------------------------------------ 结构体定义 --------------------------------------------*/

    enum EnterpriseType { normal, core }     // 企业类型，分为核心企业和中下游普通企业
    enum ThirdPartyType { logistics, bank }  // 第三方可信机构类型，确认单据的真实性，目前暂分为银行和物流机构两类

    // 公司结构体定义
    struct Enterprise {
        string name;                    // 公司名称
        EnterpriseType eType;           // 公司类型
        uint property;                  // 公司资产
        uint256[] transactions;         // 历史交易id
        uint256[] financings;           // 历史融资记录
        bool exists;                    // 是否存在
    }

    // 第三方结构体定义
    struct ThirdParty {
        string name;                // 名称
        ThirdPartyType tType;       // 第三方类型
        bool exists;                // 是否存在
    }

    // 交易结构体定义
    struct Transaction {
        uint256 id;                 // 交易hash
        address seller;             // 卖方
        address buyer;              // 买方
        string info;                // 交易相关信息
        uint transactionTime;       // 交易时间
        uint256 receiptId;          // 交易对应的应收账款单据Id
        bool settled;               // 是否已经结算
        bool exists;                // 是否存在
    }

    // 应收账款单据结构体定义
    struct Receipt {
        uint256 id;                         // 单据hash
        uint256[] tranIds;                    // 交易hash,一个单据可被多个交易使用
        uint createTime;                    // 应收账款单据创建时间，和交易创建时间相同
        uint totalAmount;                   // 应收账款总金额
        uint deadline;                      // 结算期限
        uint creditLevel;                   // 单据可信度，由第三方确认后提高
        address payer;                      // 最终付款方
        address[] payees;                   // 收款方, payees[0]为初始交易收款方，其余的为后续账单转让后的收款方
        mapping (address => uint) payInfo;  // 收款方 => 应收金额
        mapping (address => uint) timing;   // 收款方 => 初始创建以及后续转让时间记录
        bool settled;                       // 是否已经结算
        bool exists;                        // 是否存在
    }

    // 融资结构体定义
    struct Financing {
        uint256 id;                 // 融资hash值
        address enterprise;         // 融资申请者
        address bank;               // 金融机构（银行）
        uint256 receiptId;          // 融资使用的单据
        uint date;                  // 融资时间
        uint amount;                // 融资金额
        bool exists;                // 是否存在
    }

    // 数据都设为public使得任何人都可以访问，保证信息的公开透明
    mapping (address => Enterprise) public enterprises;             // 公司
    mapping (address => ThirdParty) public thirdParties;            // 第三方
    mapping (uint256 => Transaction) public transactions;           // 交易
    mapping (uint256 => Receipt) public receipts;                   // 单据及其转让记录(转让记录包含在单据结构体中)
    mapping (uint256 => Financing) public financings;               // 融资记录

    // 所有注册用户
    address[] public users;
    address public owner;           // 合约创始人


    /*------------------------------------------ 方法定义 --------------------------------------------*/

    constructor() public {
        owner = msg.sender;
    }


    // 事件定义
    // 由于更改合约中数据的结果都保存在特定合约的数据存储器中，我们在区块链浏览器中查看该地址是看不到任何信息的
    // 所以通过使用事件，可以使用户界面监听到这一事件的发生
    event TransactionCreateEvent(uint256 id, address seller, address buyer, string info, uint amount);
    event ReceiptCreateEvent(uint256 id, address payer, address payee, uint amount);
    event ReceiptTransferEvent(uint256 id, address sender, address receiver, uint amount);
    event FinanceAccpetEvent(uint256 id, address enterprise, address banker, uint amount);
    event TransactionSettleEvent(uint256 id, address payer, address[] payee);


    // 企业注册，新注册企业默认类型为普通企业
    function newEnterprise(string memory name, uint property) public returns (bool, string memory) {
        if(!enterprises[msg.sender].exists){
            enterprises[msg.sender].name = name;
            enterprises[msg.sender].eType = EnterpriseType.normal;
            enterprises[msg.sender].property = property;
            enterprises[msg.sender].exists = true;
            users.push(msg.sender);
            return (true, "[INFO] Regist an enterprise successfully.");
        }else{
            return (false, "[ERROR] You have registed.");
        }
    }

    // 第三方机构注册
    function newThirdParty(string memory name, ThirdPartyType tType) public returns (bool, string memory) {
        if(!thirdParties[msg.sender].exists){
            thirdParties[msg.sender] = ThirdParty(name, tType, true);
            users.push(msg.sender);
            return (true, "[INFO] Regist a thirdParty successfully.");
        }else{
            return (false, "[ERROR] You have registed.");
        }
    }


    // 核心企业认定功能
    function coreEnterpriseIdentifiy(address enterpriseAddr) public returns (bool, string memory){
        if(!thirdParties[msg.sender].exists){
            return (false, "[ERROR] You don't have right to announce a core enterprise.");
        }else if(!enterprises[enterpriseAddr].exists){
            return (false, "[ERROR] Enterprise doesn't exist.");
        }else{
            enterprises[enterpriseAddr].eType = EnterpriseType.core;
            return (true, "[INFO] That enterprise is core enterprise now.");
        }
    }

    // 通过新创建单据的方式发起交易（这里设定由买方发起交易）
    function TransactionWithNewReceipt(string memory info, uint time, uint amount, uint deadline, address seller) public returns (bool, string memory) {
        if(!enterprises[msg.sender].exists){
            return (false, "[ERROR] You need regist your company first.");
        }else{
            uint256 transactionId = uint256(keccak256(abi.encodePacked(msg.sender, seller, amount, now)));
            // 创建单据，生成一个单据Id
            uint256 receiptId = uint256(keccak256(abi.encodePacked(seller, amount, now)));
            if(!receipts[receiptId].exists){
                transactions[transactionId] = Transaction(transactionId, seller, msg.sender, info, time, receiptId, false, true);
                enterprises[msg.sender].transactions.push(transactionId);
                enterprises[seller].transactions.push(transactionId);
                // 交易创建事件触发
                emit TransactionCreateEvent(transactionId, seller, msg.sender, info, amount);

                receipts[receiptId].id = receiptId;
                receipts[receiptId].tranIds.push(transactionId);
                receipts[receiptId].createTime = time;
                receipts[receiptId].totalAmount = amount;
                receipts[receiptId].deadline = deadline;
                receipts[receiptId].creditLevel = 0;
                receipts[receiptId].payer = msg.sender;
                receipts[receiptId].payees.push(seller);
                receipts[receiptId].payInfo[seller] = amount;
                receipts[receiptId].timing[seller] = time;
                receipts[receiptId].settled = false;
                receipts[receiptId].exists = true;
                // 应收账款单据创建事件触发
                emit ReceiptCreateEvent(receiptId, msg.sender, seller, amount);
                return (true, "[INFO] Create a new transaction successfully.");
            }else{
                return (false, "[ERROR] Create receipt failed.");
            }
        }
    }

    // 通过转让单据的方式发起交易（这里设定由买方发起交易）
    function TransactionByTransferReceipt(string memory info, uint time, uint amount, address seller, uint256 receiptId) public returns (bool, string memory) {
        if(!enterprises[msg.sender].exists){
            return (false, "[ERROR] You need regist your company first.");
        }else if(!receipts[receiptId].exists){
            return (false, "[ERROR] Receipt doesn't exist.");
        }else if(receipts[receiptId].payInfo[msg.sender] == 0){
            return (false, "[ERROR] Your have no right to transfer this receipt.");
        }else if(receipts[receiptId].settled){
            return (false, "[ERROR] Receipt is out of date.");
        }else if(receipts[receiptId].payInfo[msg.sender] < amount){
            return (false, "[WARNNING] Transfer failed, amount limited.");
        }else{
            // 创建交易
            uint256 transactionId = uint256(keccak256(abi.encodePacked(msg.sender, seller, amount, now)));
            Transaction memory tran = Transaction(transactionId, seller, msg.sender, info, time, receiptId, false, true);
            transactions[transactionId] = tran;
            enterprises[msg.sender].transactions.push(transactionId);
            enterprises[seller].transactions.push(transactionId);
            // 交易创建事件触发
            emit TransactionCreateEvent(transactionId, seller, msg.sender, info, amount);
            receipts[receiptId].tranIds.push(transactionId);
            receipts[receiptId].payees.push(seller);
            receipts[receiptId].payInfo[msg.sender] -= amount;
            receipts[receiptId].payInfo[seller] += amount;
            receipts[receiptId].timing[seller] = time;
            emit ReceiptTransferEvent(receiptId, msg.sender, seller, amount);
            return (true, "[INFO] Transfer successfully.");
        }
    }

    // 第三方机构对于单据进行确认，以提高可信度。creditLevel, 银行确认+2, 物流公司+1。
    function confirmReceipt(uint256 receiptId) public{
        require(
            thirdParties[msg.sender].exists = true,
            "Only thirdParty can comfirm a transaction."
        );

        if(thirdParties[msg.sender].tType == ThirdPartyType.bank){
            receipts[receiptId].creditLevel += 2;
        }else{
            receipts[receiptId].creditLevel += 1;
        }
    }


    // 下游企业通过核心企业的应收账款单据向银行提出融资申请
    // 目前实现:应收账款单据的creditLevel要大于2才能通过融资申请
    function finance(uint256 receiptId, address bankAddr, uint amount, uint date) public returns (bool, string memory) {
        if(!enterprises[msg.sender].exists){
            return (false, "[ERROR] You need regist your company first.");
        }else if(!receipts[receiptId].exists){
            return (false, "[ERROR] Receipt doesn't exist.");
        }else if(receipts[receiptId].settled){
            return (false, "[ERROR] Receipt is out of date.");
        }else if(enterprises[receipts[receiptId].payer].eType != EnterpriseType.core){
            // 验证应收账款单据有否是由核心企业签发的
            return (false, "[ERROR] Sorry, the bank refuses your financing request.");
        }else if(receipts[receiptId].creditLevel < 2){
            // 交易可信度需要 >= 3
            return (false, "[ERROR] Sorry, the bank refuses your financing request.");
        }else if(receipts[receiptId].payInfo[msg.sender] < amount){
            // 验证是否有还款能力
            return (false, "[ERROR] Sorry, the bank refuses your financing request.");
        }else{
            // 生成一个融资Id
            uint256 financingId = uint256(keccak256(abi.encodePacked(msg.sender, amount, now)));
            if(!financings[financingId].exists){
                // 融资
                Financing memory finance = Financing(financingId, msg.sender, bankAddr, receiptId, date, amount, true);
                financings[financingId] = finance;

                enterprises[msg.sender].financings.push(financingId);
                emit FinanceAccpetEvent(financingId, msg.sender, bankAddr, amount);
                return (true, "[INFO] Financing successfully.");
            }else{
                return (false, "[ERROR] Financing exists.");
            }
        }
    }

    // 结算
    function settlement(uint256 receiptId) public returns (bool, string memory) {
        if(receipts[receiptId].settled){
            return (false, "[ERROR] The receipt already settled.");
        }else if(!receipts[receiptId].exists){
            return (false, "[ERROR] Receipt doesn't exists.");
        }else if(receipts[receiptId].payer != msg.sender){
            return (false, "[ERROR] You don't need to pay anything for this receipt.");
        }else{
            uint totalAmount = 0;
            // 扣款
            for(uint i = 0; i < receipts[receiptId].payees.length; i++){
                address payeeAddr = receipts[receiptId].payees[i];
                uint amount = receipts[receiptId].payInfo[payeeAddr];
                enterprises[payeeAddr].property += amount;
                totalAmount += amount;
            }
            enterprises[receipts[receiptId].payer].property -= totalAmount;
            receipts[receiptId].settled = true;
            for(i = 0; i < receipts[receiptId].tranIds.length; i++){
                transactions[receipts[receiptId].tranIds[i]].settled = true;
            }

            emit TransactionSettleEvent(receiptId, receipts[receiptId].payer, receipts[receiptId].payees);
            return (true, "[INFO] Transaction settles.");
        }
    }

    /*------------------------------------------ 查询函数 --------------------------------------------*/

    // 用户登录时验证的函数：检查该账户地址是否已经注册成为了企业或者第三方机构
    // type: 0 尚未注册， 1 核心企业， 2 普通企业 3 银行 4 物流公司
    function getUserInfo() public view returns (bool, uint, string memory name) {
        if(enterprises[msg.sender].exists){
            if(enterprises[msg.sender].eType == EnterpriseType.core){
                return (true, 1, enterprises[msg.sender].name);
            }else{
                return (true, 2, enterprises[msg.sender].name);
            }
        }else if(thirdParties[msg.sender].exists){
            if(thirdParties[msg.sender].tType == ThirdPartyType.bank){
                return (true, 3, thirdParties[msg.sender].name);
            }else{
                return (true, 4, thirdParties[msg.sender].name);
            }
        }else{
            return (false, 0, "[ERROR] Please register first!");
        }
    }


    function findAllEnterpriseAddr() public view returns(bool, uint num, address[] memory, string memory){
        address[] memory addrs = new address[](users.length);
        string memory names = "";
        uint count = 0;
        for(uint i = 0; i < users.length; i++){
            address addr = users[i];
            if(enterprises[addr].exists){
                addrs[count] = addr;
                // 字符串拼接
                if(count == 0){
                    names = enterprises[addr].name;
                }else{
                    names = strConcat(names, enterprises[addr].name);
                    names = strConcat(names, ",");
                }
                count++;
            }
        }
        if(count == 0){
            return (false, 0, addrs, names);
        }
        else{
            return (true, count, addrs, names);
        }
    }

    function findAllBankAddr() public returns(bool, uint num, address[] memory, string memory){
        address[] memory addrs = new address[](users.length);
        string memory names = "";
        uint count = 0;
        for(uint i = 0; i < users.length; i++){
            address addr = users[i];
            if(thirdParties[addr].exists && thirdParties[addr].tType == ThirdPartyType.bank){
                addrs[count] = addr;
                // 字符串拼接
                if(count == 0){
                    names = thirdParties[addr].name;
                }else{
                    names = strConcat(names, ",");
                    names = strConcat(names, thirdParties[addr].name);
                }
                count++;
            }
        }
        if(count == 0){
            return (false, 0, addrs, names);
        }
        else{
            return (true, count, addrs, names);
        }
    }

    // 登陆企业获取其历史交易信息
    // 应收账款单据包括在其中
    function getEnterpriseAllTransaction() public view returns(
        address[] memory seller,
        address[] memory buyer,
        string memory info,
        uint[] memory transactionTime,
        bool[] memory settled,
        uint256[] memory receiptId
    ){
        seller = new address[](enterprises[msg.sender].transactions.length);
        buyer = new address[](enterprises[msg.sender].transactions.length);
        info = "";
        transactionTime = new uint[](enterprises[msg.sender].transactions.length);
        receiptId = new uint256[](enterprises[msg.sender].transactions.length);
        settled = new bool[](enterprises[msg.sender].transactions.length);

        uint256[] tranIds = enterprises[msg.sender].transactions;
        for(uint i = 0; i < tranIds.length; i++){
            seller[i] = transactions[tranIds[i]].seller;
            buyer[i] = transactions[tranIds[i]].buyer;

            // 字符串拼接
            if(i == 0){
                info = transactions[tranIds[i]].info;
            }else{
                info = strConcat(info, ",");
                info = strConcat(info, transactions[tranIds[i]].info);
            }
            
            transactionTime[i] = transactions[tranIds[i]].transactionTime;
            settled[i] = transactions[tranIds[i]].settled; 
            receiptId[i] = transactions[tranIds[i]].receiptId;
        }
    }

    // 应收账款单据信息查看
    function getReceiptInfo(uint256 receiptId) public view returns(
        uint256 id,
        uint createTime,
        uint totalAmount,
        uint deadline,
        uint creditLevel,
        address payer,
        address[] memory payees,
        uint[] memory amount,
        bool settled
    ){
        id = receipts[receiptId].id;
        createTime = receipts[receiptId].createTime;
        totalAmount = receipts[receiptId].totalAmount;
        deadline = receipts[receiptId].deadline;
        creditLevel = receipts[receiptId].creditLevel;
        payer = receipts[receiptId].payer;
        payees = receipts[receiptId].payees;
        amount = new uint[](payees.length);
        for(uint i = 0; i < payees.length; i++){
            amount[i] = receipts[receiptId].payInfo[payees[i]];
        }
        settled = receipts[receiptId].settled;
    }

    // 登陆企业获取其历史融资记录
    function getFinancingInfo() public view returns(
        uint256[] memory id,
        address[] memory bank,
        uint256[] memory receiptId,
        uint[] date,
        uint[] amount
    ){
        id = new uint256[](enterprises[msg.sender].financings.length);
        bank = new address[](enterprises[msg.sender].financings.length);
        receiptId = new uint256[](enterprises[msg.sender].financings.length);
        date = new uint[](enterprises[msg.sender].financings.length);
        amount = new uint[](enterprises[msg.sender].financings.length);

        uint256[] finaIds = enterprises[msg.sender].financings;
        for(uint i = 0; i < finaIds.length; i++){
            id[i] = financings[finaIds[i]].id;
            bank[i] = financings[finaIds[i]].bank;
            receiptId[i] = financings[finaIds[i]].receiptId;
            date[i] = financings[finaIds[i]].date;
            amount[i] = financings[finaIds[i]].amount;
        }
    }


    /*------------------------------------------ 工具函数 --------------------------------------------*/

    // 拼接字符串
    function strConcat(string _a, string _b) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
   }  
}
