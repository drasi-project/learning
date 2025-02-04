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
import { Wifi, WifiOff } from 'lucide-vue-next'
import * as signalR from '@microsoft/signalr'

const props = defineProps({
  url: {
    type: String,
    required: true
  }
})

const isConnected = ref(false)
let connection = null

onMounted(() => {
  connection = new signalR.HubConnectionBuilder()
    .withUrl(props.url)
    .withAutomaticReconnect()
    .build()

  connection.start()
    .then(() => isConnected.value = true)
    .catch(() => isConnected.value = false)

  connection.onclose(() => isConnected.value = false)
  connection.onreconnecting(() => isConnected.value = false)
  connection.onreconnected(() => isConnected.value = true)
})

onUnmounted(() => {
  if (connection) {
    connection.stop()
  }
})
</script>

<template>
  <!-- Connection status indicator -->
  <div v-if="isConnected" 
       class="flex items-center gap-1 text-xs px-2 py-1 bg-green-100 text-green-800 rounded-full">
    <Wifi class="h-3 w-3" />
    <span>Live</span>
  </div>
  <div v-else 
       class="flex items-center gap-1 text-xs px-2 py-1 bg-red-100 text-red-800 rounded-full">
    <WifiOff class="h-3 w-3" />
    <span>Disconnected</span>
  </div>
</template>