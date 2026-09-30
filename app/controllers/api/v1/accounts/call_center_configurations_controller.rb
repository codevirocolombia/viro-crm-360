class Api::V1::Accounts::CallCenterConfigurationsController < Api::V1::Accounts::BaseController
  DEFAULT_RELEASE_DELAY_SECONDS = 60
  MIN_RELEASE_DELAY_SECONDS = 15
  MAX_RELEASE_DELAY_SECONDS = 600

  before_action :ensure_administrator!

  def show
    render json: configuration_payload
  end

  def update
    delay = Integer(params[:release_delay_seconds])

    unless delay.between?(MIN_RELEASE_DELAY_SECONDS, MAX_RELEASE_DELAY_SECONDS)
      return render_could_not_create_error(
        'El tiempo debe estar entre 15 y 600 segundos'
      )
    end

    attributes = Current.account.custom_attributes || {}

    Current.account.update!(
      custom_attributes: attributes.merge(
        'call_center_release_delay_seconds' => delay
      )
    )

    render json: configuration_payload
  rescue ArgumentError, TypeError
    render_could_not_create_error('El tiempo de espera no es válido')
  end

  private

  def ensure_administrator!
    return if Current.account_user&.administrator?

    render_unauthorized('Solo los administradores pueden gestionar Call Center')
  end

  def release_delay_seconds
    value = Current.account.custom_attributes&.fetch(
      'call_center_release_delay_seconds',
      DEFAULT_RELEASE_DELAY_SECONDS
    ).to_i

    value.positive? ? value : DEFAULT_RELEASE_DELAY_SECONDS
  end

  def configuration_payload
    {
      release_delay_seconds: release_delay_seconds,
      call_centers: CallCenter::AvailabilityService.new(
        account: Current.account
      ).payload
    }
  end
end
