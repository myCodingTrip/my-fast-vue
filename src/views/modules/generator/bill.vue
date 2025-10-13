<template>
  <div class="mod-config">
    <el-form :inline="true" :model="dataForm" @keyup.enter.native="getDataList()">
      <el-form-item>
        <el-input-number v-model="dataForm.leastMoney" :min="0" placeholder="金额至少" clearable></el-input-number>
        <el-input v-model="dataForm.search" placeholder="收款方/物品" clearable></el-input>
      </el-form-item>

      <el-form-item>
        <el-select v-model="value" filterable clearable placeholder="请选择">
          <el-option
            v-for="item in searchTypes"
            :key="item"
            :label="item"
            :value="item">
          </el-option>
        </el-select>
      </el-form-item>

      <el-form-item>
        <div class="block">
          <el-date-picker
            v-model="value1"
            type="date"
            placeholder="选择日期"
            value-format="yyyy-MM-dd HH:mm:ss"
            format="yyyy-MM-dd HH:mm:ss">
          </el-date-picker>
          <span class="demonstration">~</span>
          <el-date-picker
            v-model="value2"
            type="date"
            placeholder="选择日期"
            value-format="yyyy-MM-dd HH:mm:ss"
            format="yyyy-MM-dd HH:mm:ss">
          </el-date-picker>
        </div>
      </el-form-item>

      <el-form-item>
        <el-button @click="resetPage();getDataList();stat()">查询</el-button>
        <el-button v-if="isAuth('generator:bill:save')" type="primary" @click="addOrUpdateHandle()">新增</el-button>
        <el-button v-if="isAuth('generator:bill:delete')" type="danger" @click="deleteHandle()"
                   :disabled="dataListSelections.length <= 0">批量删除
        </el-button>
        <el-button type="primary" @click="updateTypeHandle()"
                   :disabled="dataListSelections.length <= 0">修改类型</el-button>
      </el-form-item>
    </el-form>
    <el-table
      :data="dataList"
      border
      v-loading="dataListLoading"
      @selection-change="selectionChangeHandle"
      style="width: 100%;"
      @sort-change='sortChange'>
      <el-table-column
        type="selection"
        header-align="center"
        align="center"
        width="50">
      </el-table-column>
      <el-table-column
        prop="time"
        header-align="center"
        align="center"
        sortable='custom'
        width="200"
        label="交易时间">
        <template slot-scope="scope">
          <el-tooltip placement="top" :content="numberToDay(scope.row.dayOfWeek)">
            <span>{{ scope.row.time }}</span>
          </el-tooltip>
        </template>
      </el-table-column>
      <el-table-column
        prop="money"
        header-align="center"
        align="center"
        width="100"
        label="交易金额">
      </el-table-column>
      <el-table-column
        prop="payee"
        header-align="center"
        align="center"
        label="交易对方">
      </el-table-column>
      <el-table-column
        prop="goods"
        header-align="center"
        align="center"
        label="商品">
      </el-table-column>
      <el-table-column
        prop="source"
        header-align="center"
        align="center"
        width="100"
        label="支付方式">
      </el-table-column>
      <el-table-column
        prop="type"
        header-align="center"
        align="center"
        width="100"
        label="消费类型">
      </el-table-column>
      <el-table-column
        fixed="right"
        header-align="center"
        align="center"
        width="150"
        label="操作">
        <template slot-scope="scope">
          <el-button type="text" size="small" @click="addOrUpdateHandle(scope.row.id)">修改</el-button>
          <el-button type="text" size="small" @click="deleteHandle(scope.row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      @size-change="sizeChangeHandle"
      @current-change="currentChangeHandle"
      :current-page="pageIndex"
      :page-sizes="[10, 20, 50, 100]"
      :page-size="pageSize"
      :total="totalPage"
      layout="total, sizes, prev, pager, next, jumper">
    </el-pagination>

    <div style="width: 400px; float:left">
      <el-table
        :data="statTable"
        style="width: 400px">
        <el-table-column
          prop="type"
          label="消费类型"
          width="180">
        </el-table-column>
        <el-table-column
          prop="sumMoney"
          label="消费总额"
          width="180">
        </el-table-column>
      </el-table>
    </div>

    <!-- 弹窗, 新增 / 修改 -->
    <add-or-update v-if="addOrUpdateVisible" ref="addOrUpdate" @refreshDataList="getDataList"></add-or-update>
    <batchTypeUpdate v-if="updateTypeDialogVisible" ref="batchTypeUpdate" @refreshDataList="getDataList"></batchTypeUpdate>
  </div>
