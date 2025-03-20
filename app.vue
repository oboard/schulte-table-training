<template>
  <div class="min-h-screen bg-base-200">
    <div class="navbar bg-base-100">
      <div class="flex-1">
        <a class="btn btn-ghost text-xl">舒尔特表格训练</a>
      </div>
      <div class="flex-none">
        <AuthButton />
      </div>
    </div>

    <main class="container mx-auto p-4">
      <div v-if="user">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">训练区</h2>
              <SchulteTable @complete="handleComplete" />
            </div>
          </div>
          <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
              <h2 class="card-title">统计数据</h2>
              <StatsChart />
            </div>
          </div>
        </div>
      </div>
      <div v-else class="text-center py-10">
        <h2 class="text-2xl font-bold mb-4">请先登录</h2>
        <p>登录后开始训练并记录您的进度</p>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import type { Database } from '~/types/supabase'

const user = useSupabaseUser()
const { $supabase } = useNuxtApp()

const handleComplete = async (data: { time: number, gridSize: number }) => {
  try {
    const { error } = await $supabase
      .from('schulte_records')
      .insert({
        grid_size: data.gridSize,
        completion_time: data.time,
        user_id: user.value?.id
      })
    
    if (error) {
      console.error('保存记录失败:', error)
    } else {
      console.log('训练记录已保存')
    }
  } catch (err) {
    console.error('提交记录时发生错误:', err)
  }
}
</script>