<script setup>
import { onMounted, ref } from 'vue';
import { useAlert } from 'dashboard/composables';
import SettingsLayout from '../SettingsLayout.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import superadminConfigurationAPI from 'dashboard/api/superadminConfiguration';

const isLoading = ref(false);
const isSaving = ref(false);

const form = ref({
  installation_name: '',
  logo: '',
  logo_dark: '',
  logo_thumbnail: '',
});

const files = ref({
  logo: null,
  logo_dark: null,
  logo_thumbnail: null,
});

const loadConfiguration = async () => {
  isLoading.value = true;

  try {
    const response = await superadminConfigurationAPI.get();
    form.value = response.data;
  } finally {
    isLoading.value = false;
  }
};

const handleFileChange = (key, event) => {
  const [file] = event.target.files || [];
  files.value[key] = file || null;
};

const saveConfiguration = async () => {
  isSaving.value = true;

  const formData = new FormData();
  formData.append('installation_name', form.value.installation_name || '');

  Object.entries(files.value).forEach(([key, file]) => {
    if (file) formData.append(key, file);
  });

  try {
    const response = await superadminConfigurationAPI.update(formData);
    form.value = response.data;
    files.value = {
      logo: null,
      logo_dark: null,
      logo_thumbnail: null,
    };

    useAlert('Configuración actualizada correctamente');
    setTimeout(() => window.location.reload(), 800);
  } catch (error) {
    useAlert(
      error?.response?.data?.error ||
        error?.response?.data?.message ||
        'No se pudo actualizar la configuración'
    );
  } finally {
    isSaving.value = false;
  }
};

onMounted(loadConfiguration);
</script>

<template>
  <SettingsLayout
    :is-loading="isLoading"
    loading-message="Cargando configuración"
  >
    <template #header>
      <BaseSettingsHeader
        title="Configuración Superadmin"
        description="Configura el nombre del CRM, los logos y el favicon de la instalación."
      />
    </template>

    <template #body>
      <form
        class="flex flex-col gap-6 border-t border-n-weak pt-6 w-full max-w-3xl"
        @submit.prevent="saveConfiguration"
      >
        <label class="flex flex-col gap-2">
          <span class="text-sm font-medium text-n-slate-12">Nombre del CRM</span>
          <input
            v-model="form.installation_name"
            type="text"
            class="h-10 rounded-md border border-n-weak bg-n-alpha-2 px-3 text-sm text-n-slate-12"
          />
        </label>

        <label class="flex flex-col gap-2">
          <span class="text-sm font-medium text-n-slate-12">Logo black</span>
          <img
            v-if="form.logo"
            :src="form.logo"
            class="h-14 w-fit max-w-xs rounded border border-n-weak bg-white p-2"
          />
          <input
            type="file"
            accept="image/png,image/jpeg,image/svg+xml,image/webp"
            class="text-sm text-n-slate-11"
            @change="handleFileChange('logo', $event)"
          />
        </label>

        <label class="flex flex-col gap-2">
          <span class="text-sm font-medium text-n-slate-12">Logo white</span>
          <img
            v-if="form.logo_dark"
            :src="form.logo_dark"
            class="h-14 w-fit max-w-xs rounded border border-n-weak bg-black p-2"
          />
          <input
            type="file"
            accept="image/png,image/jpeg,image/svg+xml,image/webp"
            class="text-sm text-n-slate-11"
            @change="handleFileChange('logo_dark', $event)"
          />
        </label>

        <label class="flex flex-col gap-2">
          <span class="text-sm font-medium text-n-slate-12">Favicon</span>
          <img
            v-if="form.logo_thumbnail"
            :src="form.logo_thumbnail"
            class="size-12 rounded border border-n-weak bg-white p-2"
          />
          <input
            type="file"
            accept="image/png,image/jpeg,image/svg+xml,image/webp,image/x-icon"
            class="text-sm text-n-slate-11"
            @change="handleFileChange('logo_thumbnail', $event)"
          />
        </label>

        <div>
          <button
            type="submit"
            class="h-10 rounded-md bg-[#1f93ff] px-4 text-sm font-semibold text-white transition-colors hover:bg-[#1a7edb] disabled:cursor-not-allowed disabled:opacity-60"
            :disabled="isSaving"
          >
            {{ isSaving ? 'Guardando...' : 'Guardar cambios' }}
          </button>
        </div>
      </form>
    </template>
  </SettingsLayout>
</template>