</template>

<style scoped>

</style>

<script>
import AddOrUpdate from './bill-add-or-update'
import batchTypeUpdate from './bill-batchTypeUpdate'

export default {
  data () {
    return {
      searchTypes: [],
      value: '',
      value1: '',
      value2: '',
      dataForm: {
        key: ''
      },
      statTable: [],
      dataList: [],
      pageIndex: 1,
      pageSize: 10,
      totalPage: 0,
      dataListLoading: false,
      dataListSelections: [],
      addOrUpdateVisible: false,
      updateTypeDialogVisible: true,
      order: '',
      selectedOption: null
    }
  },
  components: {
    AddOrUpdate,
    batchTypeUpdate
  },
  activated () {
    this.listTypes()
    this.getDataList()
    this.stat()
  },
  methods: {
    // 获取分类列表
    listTypes () {
      this.$http({
        url: this.$http.adornUrl('/generator/bill/listTypes'),
        method: 'get'
      }).then(({data}) => {
        if (data && data.code === 0) {
          this.searchTypes = data.types
        }
      })
    },
    resetPage () {
      this.pageIndex = 1
    },
    numberToDay(num) {
      const dayMap = {
        1: '星期一',
        2: '星期二',
        3: '星期三',
        4: '星期四',
        5: '星期五',
        6: '星期六',
        7: '星期日'
      };
      return dayMap[num] || '无效的数字';
    },
    // 获取数据列表
    getDataList () {
      this.dataListLoading = true
      this.$http({
        url: this.$http.adornUrl('/generator/bill/list'),
        method: 'get',
        params: this.$http.adornParams({
          'page': this.pageIndex,
          'limit': this.pageSize,
          'leastMoney': this.dataForm.leastMoney,
          'search': this.dataForm.search,
          'type': this.value,
          'start': this.value1,
          'end': this.value2,
          'column': this.column,
          'order': this.order
        })
      }).then(({data}) => {
        if (data && data.code === 0) {
          this.dataList = data.page.list
          this.totalPage = data.page.totalCount
        } else {
          this.dataList = []
          this.totalPage = 0
        }
        this.dataListLoading = false
      })
    },
    sortChange: function (column, prop, order) {
      //console.log(column + '-' + column.prop + '-' + column.order)
      this.order = column.order
      this.getDataList()
    },
    // 获取统计数据
    stat () {
      this.$http({
        url: this.$http.adornUrl('/generator/bill/stat'),
        method: 'get',
        params: this.$http.adornParams({
          'page': this.pageIndex,
          'limit': this.pageSize,
          'leastMoney': this.dataForm.leastMoney,
          'search': this.dataForm.search,
          'type': this.value,
          'start': this.value1,
          'end': this.value2
        })
      }).then(({data}) => {
        if (data && data.code === 0) {
          this.statTable = data.stat
        }
      })
    },
    // 每页数
    sizeChangeHandle (val) {
      this.pageSize = val
      this.pageIndex = 1
      this.getDataList()
    },
    // 当前页
    currentChangeHandle (val) {
      this.pageIndex = val
      this.getDataList()
    },
    // 多选
    selectionChangeHandle (val) {
      this.dataListSelections = val
    },
    // 新增 / 修改
    addOrUpdateHandle (id) {
      this.addOrUpdateVisible = true
      this.$nextTick(() => {
        this.$refs.addOrUpdate.init(id)
        this.$refs.addOrUpdate.listTypes()
      })
    },
    updateTypeHandle () {
      this.updateTypeDialogVisible = true
      const ids = this.dataListSelections.map(item => {
        return item.id
      })
      this.$refs.batchTypeUpdate.init(ids)
      this.$refs.batchTypeUpdate.listTypes()
    },
    // 删除
    deleteHandle (id) {
      var ids = id ? [id] : this.dataListSelections.map(item => {
        return item.id
      })
      this.$confirm(`确定对[id=${ids.join(',')}]进行[${id ? '删除' : '批量删除'}]操作?`, '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$http({
          url: this.$http.adornUrl('/generator/bill/delete'),
          method: 'delete',
          data: this.$http.adornData(ids, false)
        }).then(({data}) => {
          if (data && data.code === 0) {
            this.$message({
              message: '操作成功',
              type: 'success',
              duration: 1500,
              onClose: () => {
                this.getDataList()
              }
            })
          } else {
            this.$message.error(data.msg)
          }
        })
      })
    }
  }
}
</script>
