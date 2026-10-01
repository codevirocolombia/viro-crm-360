/* global axios */

import ApiClient from './ApiClient';

class CallCenterConfigurationAPI extends ApiClient {
  constructor() {
    super('call_center_configuration', { accountScoped: true });
  }

  status() {
  return axios.get(`${this.url}/status`);
}

  update(data) {
    return axios.patch(this.url, data);
  }
}

export default new CallCenterConfigurationAPI();
