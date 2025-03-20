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
const client = useSupabaseClient<Database>()

const handleComplete = async (data: { time: number, gridSize: number }) => {
  try {
    console.log('正在保存记录:', {
      grid_size: data.gridSize,
      completion_time: data.time,
      user_id: user.value?.id
    })
    
    if (!user.value?.id) {
      console.error('保存记录失败: 用户未登录或用户ID不存在')
      return
    }

    // 首先刷新会话以确保有最新的令牌
    const { data: sessionData, error: sessionError } = await client.auth.getSession()
    
    if (sessionError || !sessionData.session) {
      console.error('获取会话失败，可能需要重新登录:', sessionError)
      return
    }
    
    console.log('当前会话状态:', {
      有效: sessionData.session !== null,
      过期时间: sessionData.session.expires_at ? new Date(sessionData.session.expires_at * 1000).toLocaleString() : '未知',
      用户ID: sessionData.session.user.id
    })

    // 使用刷新后的会话
    const { error } = await client
      .from('schulte_records')
      .insert({
        grid_size: data.gridSize,
        completion_time: data.time,
        user_id: sessionData.session.user.id
      })
    
    if (error) {
      console.error('保存记录失败:', error)
      
      if (error.code === '401' || error.message?.includes('Unauthorized')) {
        // 认证失败，尝试刷新令牌
        const { error: refreshError } = await client.auth.refreshSession()
        
        if (refreshError) {
          console.error('刷新令牌失败:', refreshError)
          alert('您的登录已过期，请重新登录后再试')
          return
        }
        
        // 使用刷新后的令牌重试
        console.log('令牌已刷新，正在重试...')
        const { error: retryError } = await client
          .from('schulte_records')
          .insert({
            grid_size: data.gridSize,
            completion_time: data.time,
            user_id: user.value.id
          })
          
        if (retryError) {
          console.error('重新尝试保存记录失败:', retryError)
          alert('保存记录失败，请稍后再试')
        } else {
          console.log('使用刷新的令牌成功保存记录')
        }
      }
    } else {
      console.log('训练记录已保存')
    }
  } catch (err) {
    console.error('提交记录时发生错误:', err)
  }
}
</script>