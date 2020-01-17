<template>
  <div>
    <!--按钮部分-->
    <Card>
      <p slot="title">历史交易</p>
      <Row>
        <Col span="6">
          <Button type="primary" style="width: 100px;" @click="openAddModal">
            发起新交易
          </Button>
          <Button type="primary" style="width: 100px; margin-left: 20px;" @click="openSettleModal">
            结算
          </Button>
        </Col>
      </Row>
      <br>
      <!--表格部分-->
      <div>
        <Table :columns="columnsList" :data="transactionData" border disabled-hover></Table>
      </div>
      <div style="margin: 10px;overflow: hidden">
        <div style="float: right;">
          <Page show-total show-elevator :total="transactionData.length" :current="page.currentPage"></Page>
        </div>
      </div>
    </Card>

    <!--Addmodal-->
    <Modal v-model="isAdd" @on-cancel="cancelModal" title="发起新交易" width="800">
      <Form :model="newTransactionForm" ref="newTransactionForm" :label-width="110">
        <Card>
          <Row>
            <Col span="11">
              <FormItem label="交易方式：">
                <Select v-model="transactionMethod">
                  <Option value="0" key="0">创建新的应收账款单据</Option>
                  <Option value="1" key="1">转让已有应收账款单据</Option>
                </Select>
              </FormItem>
            </Col>
          </Row>
          <div v-show="transactionMethod">
            <Row>
              <Col span="11">
                <FormItem label="卖方企业：" prop="seller">
                  <!--                <Select clearable filterable v-model="suggestionAddForm.enterpriseId" placeholder="请输入投诉企业" remote-->
                  <!--                        :remote-method="v=>{remoteMethod(v,'search')}" :loading="loading">-->
                  <!--                  <Option v-for="(option, index) in enterpriseData" :value="option.id.toString()" :key="index">-->
                  <!--                    {{option.name}}-->
                  <!--                  </Option>-->
                  <!--                </Select>-->
                  <Input placeholder="请输入卖方企业地址" clearable v-model="newTransactionForm.seller"></Input>
                </FormItem>
              </Col>
              <Col span="11">
                <FormItem label="交易金额：" prop="amount">
                  <Input placeholder="请输入交易金额" clearable v-model="newTransactionForm.amount"></Input>
                </FormItem>
              </Col>
            </Row>
            <Row>
              <Col span="11">
                <FormItem label="交易时间：" prop="time">
                  <Input placeholder="请输入交易时间" clearable v-model="newTransactionForm.time"></Input>
                  <!-- <DatePicker type="datetime" ref="time" placeholder="请选择交易时间"
                              style="width: 227px"></DatePicker> -->
                </FormItem>
              </Col>
              <Col span="11" v-if="transactionMethod==0">
                <FormItem label="还款时间：" prop="deadline">
                  <Input placeholder="请输入还款时间" clearable v-model="newTransactionForm.deadline"></Input>
                  <!-- <DatePicker type="datetime" ref="deadline" placeholder="请选择还款时间"
                              style="width: 227px"></DatePicker> -->
                </FormItem>
              </Col>
              <Col span="11" v-if="transactionMethod==1">
                <FormItem label="应收账款单据：" prop="receiptId">
                  <Input placeholder="请输入要转让的单据ID" clearable v-model="newTransactionForm.receiptId"></Input>
                </FormItem>
              </Col>
            </Row>
            <Row>
              <Col>
                <FormItem label="交易内容：" prop="info">
                  <Input placeholder="请输入交易信息" clearable v-model="newTransactionForm.info"></Input>
                </FormItem>
              </Col>
            </Row>
          </div>
        </Card>
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="text" @click="cancelModal">取消</Button>
        <Button type="primary" @click="doCreateTransaction">确认</Button>
      </div>
    </Modal>

    <!--Settlemodal-->
    <Modal v-model="isSettle" @on-cancel="cancelModal" title="结算" width="800">
      <Form :model="settleForm" ref="settleForm" :label-width="110">
        <Card>
          <Row>
            <FormItem label="应收账款单据：" prop="receiptId">
              <Input placeholder="请输入要结算的应收账款单据ID" clearable v-model="settleForm.receiptId"></Input>
            </FormItem>
          </Row>
        </Card>
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="text" @click="cancelModal">取消</Button>
        <Button type="primary" @click="doReceiptSettle">确认</Button>
      </div>
    </Modal>

    <!--ReceiptDetailmodal-->
    <Modal v-model="isReceipt" @on-cancel="cancelModal" title="应收账款单据详情" width="800">
      <Form :model="receiptData" ref="receiptData" :label-width="110">
        <Card>
          <FormItem label="单据ID：" prop="id">
            <p>{{receiptData.id}}</p>
          </FormItem>
          <FormItem label="创建时间：" prop="createTime">
            <p>{{receiptData.createTime}}</p>
          </FormItem>
          <FormItem label="结算日期：" prop="deadline">
            <p>{{receiptData.deadline}}</p>
          </FormItem>
          <FormItem label="总金额：" prop="totalAmount">
            <p>{{receiptData.totalAmount}}</p>
          </FormItem>
          <FormItem label="付款方：" prop="payer">
            <p>{{receiptData.payer}}</p>
          </FormItem>
          <FormItem label="收款方：">
            <p v-for="(item, index) in receiptData.payees" :key="index">{{item}} : {{ receiptData.amount[index] }} </p>
          </FormItem>
          <FormItem label="当前可信度：" prop="creditLevel">
            <p>{{receiptData.creditLevel}}</p>
          </FormItem>
          <FormItem label="状态：" prop="settled">
            <p v-if="receiptData.settled">已结算</p>
            <p v-else>尚未结算</p>
          </FormItem>
        </Card>
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="primary" @click="cancelModal">关闭</Button>
      </div>
    </Modal>

  </div>
