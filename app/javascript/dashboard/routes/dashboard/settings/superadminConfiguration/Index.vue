<script setup>
import { onMounted, ref } from 'vue';
import { useAlert } from 'dashboard/composables';
import SettingsLayout from '../SettingsLayout.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import superadminConfigurationAPI from 'dashboard/api/superadminConfiguration';

const isLoading = ref(false);
const isSaving = ref(false);
const isResetting = ref(false);

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

const assetFields = [
  {
    key: 'logo',
    title: 'Logo black',
    description: 'Se usa en fondos claros y pantallas principales.',
    previewClass: 'bg-white',
  },
  {
    key: 'logo_dark',
    title: 'Logo white',
    description: 'Se usa en fondos oscuros como el login.',
    previewClass: 'bg-black',
  },
  {
    key: 'logo_thumbnail',
    title: 'Favicon',
    description: 'Se usa en la pestaña del navegador y logo compacto.',
    previewClass: 'bg-white',
    isFavicon: true,
  },
];

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

const reloadAfterChange = () => {
  setTimeout(() => window.location.reload(), 800);
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
    reloadAfterChange();
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

const resetConfiguration = async () => {
  const confirmed = window.confirm(
    '¿Seguro que quieres restaurar el nombre, logos y favicon por defecto?'
  );

  if (!confirmed) return;

  isResetting.value = true;

  try {
    const response = await superadminConfigurationAPI.reset();
    form.value = response.data;
    files.value = {
      logo: null,
      logo_dark: null,
      logo_thumbnail: null,
    };

    useAlert('Configuración restaurada correctamente');
    reloadAfterChange();
  } catch (error) {
    useAlert(
      error?.response?.data?.error ||
        error?.response?.data?.message ||
        'No se pudo restaurar la configuración'
    );
  } finally {
    isResetting.value = false;
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
        class="flex flex-col gap-6 border-t border-n-weak pt-6 w-full max-w-4xl"
        @submit.prevent="saveConfiguration"
      >
        <section class="rounded-lg border border-n-weak bg-n-solid-1 p-5">
          <label class="flex flex-col gap-2">
            <span class="text-sm font-semibold text-n-slate-12">
              Nombre del CRM
            </span>
            <input
              v-model="form.installation_name"
              type="text"
              class="h-10 rounded-md border border-n-weak bg-n-alpha-2 px-3 text-sm text-n-slate-12 outline-none focus:border-n-brand"
            />
          </label>
        </section>

        <section class="grid grid-cols-1 gap-4">
          <article
            v-for="asset in assetFields"
            :key="asset.key"
            class="grid grid-cols-1 gap-4 rounded-lg border border-n-weak bg-n-solid-1 p-5 md:grid-cols-[180px_minmax(0,1fr)_190px] md:items-center"
          >
            <div>
              <h2 class="text-sm font-semibold text-n-slate-12">
                {{ asset.title }}
              </h2>
              <p class="mt-1 text-xs leading-5 text-n-slate-11">
                {{ asset.description }}
              </p>
            </div>

            <div class="flex items-center gap-4 min-w-0">
              <div
                class="flex items-center justify-center rounded-md border border-n-weak p-3"
                :class="[
                  asset.previewClass,
                  asset.isFavicon ? 'size-16' : 'h-20 w-40',
                ]"
              >
                <img
                  v-if="form[asset.key]"
                  :src="form[asset.key]"
                  :class="asset.isFavicon ? 'size-10 object-contain' : 'max-h-14 max-w-32 object-contain'"
                />
              </div>

              <div class="min-w-0">
                <p class="truncate text-sm font-medium text-n-slate-12">
                  {{ files[asset.key]?.name || 'Archivo actual' }}
                </p>
                <p class="text-xs text-n-slate-11">
                  PNG, JPG, SVG, WEBP o ICO
                </p>
              </div>
            </div>

            <div class="flex md:justify-end">
              <input
                :id="`superadmin-${asset.key}`"
                type="file"
                accept="image/png,image/jpeg,image/svg+xml,image/webp,image/x-icon"
                class="hidden"
                @change="handleFileChange(asset.key, $event)"
              />
              <label
                :for="`superadmin-${asset.key}`"
                class="inline-flex h-9 cursor-pointer items-center justify-center rounded-md border border-n-weak bg-n-alpha-2 px-3 text-sm font-medium text-n-slate-12 transition-colors hover:bg-n-alpha-3"
              >
                Seleccionar archivo
              </label>
            </div>
          </article>
        </section>

        <div class="flex flex-wrap items-center gap-3">
          <button
            type="submit"
            class="h-10 rounded-md bg-[#1f93ff] px-4 text-sm font-semibold text-white transition-colors hover:bg-[#1a7edb] disabled:cursor-not-allowed disabled:opacity-60"
            :disabled="isSaving || isResetting"
          >
            {{ isSaving ? 'Guardando...' : 'Guardar cambios' }}
          </button>

          <button
            type="button"
            class="h-10 rounded-md border border-n-weak bg-n-alpha-2 px-4 text-sm font-semibold text-n-slate-12 transition-colors hover:bg-n-alpha-3 disabled:cursor-not-allowed disabled:opacity-60"
            :disabled="isSaving || isResetting"
            @click="resetConfiguration"
          >
            {{ isResetting ? 'Restaurando...' : 'Restaurar valores por defecto' }}
          </button>
        </div>
      </form>
    </template>
  </SettingsLayout>
</template>
