class Organizer::SuppliersController < Organizer::BaseController
  before_action :set_supplier, only: %i[ show edit update destroy ]

  def index
    @nome_fornecedor = params[:nome_fornecedor].to_s.strip
    @tipo_servico = params[:tipo_servico].to_s.strip

    @suppliers = Supplier.all

    if @nome_fornecedor.present?
      @suppliers = @suppliers.where(
        "razao_social ILIKE ?",
        "%#{ActiveRecord::Base.sanitize_sql_like(@nome_fornecedor)}%"
      )
    end

    if @tipo_servico.present?
      @suppliers = @suppliers.where(tipo_servico: @tipo_servico)
    end

    @tipos_servico = Supplier
      .where.not(tipo_servico: [nil, ""])
      .distinct
      .order(:tipo_servico)
      .pluck(:tipo_servico)

    @suppliers = @suppliers
      .order(razao_social: :asc)
      .page(params[:page])
      .per(10)
  end

  def show; end # Agora com view show

  def new
    @supplier_form = Organizer::SupplierForm.new
  end

  def create
    @supplier_form = Organizer::SupplierForm.new(supplier_params)
    if @supplier_form.save
      redirect_to organizer_suppliers_path, notice: "Fornecedor cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @supplier_form = Organizer::SupplierForm.from_model(@supplier)
  end

  def update
    @supplier_form = Organizer::SupplierForm.new(supplier_params.merge(id: @supplier.id))
    if @supplier_form.save
      redirect_to organizer_supplier_path(@supplier), notice: "Fornecedor atualizado!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @supplier.supplier_contracts.any?
      redirect_to organizer_suppliers_path, alert: "Este fornecedor possui contratos ativos."
    else
      @supplier.destroy
      redirect_to organizer_suppliers_path, notice: "Fornecedor removido.", status: :see_other
    end
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    # Atributos atualizados aqui
    params.require(:organizer_supplier_form).permit(
      :razao_social, :cnpj, :contato, :email_contato, 
      :phone_contato, :tipo_servico, :avaliacao_media
    )
  end
end