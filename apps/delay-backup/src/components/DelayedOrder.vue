<!--
  Copyright 2025 The Drasi Authors.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { Clock } from 'lucide-vue-next'

const props = defineProps({
  order: {
    type: Object,
    required: true
  }
})

const elapsedSeconds = ref(0)
let timerInterval

const updateElapsedTime = () => {
  elapsedSeconds.value = Math.floor((Date.now() - new Date(props.order.startTime).getTime()) / 1000)
}

onMounted(() => {
  updateElapsedTime()
  timerInterval = setInterval(updateElapsedTime, 1000)
})

onUnmounted(() => {
  if (timerInterval) {
    clearInterval(timerInterval)
  }
})
</script>

<template>
  <div class="p-3 rounded-lg border bg-orange-50 border-orange-100">
    <div class="flex justify-between">
      <div>
        <div class="font-medium">Order #{{ order.orderId }}</div>
        <div class="text-sm text-gray-600">Customer: {{ order.customerName }}</div>
        <div class="flex items-center gap-2 mt-1">
          <div class="px-2 py-0.5 rounded text-xs bg-orange-100 text-orange-700">
            {{ elapsedSeconds }}s elapsed
          </div>
        </div>
      </div>
      <div class="h-12 w-12 rounded-full flex items-center justify-center bg-orange-100 text-orange-500">
        <Clock class="h-6 w-6" />
      </div>
    </div>
  </div>
</template>