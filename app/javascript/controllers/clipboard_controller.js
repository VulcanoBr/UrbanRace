// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["source", "button"];

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value).catch(() => {
      this.sourceTarget.select();
      document.execCommand("copy"); // fallback para HTTP
    });
    this.buttonTarget.textContent = "Copiado!";
    this.buttonTarget.classList.replace("bg-blue-600", "bg-green-600");
    setTimeout(() => {
      this.buttonTarget.textContent = "Copiar";
      this.buttonTarget.classList.replace("bg-green-600", "bg-blue-600");
    }, 2000);
  }
}
