<template>
  <div>
    <div class="tabs tabs-boxed mb-4">
      <a 
        v-for="period in periods" 
        :key="period"
        class="tab"
        :class="{ 'tab-active': selectedPeriod === period }"
        @click="selectedPeriod = period"
      >
        {{ period }}
      </a>
    </div>

    <div v-if="chartData" class="chart-container">
      <Line :data="chartData" :options="chartOptions" class="mb-4" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js'
import dayjs from 'dayjs'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend)

const periods = ['日', '月', '年']
const selectedPeriod = ref('日')
const client = useSupabaseClient()

const fetchData = async () => {
  console.log('开始获取训练记录...')
  const { data, error } = await client
    .from('schulte_records')
    .select('completion_time, created_at')
    .order('created_at', { ascending: true })
  
  if (error) {
    console.error('获取训练记录失败:', error)
    return []
  }
  
  console.log('获取到训练记录:', data)
  return data || []
}

const processData = (data: any[]) => {
  const groupedData = data.reduce((acc: any, record: any) => {
    const date = dayjs(record.created_at)
    const key = selectedPeriod.value === '日' ? date.format('YYYY-MM-DD') :
                selectedPeriod.value === '月' ? date.format('YYYY-MM') :
                date.format('YYYY')
    
    if (!acc[key]) {
      acc[key] = []
    }
    acc[key].push(record.completion_time)
    return acc
  }, {})

  const labels = Object.keys(groupedData)
  const averages = labels.map(key => {
    const times = groupedData[key]
    return times.reduce((a: number, b: number) => a + b, 0) / times.length
  })

  return { labels, averages }
}

interface ChartDataType {
  labels: string[];
  datasets: {
    label: string;
    data: number[];
    borderColor: string;
    tension: number;
  }[];
}

const chartData = ref<ChartDataType | null>(null)
const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    }
  }
}

watch([selectedPeriod], async () => {
  const data = await fetchData()
  const { labels, averages } = processData(data)
  
  chartData.value = {
    labels,
    datasets: [{
      label: '平均完成时间',
      data: averages,
      borderColor: 'rgb(75, 192, 192)',
      tension: 0.1
    }]
  }
}, { immediate: true })
</script>

<style scoped>
.chart-container {
  position: relative;
  height: 300px;
  width: 100%;
}
</style>