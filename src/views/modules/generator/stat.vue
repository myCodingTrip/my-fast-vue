<template>
  <div>
    <div class="block">
      <el-date-picker
        v-model="year"
        type="year"
        placeholder="选择年"
        format="yyyy"
        value-format="yyyy"
        @change="getData">
      </el-date-picker>
      <el-select v-model="month"
                 clearable
                 placeholder="选择月"
                 @change="getData">
        <el-option
          v-for="item in months"
          :key="item.value"
          :label="item.label"
          :value="item.value">
        </el-option>
      </el-select>
      <span style="padding-left: 20px">总花费：</span><span v-text="total" style="font-size: 22px;color: red"></span>
    </div>
    <div id="pie-chart" style="height: 400px"></div>

    <div class="block">
      <el-date-picker
        v-model="lineStart"
        type="month"
        format="yyyy-MM"
        value-format="yyyy-MM-01 00:00:00"
        placeholder="开始"
        @change="getLineData">
      </el-date-picker>
    </div>
    <div class="block">
      <el-date-picker
        v-model="lineEnd"
        type="month"
        format="yyyy-MM"
        value-format="yyyy-MM-01 00:00:00"
        placeholder="结束"
        @change="getLineData">
      </el-date-picker>
    </div>
    <div id="line-chart" style="height: 400px"></div>
  </div>
</template>

<script>
import Vue from 'vue'
import ECharts from 'echarts'

Vue.prototype.$echarts = ECharts

export default {
  data () {
    return {
      //饼图数据
      year: '',
      month: undefined,
      months: [{
        value: '1',
        label: '一月'
      }, {
        value: '2',
        label: '二月'
      }, {
        value: '3',
        label: '三月'
      }, {
        value: '4',
        label: '四月'
      }, {
        value: '5',
        label: '五月'
      }, {
        value: '6',
        label: '六月'
      }, {
        value: '7',
        label: '七月'
      }, {
        value: '8',
        label: '八月'
      }, {
        value: '9',
        label: '九月'
      }, {
        value: '10',
        label: '十月'
      }, {
        value: '11',
        label: '十一月'
      }, {
        value: '12',
        label: '十二月'
      }],
      total: 0,
      lineChart: null,
      pieChart: null,
      pieData: [],
      pieOption: {
        //鼠标放上去有提示
        tooltip: {
          trigger: 'item'
        },
        series: [
          {
            type: 'pie',
            radius: '50%',
            data: []
          },
        ]
      },
      //折线图数据
      lineStart: null,
      lineEnd: null,
      lineOption: {
        tooltip: {
          trigger: 'item'
        },
        xAxis: {
          type: 'category',
          data: this.lineX
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            data: this.lineY,
            type: 'line'
          }
        ]
      }
    }
  },
  methods: {
    getData () {
      let year
      let month
      if (this.year) {
        year = this.year
        month = this.month
      }

      this.$http({
        url: this.$http.adornUrl('/generator/bill/pieStat'),
        method: 'get',
        params: this.$http.adornParams({
          'year': year,
          'month': month
        })
      }).then(({data}) => {
        this.pieOption.series[0].data = data.stat
        this.pieChart.setOption(this.pieOption)

        this.total = 0
        for (const num of data.stat) {
          this.total += num.value
        }
      })
    },
    getLineData () {
      this.$http({
        url: this.$http.adornUrl('/generator/bill/monthStat'),
        method: 'get',
        params: this.$http.adornParams({
          'start': this.lineStart,
          'end': this.lineEnd
        })
      }).then(({data}) => {
        //this.lineX = data.stat.timeList
        //this.lineY = data.stat.moneyList
        // console.log(this.lineX)
        this.lineOption.xAxis.data = data.stat.timeList
        this.lineOption.series[0].data = data.stat.moneyList
        this.lineChart.setOption(this.lineOption)

        // this.total = 0
        // for (const num of data.stat) {
        //   console.log(num)
        //   this.total += num.value
        // }
      })
    }
  },
  activated () {
    this.getData()
    this.getLineData()
  },
  mounted () {
    this.pieChart = this.$echarts.init(document.getElementById('pie-chart'))
    this.lineChart = this.$echarts.init(document.getElementById('line-chart'))

    // 创建一个 Date 对象，并将日期设置为当天
    let currentDate = new Date()

    // 获取当前月份和年份
    let currentMonth = currentDate.getMonth() // 获取的月份是从 0 开始计数的，0 表示一月，1 表示二月，以此类推
    let currentYear = currentDate.getFullYear()

    // 计算上个月的年份和月份
    let lastMonthYear, lastMonth
    if (currentMonth === 0) {
      // 如果当前月份是一月，则上个月是去年的十二月
      lastMonthYear = currentYear - 1
      lastMonth = 11 // 十二月的索引是 11
    } else {
      lastMonthYear = currentYear
      lastMonth = currentMonth - 1
    }

    // 输出上个月的年份和月份
    console.log('上个月的年份：' + lastMonthYear)
    console.log('上个月的月份：' + (lastMonth + 1)) // 月份是从 1 开始计数的，需要加 1

    this.year = lastMonthYear + ''
    this.month = this.months[lastMonth].value

    let mon = lastMonth + 1
    let monStr = mon<=9?'0'+mon:mon
    this.lineStart = (lastMonthYear - 1) + '-' + monStr + '-01 00:00:00'
    this.lineEnd = lastMonthYear + '-' + monStr + '-01 00:00:00'
  }
}
</script>
