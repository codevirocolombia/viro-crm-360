<script setup>
import { computed, onMounted, ref } from 'vue';
import { useAlert } from 'dashboard/composables';
import { useStore, useMapGetter } from 'dashboard/composables/store';
import SettingsLayout from '../SettingsLayout.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import Avatar from 'next/avatar/Avatar.vue';

const store = useStore();
const agents = useMapGetter('agents/getAgents');
const uiFlags = useMapGetter('agents/getUIFlags');
const updatingAgentIds = ref([]);

const visibleUsers = computed(() =>
  agents.value.filter(agent => agent.role !== 'administrator')
);

const limitOptions = computed(() => [
  ...Array.from({ length: 20 }, (_, index) => ({
    label: String(index + 1),
    value: index + 1,
  })),
  {
    label: 'Sin límite',
    value: '',
  },
]);
onMounted(() => {
  store.dispatch('agents/get');
});

const updateLimit = async (agent, event) => {
  const selectedValue = event.target.value;
  const conversationAssignmentLimit =
    selectedValue === '' ? null : Number(selectedValue);

  updatingAgentIds.value.push(agent.id);

  try {
    await store.dispatch('agents/update', {
      id: agent.id,
      conversation_assignment_limit: conversationAssignmentLimit,
    });
    useAlert('Límite actualizado correctamente');
  } catch {
    useAlert('No se pudo actualizar el límite');
  } finally {
    updatingAgentIds.value = updatingAgentIds.value.filter(id => id !== agent.id);
  }
};

const isUpdating = agentId => updatingAgentIds.value.includes(agentId);
</script>

<template>
  <SettingsLayout
    :is-loading="uiFlags.isFetching"
    loading-message="Cargando agentes"
    :no-records-found="!visibleUsers.length"
    no-records-message="No hay agentes para mostrar"
  >
    <template #header>
      <BaseSettingsHeader
        title="Límites de conversaciones"
        description="Define cuántas conversaciones activas puede tener asignadas cada agente. Los supervisores no tienen límite."
      />
    </template>

    <template #body>
      <div class="divide-y divide-n-weak border-t border-n-weak">
        <div
          v-for="agent in visibleUsers"
          :key="agent.id"
          class="grid grid-cols-[minmax(0,1fr)_80px] items-center gap-4 py-4"
        >
          <div class="flex items-center gap-4 min-w-0">
            <Avatar
              :src="agent.thumbnail"
              :name="agent.name"
              :status="agent.availability_status"
              :size="40"
              hide-offline-status
            />
            <div class="min-w-0">
              <div class="text-heading-3 text-n-slate-12 truncate">
                {{ agent.name }}
              </div>
              <div class="text-body-main text-n-slate-11 truncate">
                {{ agent.email }}
              </div>
            </div>
          </div>

          <span
          v-if="agent.role === 'supervisor'"
          class="w-20 justify-self-end text-center text-sm font-medium text-n-slate-11"
            >
              Supervisor
          </span>

          <select
            v-else
            class="w-28 h-8 justify-self-end rounded-lg border border-n-weak bg-n-alpha-1 px-2 text-sm text-n-slate-12 outline-none"
            :value="agent.conversation_assignment_limit ?? ''"
            :disabled="isUpdating(agent.id)"
            @change="updateLimit(agent, $event)"
          >
<option
  v-for="limit in limitOptions"
  :key="limit.value === '' ? 'unlimited' : limit.value"
  :value="limit.value"
>
  {{ limit.label }}
</option>
          </select>
        </div>
      </div>
    </template>
  </SettingsLayout>
</template>
