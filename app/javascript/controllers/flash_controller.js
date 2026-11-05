import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Esconde a mensagem automaticamente após 5 segundos
    setTimeout(() => {
      this.close();
    }, 5000);
  }

  close() {
    this.element.classList.add("opacity-0", "translate-x-4");
    setTimeout(() => {
      this.element.remove();
    }, 300);
  }
}
