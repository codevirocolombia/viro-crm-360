class Api::V1::Accounts::SuperadminConfigurationsController < Api::V1::Accounts::BaseController
  before_action :ensure_superadmin!

  CONFIG_KEYS = {
    installation_name: 'INSTALLATION_NAME',
    logo: 'LOGO',
    logo_dark: 'LOGO_DARK',
    logo_thumbnail: 'LOGO_THUMBNAIL'
  }.freeze

  IMAGE_PARAMS = %i[logo logo_dark logo_thumbnail].freeze

  def show
    render json: current_config_payload
  end

  def update
    update_installation_name
    update_images

    render json: current_config_payload
  end

  private

  def ensure_superadmin!
    return if Current.user.is_a?(SuperAdmin)

    render_unauthorized('Solo el superadmin puede modificar esta configuración')
  end

  def update_installation_name
    return unless params.key?(:installation_name)

    name = params[:installation_name].to_s.strip

    if name.blank?
      render_could_not_create_error('El nombre del CRM no puede estar vacío')
      return
    end

    update_config('INSTALLATION_NAME', name)
  end

  def update_images
    IMAGE_PARAMS.each do |param_name|
      file = params[param_name]
      next if file.blank?

      blob = ActiveStorage::Blob.create_and_upload!(
        io: file.tempfile,
        filename: file.original_filename,
        content_type: file.content_type
      )

      update_config(CONFIG_KEYS[param_name], rails_blob_path(blob, only_path: true))
    end
  end

  def update_config(name, value)
    config = InstallationConfig.find_or_initialize_by(name: name)
    config.locked = false if config.new_record?
    config.value = value
    config.save!
  end

  def current_config_payload
    config = GlobalConfig.get(*CONFIG_KEYS.values)

    {
      installation_name: config['INSTALLATION_NAME'],
      logo: config['LOGO'],
      logo_dark: config['LOGO_DARK'],
      logo_thumbnail: config['LOGO_THUMBNAIL']
    }
  end
end
