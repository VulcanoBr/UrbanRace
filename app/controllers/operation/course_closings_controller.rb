# app/controllers/operation/course_closings_controller.rb
class Operation::CourseClosingsController < Operation::BaseController
  def update
    @waypoint = Waypoint.find(params[:id])
    @event = @waypoint.route.event
    
    @closing_form = Operation::ClosingForm.new(
      waypoint_id: @waypoint.id,
      organizer_id: Current.user.id,
      confirmacao_ultimo_atleta: params[:confirmacao_ultimo_atleta]
    )

    if @closing_form.save
      redirect_to operation_event_course_status_path(@event), notice: "Ponto #{@waypoint.nome} encerrado!"
    else
      redirect_to operation_event_course_status_path(@event), alert: "Falha ao encerrar: confirme visualmente o último atleta." 
    end
  end
end