<template>
  <div style="height: 100%;">
    <Card style="height: 100%;">
      <p slot="title">认证单据</p>
      <Row>
        <Col span="5">
          <Button type="primary" style="width: 100px;" @click="openAddModal">
            添加新认证
          </Button>
        </Col>
      </Row>
      <br>
    </Card>

    <!--Addmodal-->
    <Modal v-model="isAdd" @on-cancel="cancelModal" title="单据认证" width="800">
      <Form :model="addForm" ref="addForm" :label-width="110">
        <Card>
          <Row>
            <FormItem label="应收账款单据ID：" prop="receiptId">
              <Input placeholder="请输入要认证的应收账款单据id" clearable v-model="addForm.receiptId"></Input>
            </FormItem>
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
    import {receiptConfirm} from '../../api/receipt.js'

    export default {
        name: 'transaction',
        components: {},
        data: function () {
            return {
                // modal控制
                isAdd: false,
                addForm: {},
            }
        },

        created() {
        },

        methods: {
            openAddModal() {
                this.isAdd = true
            },

            async doConfirm() {
                let res = await receiptConfirm(this.addForm)
                if(res.data.message == "success"){
                  this.$Message.success("认证成功")
                }else{
                  this.$Message.error("认证失败")
                }
                this.cancelModal()
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