</template>

<script>
    import {getTransactionData, TransactionWithNewReceipt, TransactionByTransferReceipt} from '../../api/transaction.js'
    import {receiptSettle, getReceiptDetail} from '../../api/receipt.js'
    import {getAllEnterprises} from '../../api/enterprise.js'

    export default {
        name: 'transaction',
        components: {},
        data: function () {
            return {
                // modal控制
                isAdd: false,
                isReceipt: false,
                isSettle: false,

                // 表头数据
                columnsList: [
                    {
                        type: 'selection',
                        width: 60,
                        align: 'center'
                    },
                    {
                        title: '卖方',
                        align: 'center',
                        key: 'seller'
                    },
                    {
                        title: '买方',
                        align: 'center',
                        key: 'buyer'
                    },
                    {
                        title: '交易金额',
                        align: 'center',
                        key: 'amount'
                    },
                    {
                        title: '交易详情',
                        align: 'center',
                        key: 'info'
                    },
                    {
                        title: '交易时间',
                        align: 'center',
                        key: 'transactionTime'
                    },
                    {
                        title: '是否结算',
                        align: 'center',
                        key: 'settled',
                        render: (h, params) => {
                            let settled = "";
                            if (params.row.settled) {
                                settled = "已结算"
                            } else {
                                settled = "尚未结算"
                            }
                            return h('span', {}, settled)
                        }
                    },
                    {
                        title: '应收账款单据信息',
                        align: 'center',
                        key: 'handle',
                        width: 200,
                        render: (h, params) => {
                            return h('div', [
                                h('Button', {
                                    props: {
                                        type: 'primary'
                                    },
                                    style: {
                                        marginRight: '5px',
                                        display: 'inline-block'
                                    },
                                    on: {
                                        click: () => {
                                            let id = params.row.receiptId
                                            console.log(id)
                                            this.findReceiptDetail(id)
                                        }
                                    }
                                }, '查看'),
                            ])
                        }
                    }
                ],
                gettingEnterpriseData: false,

                transactionData: [],
                receiptData: {},
                newTransactionForm: {},
                settleForm: {},
                transactionMethod: null, // 记录发起新的交易方式，0表示创建新单据，1表示转让已有单据

                loading: false, // 远程查询时使用
                loading1: false, // 远程查询时使用
                loading2: false, // 远程查询时使用

                delId: {
                    ids: ''
                },
                page: {
                    total: 1,
                    currentPage: 1
                }
            }
        },

        created() {
            this.findTransactionData()
        },

        methods: {
            async findTransactionData() {
                let res = await getTransactionData()
                this.transactionData = res.data.data
                console.log(this.transactionData)
            },

            async findReceiptDetail(id) {
                let res = await getReceiptDetail({receiptId: id})
                console.log(res)
                this.receiptData = res.data.data
                this.openReceiptModal()
            },

            async doReceiptSettle() {
                let res = await receiptSettle(this.settleForm)
                if(res.data.message == "success"){
                  this.$Message.success("结算成功")
                  this.findTransactionData()
                }else{
                  this.$Message.error("结算失败")
                }
                this.cancelModal()
            },

            doCreateTransaction() {
                if (this.transactionMethod == 0) {
                    this.doCreateNewTransaction()
                } else {
                    this.doTransferReceipt()
                }
            },

            async doCreateNewTransaction() {
                let res = await TransactionWithNewReceipt(this.newTransactionForm)
                if(res.data.message == "success"){
                  this.$Message.success("交易成功")
                  this.findTransactionData()
                }else{
                  this.$Message.error("交易失败")
                }
                this.cancelModal()
            },

            async doTransferReceipt() {
                let res = await TransactionByTransferReceipt(this.newTransactionForm)
                if(res.data.message == "success"){
                  this.$Message.success("交易成功")
                  this.findTransactionData()
                }else{
                  this.$Message.error("交易失败")
                }
                this.cancelModal()
            },

            openAddModal() {
                this.isAdd = true
            },

            openReceiptModal() {
                this.isReceipt = true
            },

            openSettleModal() {
                this.isSettle = true
            },

            cancelModal() {
                this.isAdd = false
                this.isReceipt = false
                this.isSettle = false
                this.transactionMethod = null
                this.$refs.newTransactionForm.resetFields()
                this.$refs.settleForm.resetFields()
            }
        }
    }

</script>

<style scoped>

</style>
