<template>
  <div>
    <!--按钮部分-->
    <Card>
      <p slot="title">企业名录</p>
      <Row>
        <Col span="5">
          <Button type="primary" style="width: 100px;" @click="openAddModal">
            添加新认证
          </Button>
        </Col>
      </Row>
      <br>
      <!--表格部分-->
      <div>
        <Table :columns="columnsList" :data="coreEnterpriseData" border disabled-hover></Table>
      </div>
      <div style="margin: 10px;overflow: hidden">
        <div style="float: right;">
          <Page show-total show-elevator :total="coreEnterpriseData.length" :current="page.currentPage"></Page>
        </div>
      </div>
    </Card>

    <!--Addmodal-->
    <Modal v-model="isAdd" @on-cancel="cancelModal" title="核心企业认证" width="800">
      <Form :model="addForm" ref="addForm" :label-width="110">
        <Card>
          <Row>
            <Col span="15">
              <FormItem label="企业地址：" prop="address">
                <!--                <Select clearable filterable v-model="suggestionAddForm.enterpriseId" placeholder="请输入投诉企业" remote-->
                <!--                        :remote-method="v=>{remoteMethod(v,'search')}" :loading="loading">-->
                <!--                  <Option v-for="(option, index) in enterpriseData" :value="option.id.toString()" :key="index">-->
                <!--                    {{option.name}}-->
                <!--                  </Option>-->
                <!--                </Select>-->
                <Input placeholder="请输入将被认证为核心企业的地址" clearable v-model="addForm.address"></Input>
              </FormItem>
            </Col>
          </Row>
        </Card>
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="text" @click="cancelModal">取消</Button>
        <Button type="primary" @click="doConfirm">确认</Button>
      </div>
    </Modal>
  </div>
</template>

<script>
    import {getAllEnterprises, coreEnterpriseIdentifiy} from '../../api/enterprise.js'

    export default {
        name: 'transaction',
        components: {},
        data: function () {
            return {
                // modal控制
                isAdd: false,

                // 表头数据
                columnsList: [
                    {
                        type: 'selection',
                        width: 60,
                        align: 'center'
                    },
                    {
                        title: '企业名称',
                        align: 'center',
                        key: 'name'
                    },
                    {
                        title: '账户地址',
                        align: 'center',
                        key: 'address'
                    },
                    {
                        title: '企业类型',
                        align: 'center',
                        key: 'isCore',
                        render: (h, params) => {
                            let type = "";
                            if (params.row.isCore=="1") {
                                type = "核心企业"
                            } else {
                                type = "普通企业"
                            }
                            return h('span', {}, type)
                        }
                    }
                ],
                gettingEnterpriseData: false,

                coreEnterpriseData: [],
                addForm: {},

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
            this.findCoreEnterpriseData()
        },

        methods: {
            async findCoreEnterpriseData() {
                let res = await getAllEnterprises()
                this.coreEnterpriseData = res.data.data
                console.log(this.coreEnterpriseData)
            },

            async doConfirm() {
                let res = await coreEnterpriseIdentifiy(this.addForm)
                if(res.data.message == "success"){
                  this.$Message.success("认证成功")
                  this.findCoreEnterpriseData()
                }else{
                  this.$Message.error("认证失败")
                }
                this.cancelModal()
            },

            openAddModal() {
                this.isAdd = true
            },

            cancelModal() {
                this.isAdd = false
                this.$refs.addForm.resetFields()
            }
        }
    }

</script>

<style scoped>

</style>
