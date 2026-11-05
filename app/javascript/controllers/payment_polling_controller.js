import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { id: Number };

  connect() {
    // Verifica o status do pagamento a cada 5 segundos
    this.timer = setInterval(() => {
      this.checkStatus();
    }, 5000);
  }

  async checkStatus() {
    try {
      const response = await fetch(
        `/registrations/${this.idValue}/payment/status`,
      );
      const data = await response.json();

      if (data.status === "pago") {
        clearInterval(this.timer);
        window.location.href = `/registrations/${this.idValue}/payment/success`;
      }
    } catch (error) {
      console.error("Erro ao verificar pagamento", error);
    }
  }

  disconnect() {
    clearInterval(this.timer);
  }
}
