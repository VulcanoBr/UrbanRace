class Organizer::SponsorsController < Organizer::BaseController
  
  before_action :set_sponsor, only: [:show, :edit, :update, :destroy]

  def index
    @sponsors = Sponsor.all.order(nome: :asc).page(params[:page]).per(10)
  end

  def show; end # Agora com view show

  def new
    @sponsor_form = Organizer::SponsorForm.new
  end

  def create
    @sponsor_form = Organizer::SponsorForm.new(sponsor_params)
    
    if @sponsor_form.save
      redirect_to organizer_sponsors_path, notice: "Patrocinador adicionado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @sponsor_form = Organizer::SponsorForm.from_model(@sponsor)
  end

  def update
    @sponsor_form = Organizer::SponsorForm.new(sponsor_params.merge(id: @sponsor.id,))
    if @sponsor_form.save
      redirect_to organizer_sponsor_path(@sponsor), notice: "Patrocinador atualizado!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sponsor.destroy
    redirect_to organizer_sponsors_path, notice: "Patrocinador removido.", status: :see_other
  end

  private

  def set_sponsor
    @sponsor = Sponsor.find(params[:id])
  end

  def sponsor_params
    params.require(:organizer_sponsor_form).permit(
      :nome, :cnpj, :contato, :email_contato, :phone_contato, 
      :website, :ativo, :logo
    )
  end
end