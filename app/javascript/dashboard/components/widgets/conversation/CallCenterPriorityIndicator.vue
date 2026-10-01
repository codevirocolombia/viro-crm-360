<script setup>
import { computed } from 'vue';
import { useCallCenterPriority } from 'dashboard/composables/useCallCenterPriority';

const props = defineProps({
  chat: {
    type: Object,
    required: true,
  },
});

const { priorityFor } = useCallCenterPriority();

const priority = computed(() => priorityFor(props.chat));

const circumference = 50.27;

const dashOffset = computed(
  () => circumference * (1 - Math.min(1, Math.max(0, priority.value.progress)))
);

const tooltip = computed(() => {
  if (priority.value.waiting) {
    return `Call Center tiene prioridad por ${priority.value.remainingSeconds} segundos`;
  }

  return 'Disponible para agentes y supervisores';
});
</script>

<template>
  <div
    v-if="priority.visible"
    class="relative flex h-6 w-6 shrink-0 items-center justify-center"
    :title="tooltip"
  >
    <svg
      class="h-6 w-6 -rotate-90"
      viewBox="0 0 20 20"
      aria-hidden="true"
    >
      <circle
        cx="10"
        cy="10"
        r="8"
        fill="none"
        stroke="#374151"
        stroke-width="2.5"
      />

      <circle
        cx="10"
        cy="10"
        r="8"
        fill="none"
        :stroke="priority.waiting ? '#ef4444' : '#22c55e'"
        stroke-width="2.5"
        stroke-linecap="round"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="dashOffset"
        class="transition-[stroke-dashoffset] duration-1000 ease-linear"
      />
    </svg>

    <span
      v-if="priority.waiting"
      class="absolute text-[8px] font-bold leading-none text-n-slate-12"
    >
      {{ priority.remainingSeconds }}
    </span>
  </div>
</template>
