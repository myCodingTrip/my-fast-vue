<template>
  <!-- 对话框 -->
  <el-dialog
    title="选择一个选项"
    width="30%"
    :visible.sync="visible">
    <span>选择类型：</span>
    <el-select v-model="batchType" filterable clearable placeholder="请选择">
      <el-option
        v-for="item in typeOptions"
        :key="item.type"
        :label="item.type"
        :value="item.type">
      </el-option>
    </el-select>
    <span slot="footer" class="dialog-footer">
        <el-button type="primary" @click="dataTypeFormSubmit()">确定</el-button>
      </span>
  </el-dialog>
</template>

<script>
export default {
  name: 'batchTypeUpdate',
  data () {
    return {
      visible: false,
      typeOptions: [],
      batchType: '',
      ids: undefined
    }
  },
  methods: {
    init (ids) {
      this.ids = ids
      this.visible = true
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
    dataTypeFormSubmit () {
      for (const c_id of this.ids) {
        this.$http({
          url: this.$http.adornUrl(`/generator/bill/update`),
          method: 'post',
          data: this.$http.adornData({
            'id': c_id,
            'type': this.batchType
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
              }
            })
          } else {
            this.$message.error(data.msg)
          }
        })
      }
    }
  }
}
</script>

<style scoped>
.my-component {
  text-align: center;
  padding: 20px;
}

h1 {
  color: #333;
}

p {
  font-size: 16px;
  color: #666;
}
</style>
