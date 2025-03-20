// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase'
  ],
  supabase: {
    redirectOptions: {
      login: '/auth',
      callback: '/',
      exclude: ['/*'],
    },
    // Supabase 配置
    url: process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL,
    key: process.env.SUPABASE_KEY || process.env.VITE_SUPABASE_ANON_KEY,
    // serviceKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
    // 客户端选项
    clientOptions: {
      auth: {
        persistSession: true
      }
    }
  },
  // 确保环境变量可用于运行时
  runtimeConfig: {
    public: {
      supabaseUrl: process.env.VITE_SUPABASE_URL,
      supabaseKey: process.env.VITE_SUPABASE_ANON_KEY
    }
  }
})