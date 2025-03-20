<template>
  <div>
    <div class="flex justify-between items-center mb-4">
      <div class="form-control">
        <label class="label">
          <span class="label-text">表格大小</span>
        </label>
        <select v-model="gridSize" class="select select-bordered" :disabled="isPlaying">
          <option value="3">3 x 3</option>
          <option value="4">4 x 4</option>
          <option value="5">5 x 5</option>
        </select>
      </div>
      <button @click="startGame" class="btn btn-primary" :disabled="isPlaying">
        开始训练
      </button>
    </div>

    <div v-if="isPlaying" class="mb-4">
      <div class="text-xl font-bold">时间: {{ formatTime(timer) }}</div>
    </div>

    <div class="grid gap-2" :style="gridStyle">
      <button
        v-for="num in numbers"
        :key="num"
        @click="handleNumberClick(num)"
        class="btn btn-outline aspect-square text-lg font-bold"
        :disabled="!isPlaying || num !== currentNumber"
      >
        {{ num }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const emit = defineEmits(['complete'])

const gridSize = ref(3)
const isPlaying = ref(false)
const numbers = ref<number[]>([])
const currentNumber = ref(1)
const timer = ref(0)
let timerInterval: NodeJS.Timer | null = null

const gridStyle = computed(() => ({
  gridTemplateColumns: `repeat(${gridSize.value}, minmax(0, 1fr))`
}))

const formatTime = (time: number) => {
  return (time / 1000).toFixed(2) + 's'
}

const generateNumbers = () => {
  const total = gridSize.value * gridSize.value
  const nums = Array.from({ length: total }, (_, i) => i + 1)
  return nums.sort(() => Math.random() - 0.5)
}

const startGame = () => {
  numbers.value = generateNumbers()
  currentNumber.value = 1
  isPlaying.value = true
  timer.value = 0
  timerInterval = setInterval(() => {
    timer.value += 10
  }, 10)
}

const handleNumberClick = (num: number) => {
  if (num === currentNumber.value) {
    if (num === numbers.value.length) {
      // Game completed
      if (timerInterval) clearInterval(timerInterval)
      isPlaying.value = false
      emit('complete', {
        time: timer.value / 1000,
        gridSize: gridSize.value
      })
    } else {
      currentNumber.value++
    }
  }
}

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval)
})
</script>