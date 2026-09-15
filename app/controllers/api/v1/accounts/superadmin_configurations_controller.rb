class Api::V1::Accounts::SuperadminConfigurationsController < Api::V1::Accounts::BaseController
  before_action :ensure_superadmin!

  CONFIG_KEYS = {
    installation_name: 'INSTALLATION_NAME',
    logo: 'LOGO',
    logo_dark: 'LOGO_DARK',
    logo_thumbnail: 'LOGO_THUMBNAIL'
  }.freeze

  IMAGE_PARAMS = %i[logo logo_dark logo_thumbnail].freeze
  ALLOWED_IMAGE_CONTENT_TYPES = %w[
    image/png
    image/jpeg
    image/svg+xml
    image/webp
    image/x-icon
    image/vnd.microsoft.icon
  ].freeze

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
    return render_could_not_create_error('El nombre del CRM no puede estar vacío') if name.blank?

    update_config('INSTALLATION_NAME', name)
  end

  def update_images
    IMAGE_PARAMS.each do |param_name|
      file = params[param_name]
      next if file.blank?

      unless ALLOWED_IMAGE_CONTENT_TYPES.include?(file.content_type)
        return render_could_not_create_error('Solo se permiten imágenes PNG, JPG, SVG, WEBP o ICO')
      end

      encoded_file = Base64.strict_encode64(file.read)
      update_config(CONFIG_KEYS[param_name], "data:#{file.content_type};base64,#{encoded_file}")
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
