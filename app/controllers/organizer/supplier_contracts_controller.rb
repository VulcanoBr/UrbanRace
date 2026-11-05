class Organizer::SupplierContractsController < Organizer::BaseController
  before_action :set_contract, only: %i[ show edit update destroy ]

  def index
    @nome_fornecedor = params[:nome_fornecedor].to_s.strip
    @tipo_servico = params[:tipo_servico].to_s.strip

    @contracts = SupplierContract
      .joins(:supplier)
      .includes(:supplier, :event)
      .order(created_at: :desc)

    if @nome_fornecedor.present?
      @contracts = @contracts.where(
        "suppliers.razao_social ILIKE ?",
        "%#{ActiveRecord::Base.sanitize_sql_like(@nome_fornecedor)}%"
      )
    end

    if @tipo_servico.present?
      @contracts = @contracts.where(
        "suppliers.tipo_servico ILIKE ?",
        "%#{ActiveRecord::Base.sanitize_sql_like(@tipo_servico)}%"
      )
    end

    # O total considera todos os contratos encontrados pelos filtros,
    # antes da paginação.
    @total_gastos = @contracts.sum(:valor)

    @tipos_servico = Supplier
      .where.not(tipo_servico: [nil, ""])
      .distinct
      .order(:tipo_servico)
      .pluck(:tipo_servico)

    @contracts = @contracts.page(params[:page]).per(10)
  end


  def new
    @supplier_contract_form = Organizer::SupplierContractForm.new
  end

  def create
    @supplier_contract_form = Organizer::SupplierContractForm.new(contract_params)
    if @supplier_contract_form.save
      redirect_to organizer_supplier_contracts_path, notice: "Lançamento financeiro registrado!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @supplier_contract_form = Organizer::SupplierContractForm.from_model(@contract)
  end

  def update
    @supplier_contract_form = Organizer::SupplierContractForm.new(contract_params.merge(id: @contract.id))
    if @supplier_contract_form.save
      redirect_to organizer_supplier_contracts_path, notice: "Contrato atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contract.destroy
    redirect_to organizer_supplier_contracts_path, notice: "Lançamento excluído.", status: :see_other
  end

  private

  def set_contract
    @contract = SupplierContract.find(params[:id])
  end

  def contract_params
    params.require(:organizer_supplier_contract_form).permit(:supplier_id, :event_id, :valor, :status, :assinado_em, :arquivo_pdf)
  end
end