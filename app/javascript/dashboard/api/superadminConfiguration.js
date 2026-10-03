/* global axios */

import ApiClient from './ApiClient';

class SuperadminConfigurationAPI extends ApiClient {
  constructor() {
    super('superadmin_configuration', { accountScoped: true });
  }

  update(data) {
    return axios.patch(this.url, data);
  }
}

export default new SuperadminConfigurationAPI();
