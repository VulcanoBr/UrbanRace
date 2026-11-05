class Public::ContactsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  def new
    @contact_form = Public::ContactForm.new
  end

  def create
    @contact_form = Public::ContactForm.new(contact_params)

    if @contact_form.submit
      redirect_to root_path, notice: "Sua mensagem foi enviada com sucesso! Entraremos em contato em breve."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:public_contact_form).permit(:nome, :email, :assunto, :mensagem)
  end
end