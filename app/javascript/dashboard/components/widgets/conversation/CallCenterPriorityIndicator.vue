<script setup>
import { computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import { useCallCenterPriority } from 'dashboard/composables/useCallCenterPriority';

const props = defineProps({
  chat: {
    type: Object,
    required: true,
  },
});

const currentUser = useMapGetter('getCurrentUser');
const { priorityFor } = useCallCenterPriority();

const priority = computed(() =>
  priorityFor(props.chat, currentUser.value?.id)
);

const circumference = 50.27;

const dashOffset = computed(
  () => circumference * (1 - Math.min(1, Math.max(0, priority.value.progress)))
);

const color = computed(() => {
  switch (priority.value.state) {
    case 'assigned_to_current_user':
      return '#1f93ff';
    case 'assigned_to_other_user':
    case 'waiting':
      return '#ef4444';
    case 'available':
      return '#22c55e';
    default:
      return '#6b7280';
  }
});

const tooltip = computed(() => {
  switch (priority.value.state) {
    case 'assigned_to_current_user':
      return 'Esta conversación está asignada a ti';
    case 'assigned_to_other_user':
      return 'Esta conversación está asignada a otra persona';
    case 'waiting':
      return `Call Center tiene prioridad por ${priority.value.remainingSeconds} segundos`;
    case 'available':
      return 'Disponible para agentes y supervisores';
    case 'inactive':
      return 'Conversación no disponible para asignación';
    default:
      return 'Consultando estado de Call Center';
  }
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
        :stroke="color"
        stroke-width="2.5"
        stroke-linecap="round"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="dashOffset"
        class="transition-[stroke-dashoffset,stroke] duration-1000 ease-linear"
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
