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
import { ref } from 'vue'
import { Clock } from 'lucide-vue-next'
import { ResultSet } from '@drasi/signalr-vue'
import ConnectionStatus from './ConnectionStatus.vue'
import DelayedOrder from './DelayedOrder.vue'

defineEmits(['result'])

const hubUrl = import.meta.env.VITE_SIGNALR_HUB || 'http://localhost:8080/hub'
const delayedOrdersQuery = import.meta.env.VITE_QUERY_DELAYED || "delayed-orders"
const orders = ref([])
</script>

<template>
  <div class="max-w-xl mx-auto bg-white rounded-xl shadow-lg p-4 flex flex-col">
    <div class="flex items-center justify-between border-b pb-3">
      <div class="flex items-center gap-2">
        <div class="bg-orange-100 p-2 rounded-full">
          <Clock class="text-orange-600 h-5 w-5" />
        </div>
        <h2 class="font-bold text-lg">Extended Wait Times</h2>
      </div>
      <ConnectionStatus :url="hubUrl" />
    </div>

    <div class="overflow-auto flex-1 py-2">
      <ResultSet
        :url="hubUrl"
        :queryId="delayedOrdersQuery"
        @result="newOrders => orders = newOrders"
      >
        <template #default>
          <div class="space-y-3">
            <div v-for="order in orders" :key="order.orderId">
              <DelayedOrder :order="order" />
            </div>
          </div>
        </template>
      </ResultSet>
    </div>
  </div>
</template>