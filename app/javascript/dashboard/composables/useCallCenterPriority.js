import { computed, onBeforeUnmount, onMounted, ref } from 'vue';
import callCenterConfigurationAPI from 'dashboard/api/callCenterConfiguration';

const status = ref({
  loaded: false,
  has_call_centers: false,
  has_available_call_center: false,
  release_delay_seconds: 60,
  server_time: 0,
});

const receivedAt = ref(0);
const localTime = ref(Date.now());

let consumers = 0;
let refreshInterval = null;
let clockInterval = null;
let requestInProgress = false;

const refreshStatus = async () => {
  if (requestInProgress) return;

  requestInProgress = true;

  try {
    const response = await callCenterConfigurationAPI.status();

    status.value = {
      ...response.data,
      loaded: true,
    };

    receivedAt.value = Date.now();
    localTime.value = Date.now();
  } catch {
    // Conserva el último estado válido para no ocultar el indicador
    // ante un error temporal de red.
  } finally {
    requestInProgress = false;
  }
};

const startPolling = () => {
  if (refreshInterval) return;

  refreshStatus();

  refreshInterval = window.setInterval(refreshStatus, 5000);
  clockInterval = window.setInterval(() => {
    localTime.value = Date.now();
  }, 1000);
};

const stopPolling = () => {
  if (consumers > 0) return;

  window.clearInterval(refreshInterval);
  window.clearInterval(clockInterval);

  refreshInterval = null;
  clockInterval = null;
};

const serverNow = computed(() => {
  if (!status.value.loaded) return 0;

  return (
    Number(status.value.server_time) +
    (localTime.value - receivedAt.value) / 1000
  );
});

export const useCallCenterPriority = () => {
  onMounted(() => {
    consumers += 1;
    startPolling();
  });

  onBeforeUnmount(() => {
    consumers -= 1;
    stopPolling();
  });

  const priorityFor = conversation => {
    if (
      !status.value.loaded ||
      conversation.status !== 'open' ||
      conversation.meta?.assignee
    ) {
      return { visible: false };
    }

    const hasPriorityCallCenter =
      status.value.has_call_centers &&
      status.value.has_available_call_center;

    const delay = Number(status.value.release_delay_seconds);
    const startedAt = Number(
      conversation.updated_at || conversation.created_at
    );

    if (!delay || !startedAt) {
      return {
        visible: true,
        waiting: false,
        remainingSeconds: 0,
        progress: 1,
      };
    }

    const remainingSeconds = Math.max(
      0,
      Math.ceil(startedAt + delay - serverNow.value)
    );

    const waiting = hasPriorityCallCenter && remainingSeconds > 0;

    return {
      visible: true,
      waiting,
      remainingSeconds,
      progress: waiting ? (delay - remainingSeconds) / delay : 1,
    };
  };

  return {
    priorityFor,
  };
};
