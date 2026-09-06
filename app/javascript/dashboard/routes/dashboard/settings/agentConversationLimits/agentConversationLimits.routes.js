import { frontendURL } from '../../../../helper/URLHelper';
import SettingsWrapper from '../SettingsWrapper.vue';
import Index from './Index.vue';

const meta = {
  permissions: ['administrator'],
};

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/agent-conversation-limits'),
      component: SettingsWrapper,
      meta,
      children: [
        {
          path: '',
          name: 'agent_conversation_limits_index',
          component: Index,
          meta,
        },
      ],
    },
  ],
};
