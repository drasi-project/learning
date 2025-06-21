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
import { ref, onMounted, onUnmounted } from 'vue';

const props = defineProps({
  order: Object
});

const elapsedSeconds = ref(0);
const CRITICAL_WAIT_SECONDS = import.meta.env.VITE_CRITICAL_WAIT_SECONDS || 600;

const updateElapsedTime = () => {
  elapsedSeconds.value = Math.floor((Date.now() - new Date(props.order.waitingSinceTimestamp).getTime()) / 1000);
};

const formatTime = (seconds) => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
};

onMounted(() => {
  updateElapsedTime();
  const interval = setInterval(updateElapsedTime, 1000);
  onUnmounted(() => clearInterval(interval));
});
</script>

<template>
  <div :class="[
    'bg-gradient-to-r p-3 rounded-lg border transition-colors duration-200',
    elapsedSeconds >= CRITICAL_WAIT_SECONDS 
      ? 'from-red-50 to-transparent border-red-100' 
      : 'from-yellow-50 to-transparent border-yellow-100'
  ]">
    <div class="flex items-start gap-3">
      <div class="bg-white p-2 rounded shadow-sm">
        <!-- Clock icon -->
        <svg :class="[
          'h-8 w-8',
          elapsedSeconds >= CRITICAL_WAIT_SECONDS ? 'text-red-600' : 'text-yellow-600'
        ]" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/>
          <polyline points="12 6 12 12 16 14"/>
        </svg>
      </div>
      <div class="flex-1">
        <div class="flex justify-between items-start">
          <div>
            <div class="font-medium">Order #{{ order.orderId }}</div>
            <div class="text-sm text-gray-600">
              Customer: {{ order.customerName }}
            </div>
            <div class="flex items-center gap-1 mt-1">
              <svg class="h-3 w-3 text-gray-400" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
              <span :class="[
                'text-xs',
                elapsedSeconds >= CRITICAL_WAIT_SECONDS ? 'text-red-600' : 'text-yellow-600'
              ]">
                Waiting for {{ formatTime(elapsedSeconds) }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>