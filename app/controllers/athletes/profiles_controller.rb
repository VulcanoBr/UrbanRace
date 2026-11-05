# app/controllers/athletes/profiles_controller.rb
module Athletes
  class ProfilesController < BaseController
    def edit
      # Inicializa o Form Object com os dados atuais do atleta (Current.user)
      @profile_form = Athletes::ProfileForm.from_model(current_user)
    end

    def update
      @profile_form = Athletes::ProfileForm.new(profile_params.merge(athlete_id: current_user.id))

      if @profile_form.save
        redirect_to athletes_area_do_corredor_path, notice: "Seu perfil foi atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # LGPD: Exportação de dados (Sprint 20)
    def export_data
      service = Athletes::PrivacyService.new(current_user)
      send_data service.export_all_data, 
                filename: "meus-dados-urbanrace-#{Date.today}.json", 
                type: "application/json"
    end

    # LGPD: Página de solicitação de exclusão/anonimização
    def privacy_request
      @privacy_form = Athletes::PrivacyRequestForm.new(athlete_id: current_user.id)
    end

    def anonymize
      @privacy_form = Athletes::PrivacyRequestForm.new(privacy_params.merge(athlete_id: current_user.id))
      
      if @privacy_form.process
        # Após anonimizar, limpamos o cookie de sessão
        cookies.delete(:session_id)
        redirect_to root_path, notice: "Seus dados foram anonimizados. Sua conta foi encerrada conforme solicitado."
      else
        render :privacy_request, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:athletes_profile_form).permit(:nome, :telefone, :password, :password_confirmation)
    end

    def privacy_params
      # Note que o nome do parâmetro segue o nome da classe do Form Object
      params.require(:athletes_privacy_request_form).permit(:password, :confirm_erasure)
    end
    
  end
end