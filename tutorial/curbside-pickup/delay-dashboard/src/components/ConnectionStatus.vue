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
import { Wifi, WifiOff } from 'lucide-vue-next';

defineProps({
  connected: Boolean
});
</script>

<template>
  <div :class="[
    'flex items-center gap-1 text-xs px-2 py-1 rounded-full',
    connected ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
  ]">
    <Wifi v-if="connected" class="h-3 w-3" />
    <WifiOff v-else class="h-3 w-3" />
    <span>{{ connected ? 'Live' : 'Disconnected' }}</span>
  </div>
</template>