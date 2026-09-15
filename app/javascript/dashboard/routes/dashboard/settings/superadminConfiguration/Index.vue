<script setup>
import SettingsLayout from '../SettingsLayout.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
</script>

<template>
  <SettingsLayout>
    <template #header>
      <BaseSettingsHeader
        title="Configuración Superadmin"
        description="Configura el nombre del CRM, los logos y el favicon de la instalación."
      />
    </template>

    <template #body>
      <div class="border-t border-n-weak pt-6 text-sm text-n-slate-11">
        Página inicial de Configuración Superadmin.
      </div>
    </template>
  </SettingsLayout>
</template>
