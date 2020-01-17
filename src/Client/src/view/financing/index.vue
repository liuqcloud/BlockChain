<template>
  <div>
    <!--按钮部分-->
    <Card>
      <p slot="title">融资记录</p>
      <Row>
        <Col span="5">
          <Button type="primary" style="width: 100px;" @click="openAddModal">
            申请融资
          </Button>
        </Col>
      </Row>
      <br>
      <!--表格部分-->
      <div>
        <Table :columns="columnsList" :data="financingData" border disabled-hover></Table>
      </div>
      <div style="margin: 10px;overflow: hidden">
        <div style="float: right;">
          <Page show-total show-elevator :total="financingData.length" :current="page.currentPage"></Page>
        </div>
      </div>
    </Card>

    <!--Addmodal-->
    <Modal v-model="isAdd" @on-cancel="cancelModal" title="申请融资" width="800">
      <Form :model="applyForm" ref="applyForm" :label-width="110">
        <Card>
          <Row>
            <Col span="11">
              <FormItem label="应收账款单据：" prop="receiptId">
                <Input placeholder="请输入单据ID" clearable v-model="applyForm.receiptId"></Input>
              </FormItem>
            </Col>
            <Col span="11">
              <FormItem label="申请银行：" prop="bankAddr">
                <!--                <Select clearable filterable v-model="suggestionAddForm.enterpriseId" placeholder="请输入投诉企业" remote-->
                <!--                        :remote-method="v=>{remoteMethod(v,'search')}" :loading="loading">-->
                <!--                  <Option v-for="(option, index) in enterpriseData" :value="option.id.toString()" :key="index">-->
                <!--                    {{option.name}}-->
                <!--                  </Option>-->
                <!--                </Select>-->
                <Input placeholder="请输入银行地址" clearable v-model="applyForm.bankAddr"></Input>
              </FormItem>
            </Col>
          </Row>
          <Row>
            <Col span="11">
              <FormItem label="申请金额：" prop="amount">
                <Input placeholder="请输入申请金额" clearable v-model="applyForm.amount"></Input>
              </FormItem>
            </Col>
            <Col span="11">
              <FormItem label="申请时间：" prop="date">
                <Input placeholder="请输入申请时间" clearable v-model="applyForm.date"></Input>
                <!--                <DatePicker type="datetime" ref="timeAdd" placeholder="请选择申请时间"-->
                <!--                            style="width: 227px"></DatePicker>-->
              </FormItem>
            </Col>
          </Row>
        </Card>
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="text" @click="cancelModal">取消</Button>
        <Button type="primary" @click="doFinancingApply">确认</Button>
      </div>
    </Modal>

    <!--ReceiptDetailmodal-->
    <Modal v-model="isReceipt" @on-cancel="cancelModal" title="应收账款单据详情" width="800">
      <Form :model="receiptData" ref="receiptData" :label-width="110">
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
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="primary" @click="cancelModal">关闭</Button>
      </div>
    </Modal>

  </div>
</template>

<script>
    import {getAllfinanceApply, addApply} from '../../api/financeApply.js'
    import {getReceiptDetail} from '../../api/receipt.js'

    export default {
        name: 'financing',
        components: {},
        data: function () {
            return {
                // modal控制
                isAdd: false,
                isReceipt: false,
                // 表头数据
                columnsList: [
                    {
                        type: 'selection',
                        width: 60,
                        align: 'center'
                    },
                    {
                        title: '银行账户地址',
                        align: 'center',
                        key: 'bank'
                    },
                    {
                        title: '融资时间',
                        align: 'center',
                        key: 'date'
                    },
                    {
                        title: '融资金额',
                        align: 'center',
                        key: 'amount'
                    },
                    {
                        title: '使用的应收账款单据',
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

                financingData: [],
                receiptData: {},
                applyForm: {},

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
            this.findFinanceData()
        },

        methods: {
            async findFinanceData() {
                let res = await getAllfinanceApply()
                this.financingData = res.data.data
                console.log(this.financingData)
            },

            async findReceiptDetail(id) {
                let res = await getReceiptDetail({receiptId: id})
                console.log(res)
                this.receiptData = res.data.data
                this.openReceiptModal()
            },

            async doFinancingApply() {
                let res = await addApply(this.applyForm)
                if(res.data.message == "success"){
                  this.$Message.success("融资成功")
                  this.findFinanceData()
                }else{
                  this.$Message.error("融资失败")
                }
                this.cancelModal()
            },

            openAddModal() {
                this.isAdd = true
            },

            openReceiptModal() {
                this.isReceipt = true
            },

            cancelModal() {
                this.isAdd = false
                this.isReceipt = false
                this.$refs.applyForm.resetFields()
            }
        }
    }

</script>

<style scoped>

</style>
