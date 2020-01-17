<template>
  <div style="height: 100%;">
    <Card style="height: 100%;">
      <img src="https://raw.githubusercontent.com/FISCO-BCOS/FISCO-BCOS/master/docs/images/FISCO_BCOS_Logo.svg?sanitize=true">
      <h1 id="title">基于FISCO-BCOS的供应链金融平台</h1>
      <div v-if="unRegister">
        <h1>您的公司/机构尚未登记</h1>
        <Row style="text-align: center;">
          <Col>
            <Button type="primary" style="width: 150px;" @click="openEnterpriseModal">
              注册成为公司
            </Button>
            <Button type="primary" style="width: 150px; margin-left: 20px;" @click="openThirdPartyModal">
              注册成为第三方机构
            </Button>
          </Col>
        </Row>
      </div>
      <div v-else>
        <h1>欢迎使用，{{ userData.name }}！</h1>
      </div>
    </Card>

    <!--reigister enterprise emodal-->
    <Modal v-model="isEnterprise" @on-cancel="cancelModal" title="注册成为公司" width="800">
      <Form :model="registerForm" ref="registerForm1" :label-width="110">
        <Card>
          <Row>
            <Col span="11">
              <FormItem label="公司名称：" prop="name">
                <Input placeholder="请输入公司名称" clearable v-model="registerForm.name"></Input>
              </FormItem>
            </Col>
            <Col span="11">
              <FormItem label="现有资产：" prop="properties">
                <Input placeholder="请输入公司资产数额" clearable v-model="registerForm.properties"></Input>
              </FormItem>
            </Col>
          </Row>
        </Card>
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="text" @click="cancelModal">取消</Button>
        <Button type="primary" @click="doEnterpriseRegister">确认</Button>
      </div>
    </Modal>

    <!--reigister thirdParty emodal-->
    <Modal v-model="isThirdParty" @on-cancel="cancelModal" title="注册成为第三方机构" width="800">
      <Form :model="registerForm" ref="registerForm2" :label-width="110">
        <Card>
          <Row>
            <Col span="11">
              <FormItem label="机构名称：" prop="name">
                <Input placeholder="请输入公司名称" clearable v-model="registerForm.name"></Input>
              </FormItem>
            </Col>
            <Col span="11">
              <FormItem label="机构类型：" prop="type">
                <Select v-model="registerForm.type">
                  <Option value=0 key=0>物流公司</Option>
                  <Option value=1 key=1>银行</Option>
                </Select>
              </FormItem>
            </Col>
          </Row>
        </Card>
      </Form>
      <!--自定义页脚-->
      <div slot="footer">
        <Button type="text" @click="cancelModal">取消</Button>
        <Button type="primary" @click="doThridPartyRegister">确认</Button>
      </div>
    </Modal>

  </div>
</template>

<script>
    import {getUserDetail, registerThirdParty, registerEnterprise} from '../../api/user.js'

    export default {
        name: 'index',
        components: {},
        data() {
            return {
                isEnterprise: false,
                isThirdParty: false,

                registerForm: {},
                userData: {},
                unRegister: true
            }
        },
        created() {
            this.getUserData()
        },
        methods: {
            async getUserData() {
                let res = await getUserDetail()
                this.userData = res.data.data.output
                if (this.userData['0']) {
                    this.unRegister = false
                }
            },
            async doEnterpriseRegister() {
                let res = await registerEnterprise(this.registerForm)
                if(res.status == 200){
                  this.$Message.success("注册成功")
                  this.getUserData()
                }else{
                  this.$Message.error("注册失败")
                }
                this.cancelModal()
            },

            async doThridPartyRegister() {
                let res = await registerThirdParty(this.registerForm)
                if(res.status == 200){
                  this.$Message.success("注册成功")
                  this.getUserData()
                }else{
                  this.$Message.error("注册失败")
                }
                this.cancelModal()
            },

            openEnterpriseModal() {
                this.isEnterprise = true
            },

            openThirdPartyModal() {
                this.isThirdParty = true
            },

            cancelModal() {
                this.isEnterprise = false
                this.isThirdParty = false
                this.$refs.registerForm1.resetFields()
                this.$refs.registerForm2.resetFields()
            },
        }
    }
</script>

<style scoped>
h1{
  text-align: center;
  color: black;
  line-height: 100px;
  vertical-align: middle;
}

#title{
  font-size: 45px;
  clear: left;
  margin-bottom: 30px;
}

  img{
    float: left;
    width: 300px;
  }
</style>
