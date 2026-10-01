class Api::V1::Accounts::CallCenterConfigurationsController < Api::V1::Accounts::BaseController
  DEFAULT_RELEASE_DELAY_SECONDS = 60
  MIN_RELEASE_DELAY_SECONDS = 15
  MAX_RELEASE_DELAY_SECONDS = 600

  before_action :ensure_administrator!, only: %i[show update]
  before_action :ensure_staff_user!, only: :status

  def show
    render json: configuration_payload
  end

  def status
  availability = CallCenter::AvailabilityService.new(
    account: Current.account
  )

  render json: {
    has_call_centers: availability.any_call_center?,
    has_available_call_center: availability.any_available_call_center?,
    release_delay_seconds: release_delay_seconds,
    server_time: Time.current.to_i
  }
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

  def ensure_staff_user!
  account_user = Current.account_user

  return if account_user&.administrator? ||
            account_user&.agent? ||
            account_user&.supervisor? ||
            account_user&.call_center?

  render_unauthorized('No tienes acceso al estado de Call Center')
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
