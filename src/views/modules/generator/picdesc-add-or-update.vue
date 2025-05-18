<template>
  <el-dialog
    :title="!dataForm.id ? '新增' : '修改'"
    :close-on-click-modal="false"
    :visible.sync="visible">
    <el-form :model="dataForm" :rules="dataRule" ref="dataForm" @keyup.enter.native="dataFormSubmit()" label-width="80px">
    <el-form-item label="" prop="picDesc">
      <el-input v-model="dataForm.picDesc" placeholder=""></el-input>
    </el-form-item>
    <el-form-item label="" prop="lastModified">
      <el-input v-model="dataForm.lastModified" placeholder=""></el-input>
    </el-form-item>
    <el-form-item label="" prop="updateTime">
      <el-input v-model="dataForm.updateTime" placeholder=""></el-input>
    </el-form-item>
    </el-form>
    <span slot="footer" class="dialog-footer">
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" @click="dataFormSubmit()">确定</el-button>
    </span>
  </el-dialog>
</template>

<script>
  export default {
    data () {
      return {
        visible: false,
        dataForm: {
          path: 0,
          picDesc: '',
          lastModified: '',
          updateTime: ''
        },
        dataRule: {
          picDesc: [
            { required: true, message: '不能为空', trigger: 'blur' }
          ],
          lastModified: [
            { required: true, message: '不能为空', trigger: 'blur' }
          ],
          updateTime: [
            { required: true, message: '不能为空', trigger: 'blur' }
          ]
        }
      }
    },
    methods: {
      init (id) {
        this.dataForm.path = id || 0
        this.visible = true
        this.$nextTick(() => {
          this.$refs['dataForm'].resetFields()
          if (this.dataForm.path) {
            this.$http({
              url: this.$http.adornUrl(`/generator/picdesc/info/${this.dataForm.path}`),
              method: 'get',
              params: this.$http.adornParams()
            }).then(({data}) => {
              if (data && data.code === 0) {
                this.dataForm.picDesc = data.picDesc.picDesc
                this.dataForm.lastModified = data.picDesc.lastModified
                this.dataForm.updateTime = data.picDesc.updateTime
              }
            })
          }
        })
      },
      // 表单提交
      dataFormSubmit () {
        this.$refs['dataForm'].validate((valid) => {
          if (valid) {
            this.$http({
              url: this.$http.adornUrl(`/generator/picdesc/${!this.dataForm.path ? 'save' : 'update'}`),
              method: 'post',
              data: this.$http.adornData({
                'path': this.dataForm.path || undefined,
                'picDesc': this.dataForm.picDesc,
                'lastModified': this.dataForm.lastModified,
                'updateTime': this.dataForm.updateTime
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
        })
      }
    }
  }
</script>
