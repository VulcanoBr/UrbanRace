class Organizer::SponsorContractsController < Organizer::BaseController
  before_action :set_contract, only: %i[ show edit update destroy ]

  def index
    @contracts = SponsorContract.includes(:sponsor, :event).order(created_at: :desc).page(params[:page]).per(10)
    @total_gastos = @contracts.sum(:valor_cota)
  end

  def new
    @contract_form = Organizer::SponsorContractForm.new
  end

  def create
    @contract_form = Organizer::SponsorContractForm.new(contract_params)
    if @contract_form.save
      redirect_to organizer_sponsor_contracts_path, notice: "Lançamento financeiro registrado!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @contract_form = Organizer::SponsorContractForm.from_model(@contract)
  end

  def update
    @contract_form = Organizer::SponsorContractForm.new(contract_params.merge(id: @contract.id))
    if @contract_form.save
      redirect_to organizer_sponsor_contracts_path, notice: "Contrato atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contract.destroy
    redirect_to organizer_sponsor_contracts_path, notice: "Lançamento excluído.", status: :see_other
  end

  private

  def set_contract
    @contract = SponsorContract.find(params[:id])
  end

  def contract_params
    params.require(:organizer_sponsor_contract_form).permit(:sponsor_id, :event_id, :cota, :valor_cota, :status, :assinado_em, :arquivo_pdf)
  end
end