<template>
  <el-dialog
    :title="!dataForm.id ? '新增' : '修改'"
    :close-on-click-modal="false"
    :visible.sync="visible">
    <el-form :model="dataForm" :rules="dataRule" ref="dataForm" @keyup.enter.native="dataFormSubmit()"
             label-width="80px">
      <el-form-item label="交易时间" prop="time">
        <el-date-picker v-model="dataForm.time"
                        type="datetime"
                        placeholder="交易时间"
                        value-format="yyyy-MM-dd HH:mm:ss"></el-date-picker>
      </el-form-item>
      <el-form-item label="交易金额" prop="money">
        <el-input v-model="dataForm.money" placeholder="交易金额"></el-input>
      </el-form-item>
      <el-form-item label="支付方式" prop="source">
        <el-input v-model="dataForm.source" placeholder="支付方式"></el-input>
      </el-form-item>
      <el-form-item label="交易对方" prop="payee">
        <el-input v-model="dataForm.payee" placeholder="交易对方"></el-input>
      </el-form-item>
      <el-form-item label="商品" prop="goods">
        <el-input v-model="dataForm.goods" placeholder="商品"></el-input>
      </el-form-item>
      <el-form-item label="消费类型" prop="type">
        <!--      <el-input v-model="dataForm.type" placeholder="消费类型"></el-input>-->
        <el-select v-model="dataForm.type" filterable placeholder="请选择">
          <el-option
            v-for="item in typeOptions"
            :key="item.type"
            :label="item.type"
            :value="item.type">
          </el-option>
        </el-select>
      </el-form-item>
    </el-form>
    <span slot="footer" class="dialog-footer">
      <el-button @click="visible = false">取消</el-button>
      <el-button id="submitBtn" type="primary" @click="dataFormSubmit()">确定</el-button>
    </span>
  </el-dialog>
</template>

<script>
// 导出组件的配置对象
export default {
  // data选项用于定义组件的数据
  data () {
    return {
      visible: false,
      typeOptions: [],
      dataForm: {
        id: 0,
        time: '',
        money: '',
        source: '',
        payee: '',
        goods: '',
        type: ''
      },
      dataRule: {
        time: [
          {required: true, message: '交易时间不能为空', trigger: 'blur'}
        ],
        money: [
          {required: true, message: '交易金额不能为空', trigger: 'blur'}
        ],
        source: [
          {required: true, message: '支付方式不能为空', trigger: 'blur'}
        ],
        payee: [
          {required: true, message: '交易对方不能为空', trigger: 'blur'}
        ],
        goods: [
          {required: true, message: '商品不能为空', trigger: 'blur'}
        ],
        type: [
          {required: true, message: '消费类型不能为空', trigger: 'blur'}
        ]
      }
    }
  },
  // methods选项用于定义组件的方法
  methods: {
    init (id) {
      this.dataForm.id = id || 0
      this.visible = true
      this.$nextTick(() => {
        this.$refs['dataForm'].resetFields()
        if (this.dataForm.id) {
          this.$http({
            url: this.$http.adornUrl(`/generator/bill/info/${this.dataForm.id}`),
            method: 'get',
            params: this.$http.adornParams()
          }).then(({data}) => {
            if (data && data.code === 0) {
              this.dataForm.time = data.bill.time
              this.dataForm.money = data.bill.money
              this.dataForm.source = data.bill.source
              this.dataForm.payee = data.bill.payee
              this.dataForm.goods = data.bill.goods
              this.dataForm.type = data.bill.type
            }
          })
        }
      })
    },
    // 获取分类列表
    listTypes () {
      this.$http({
        url: this.$http.adornUrl('/generator/bill/saveTypeSelect'),
        method: 'get'
      }).then(({data}) => {
        if (data && data.code === 0) {
          this.typeOptions = data.types
        }
      })
    },
    // activated () {
    //   this.listTypes();
    // },
    // 表单提交
    dataFormSubmit () {
      const btn = document.getElementById('submitBtn');
      // 点击后立刻禁用，防止重复点
      btn.disabled = true;
      btn.innerText = "处理中...";
      this.$refs['dataForm'].validate((valid) => {
        if (valid) {
          this.$http({
            url: this.$http.adornUrl(`/generator/bill/${!this.dataForm.id ? 'save' : 'update'}`),
            method: 'post',
            data: this.$http.adornData({
              'id': this.dataForm.id || undefined,
              'time': this.dataForm.time,
              'money': this.dataForm.money,
              'source': this.dataForm.source,
              'payee': this.dataForm.payee,
              'goods': this.dataForm.goods,
              'type': this.dataForm.type
            })
          }).then(({data}) => {
            if (data && data.code === 0) {
              this.$message({
                message: '操作成功',
                type: 'success',
                duration: 1500,
                onClose: () => {
                  this.visible = false
                  this.$emit('refreshDataList')
                  // 执行完再恢复按钮
                  btn.disabled = false;
                  btn.innerText = "确定";
                }
              })
            } else {
              this.$message.error(data.msg)
            }
          })
        }
      })
    }
  }
}
</script>
