/* global axios */

import ApiClient from './ApiClient';

class SuperadminConfigurationAPI extends ApiClient {
  constructor() {
    super('superadmin_configuration', { accountScoped: true });
  }

  update(data) {
    return axios.patch(this.url, data);
  }

  reset() {
    return axios.post(`${this.url}/reset`);
  }
}

export default new SuperadminConfigurationAPI();
