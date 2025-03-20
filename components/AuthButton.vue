<template>
  <div>
    <template v-if="user">
      <button @click="handleSignOut" class="btn btn-ghost">
        退出登录
      </button>
    </template>
    <template v-else>
      <button @click="showModal" class="btn btn-primary">
        登录/注册
      </button>
      <dialog ref="authModal" class="modal">
        <div class="modal-box">
          <h3 class="font-bold text-lg mb-4">登录/注册</h3>
          <p class="text-sm mb-4">首次使用邮箱将自动为您注册账号</p>
          <form @submit.prevent="handleSignIn">
            <div class="form-control">
              <label class="label">
                <span class="label-text">邮箱</span>
              </label>
              <input 
                type="email" 
                v-model="email" 
                class="input input-bordered" 
                required
              />
            </div>
            <div class="form-control mt-4">
              <label class="label">
                <span class="label-text">密码</span>
              </label>
              <input 
                type="password" 
                v-model="password" 
                class="input input-bordered" 
                required
              />
            </div>
            <div class="modal-action">
              <button type="button" class="btn" @click="closeModal">取消</button>
              <button type="submit" class="btn btn-primary">登录/注册</button>
            </div>
          </form>
        </div>
        <form method="dialog" class="modal-backdrop">
          <button>close</button>
        </form>
      </dialog>
    </template>
  </div>
</template>

<script setup lang="ts">
const user = useSupabaseUser()
const client = useSupabaseClient()
const authModal = ref<HTMLDialogElement | null>(null)
const email = ref('')
const password = ref('')

const showModal = () => {
  authModal.value?.showModal()
}

const closeModal = () => {
  authModal.value?.close()
}

const handleSignIn = async () => {
  try {
    // 尝试登录
    const { error } = await client.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })
    
    // 如果登录失败且是因为用户不存在，则自动注册
    if (error && error.message.includes('Invalid login credentials')) {
      const { error: signUpError } = await client.auth.signUp({
        email: email.value,
        password: password.value
      })
      
      if (signUpError) {
        alert('注册失败: ' + signUpError.message)
        return
      }
      
      alert('已为您自动注册并登录')
    } else if (error) {
      alert('登录失败: ' + error.message)
      return
    }
    
    closeModal()
    email.value = ''
    password.value = ''
  } catch (err) {
    console.error('登录错误:', err)
    alert('登录过程中发生错误')
  }
}

const handleSignOut = async () => {
  try {
    await client.auth.signOut()
  } catch (err) {
    console.error('退出登录错误:', err)
    alert('退出登录过程中发生错误')
  }
}
</script>