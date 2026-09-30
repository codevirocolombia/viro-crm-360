import { frontendURL } from '../../../../helper/URLHelper';
import SettingsWrapper from '../SettingsWrapper.vue';
import Index from './Index.vue';

const meta = {
  permissions: ['administrator'],
};

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/call-center'),
      component: SettingsWrapper,
      meta,
      children: [
        {
          path: '',
          name: 'call_center_configuration_index',
          component: Index,
          meta,
        },
      ],
    },
  ],
};
