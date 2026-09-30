/* global axios */

import ApiClient from './ApiClient';

class CallCenterConfigurationAPI extends ApiClient {
  constructor() {
    super('call_center_configuration', { accountScoped: true });
  }

  update(data) {
    return axios.patch(this.url, data);
  }
}

export default new CallCenterConfigurationAPI();
