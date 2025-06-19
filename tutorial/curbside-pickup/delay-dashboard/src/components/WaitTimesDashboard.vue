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
import { ref, computed, onMounted } from 'vue';
import ConnectionStatus from './ConnectionStatus.vue';
import DelayedOrder from './DelayedOrder.vue';
import { ResultSet } from '@drasi/signalr-vue';

// Dynamic SignalR URL detection for Codespaces compatibility
const getSignalRUrl = () => {
  const hostname = window.location.hostname;
  
  // Check if we're in GitHub Codespaces
  if (hostname.includes('.github.dev') || hostname.includes('.app.github.dev')) {
    // Extract base URL and construct port-specific URL for port 8080
    const parts = hostname.split('-');
    const portIndex = parts.length - 1;
    const baseUrl = parts.slice(0, portIndex).join('-');
    return `https://${baseUrl}-8080.app.github.dev/hub`;
  } else {
    // Local environment (DevContainer, Kind, etc.)
    return 'http://localhost:8080/hub';
  }
};

// Initialize with the URL immediately, not in onMounted
const signalrUrl = ref(getSignalRUrl());
const queryId = import.meta.env.VITE_QUERY_ID;
const connected = ref(true); // You might want to implement actual connection status logic
</script>

<template>
  <div class="w-full h-full p-4 bg-gray-50">
    <div class="max-w-2xl mx-auto bg-white rounded-xl shadow-lg p-4 flex flex-col min-h-[350px]">
      <div class="flex items-center justify-between border-b pb-3">
        <div class="flex items-center gap-2">
          <div class="bg-yellow-100 p-2 rounded-full">
            <!-- Clock icon -->
            <svg class="text-yellow-600 h-5 w-5" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"/>
              <polyline points="12 6 12 12 16 14"/>
            </svg>
          </div>
          <h2 class="font-bold text-lg">Extended Wait Times</h2>
        </div>
        <ConnectionStatus :connected="connected" />
      </div>

      <div class="overflow-auto flex-1 py-2">
        <div class="space-y-3">
          <ResultSet :url="signalrUrl" :queryId="queryId">
            <template #default="{ item }">
              <DelayedOrder :order="item" />
            </template>
          </ResultSet>
        </div>
      </div>
    </div>
  </div>
</template>