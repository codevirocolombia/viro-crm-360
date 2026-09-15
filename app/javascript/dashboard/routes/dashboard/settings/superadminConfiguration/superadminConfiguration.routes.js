import { frontendURL } from '../../../../helper/URLHelper';
import SettingsWrapper from '../SettingsWrapper.vue';
import Index from './Index.vue';
import store from '../../../../store';

const meta = {
  permissions: ['administrator'],
};

const ensureSuperadmin = (to, _from, next) => {
  if (store.getters.getCurrentUser?.type === 'SuperAdmin') {
    next();
    return;
  }

  next({ name: 'settings_home', params: to.params });
};

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/superadmin-configuration'),
      component: SettingsWrapper,
      meta,
      beforeEnter: ensureSuperadmin,
      children: [
        {
          path: '',
          name: 'superadmin_configuration_index',
          component: Index,
          meta,
        },
      ],
    },
  ],
};
