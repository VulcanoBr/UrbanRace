# app/controllers/organizer/checklists_controller.rb
# app/controllers/organizer/checklists_controller.rb
class Organizer::ChecklistsController < Organizer::BaseController
  def show
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
    
    # Entregas de Fornecedores
    @entregas = SupplierDelivery.joins(:supplier_contract)
                                .where(supplier_contracts: { event_id: @event.id })
                                .includes(supplier_contract: :supplier)
                                .order(data_prevista: :asc)
                                
    # Licenças Governamentais
    @licencas = @event.licenses.order(prazo_aprovacao: :asc)
  end
end