class Athletes::PhotosController < Athletes::BaseController
  def index
    # Busca todas as fotos onde o ID do atleta foi identificado pela IA
    @photo_registrations = PhotoRegistration
                             .where(registration_id: Current.user.registrations.select(:id))
                             .includes(photo: :event)
                             .order(created_at: :desc)
  end
end