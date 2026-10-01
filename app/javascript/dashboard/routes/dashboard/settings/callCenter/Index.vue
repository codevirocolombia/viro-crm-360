<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue';
import { useAlert } from 'dashboard/composables';
import SettingsLayout from '../SettingsLayout.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import callCenterConfigurationAPI from 'dashboard/api/callCenterConfiguration';

const isLoading = ref(false);
const isSaving = ref(false);

let refreshInterval = null;
let isRefreshing = false;

const configuration = ref({
  release_delay_seconds: 60,
  call_centers: [],
});

const form = ref({
  release_delay_seconds: 60,
});

const callCenters = computed(() => configuration.value.call_centers || []);

const loadConfiguration = async ({
  showLoading = true,
  syncForm = true,
  silent = false,
} = {}) => {
  if (isRefreshing) return;

  isRefreshing = true;
  if (showLoading) isLoading.value = true;

  try {
    const response = await callCenterConfigurationAPI.get();
    configuration.value = response.data;

    // Solo al cargar inicialmente o guardar; el refresco no altera un campo
    // que el administrador pueda estar editando.
    if (syncForm) {
      form.value.release_delay_seconds = response.data.release_delay_seconds;
    }
  } catch {
    if (!silent) {
      useAlert('No se pudo cargar la configuración de Call Center');
    }
  } finally {
    if (showLoading) isLoading.value = false;
    isRefreshing = false;
  }
};

const saveConfiguration = async () => {
  isSaving.value = true;

  try {
    const response = await callCenterConfigurationAPI.update({
      release_delay_seconds: Number(form.value.release_delay_seconds),
    });

    configuration.value = response.data;
    form.value.release_delay_seconds = response.data.release_delay_seconds;
    useAlert('Configuración guardada correctamente');
  } catch (error) {
    useAlert(
      error?.response?.data?.error ||
        'No se pudo guardar la configuración'
    );
  } finally {
    isSaving.value = false;
  }
};

const limitLabel = callCenter =>
  callCenter.conversation_assignment_limit ?? 'Sin límite';

const statusLabel = callCenter => {
  if (!callCenter.in_shift) return 'Fuera de jornada';
  if (!callCenter.has_capacity) return 'Cupo completo';
  return 'En jornada';
};

const statusClass = callCenter => {
  if (!callCenter.in_shift) return 'bg-n-alpha-3 text-n-slate-11';
  if (!callCenter.has_capacity) return 'bg-amber-100 text-amber-800';
  return 'bg-green-100 text-green-800';
};

onMounted(() => {
  loadConfiguration();

  refreshInterval = window.setInterval(() => {
    loadConfiguration({
      showLoading: false,
      syncForm: false,
      silent: true,
    });
  }, 5000);
});

onBeforeUnmount(() => {
  if (refreshInterval) {
    window.clearInterval(refreshInterval);
  }
});
</script>

<template>
  <SettingsLayout
    :is-loading="isLoading"
    loading-message="Cargando Call Center"
  >
    <template #header>
      <BaseSettingsHeader
        title="Call Center"
        description="Consulta la disponibilidad y capacidad de los agentes Call Center."
      />
    </template>

    <template #body>
      <div class="flex w-full max-w-4xl flex-col gap-6 border-t border-n-weak pt-6">
        <section class="rounded-lg border border-n-weak bg-n-solid-1 p-5">
          <div class="mb-4">
            <h2 class="text-sm font-semibold text-n-slate-12">
              Tiempo de prioridad
            </h2>
            <p class="mt-1 text-xs leading-5 text-n-slate-11">
              Tiempo durante el cual los agentes Call Center tienen prioridad
              para tomar una conversación nueva.
            </p>
          </div>

          <form
            class="flex flex-wrap items-end gap-3"
            @submit.prevent="saveConfiguration"
          >
            <label class="flex flex-col gap-2">
              <span class="text-sm font-medium text-n-slate-12">
                Tiempo de espera en segundos
              </span>
              <input
                v-model.number="form.release_delay_seconds"
                type="number"
                min="15"
                max="600"
                class="h-10 w-40 rounded-md border border-n-weak bg-n-alpha-2 px-3 text-sm text-n-slate-12 outline-none focus:border-n-brand"
              />
            </label>

            <button
              type="submit"
              class="mb-[16px] h-10 rounded-md bg-[#1f93ff] px-4 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:opacity-60"
              :disabled="isSaving"
            >
              {{ isSaving ? 'Guardando...' : 'Guardar' }}
            </button>
          </form>
        </section>

        <section class="rounded-lg border border-n-weak bg-n-solid-1 p-5">
          <div class="mb-4">
            <h2 class="text-sm font-semibold text-n-slate-12">
              Estado de Call Center
            </h2>
            <p class="mt-1 text-xs leading-5 text-n-slate-11">
              La jornada se determina según la configuración de Control de acceso.
            </p>
          </div>

          <div
            v-if="!callCenters.length"
            class="rounded-md border border-dashed border-n-weak p-4 text-sm text-n-slate-11"
          >
            No hay usuarios Call Center creados. Las conversaciones nuevas se
            habilitarán inmediatamente para agentes y supervisores.
          </div>

          <div v-else class="divide-y divide-n-weak">
            <article
              v-for="callCenter in callCenters"
              :key="callCenter.id"
              class="flex items-center justify-between gap-4 py-4"
            >
              <div class="min-w-0">
                <h3 class="truncate text-sm font-semibold text-n-slate-12">
                  {{ callCenter.name }}
                </h3>
                <p class="truncate text-xs text-n-slate-11">
                  {{ callCenter.email }}
                </p>
              </div>

              <div class="flex shrink-0 items-center gap-4">
                <div class="text-right">
                  <p class="text-sm font-semibold text-n-slate-12">
                    {{ callCenter.assigned_conversation_count }}/{{ limitLabel(callCenter) }}
                  </p>
                  <p class="text-xs text-n-slate-11">
                    Conversaciones activas
                  </p>
                </div>

                <span
                  class="rounded-full px-3 py-1 text-xs font-semibold"
                  :class="statusClass(callCenter)"
                >
                  {{ statusLabel(callCenter) }}
                </span>
              </div>
            </article>
          </div>
        </section>
      </div>
    </template>
  </SettingsLayout>
</template>
