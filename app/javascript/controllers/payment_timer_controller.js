// app/javascript/controllers/payment_timer_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["display", "bar"];
  static values = { expiresAt: Number };

  connect() {
    this.total = this.expiresAtValue - Math.floor(Date.now() / 1000);
    this.tick();
    this.timer = setInterval(() => this.tick(), 1000);
  }

  disconnect() {
    clearInterval(this.timer);
  }

  tick() {
    const agora = Math.floor(Date.now() / 1000);
    const restante = Math.max(0, this.expiresAtValue - agora);
    const m = Math.floor(restante / 60);
    const s = restante % 60;
    this.displayTarget.textContent =
      String(m).padStart(2, "0") + ":" + String(s).padStart(2, "0");
    this.barTarget.style.width =
      Math.round((restante / this.total) * 100) + "%";

    if (restante < 300) {
      // menos de 5 min → vermelho
      this.displayTarget.classList.replace("text-amber-600", "text-red-600");
      this.barTarget.classList.replace("bg-amber-400", "bg-red-500");
    }
    if (restante === 0) clearInterval(this.timer);
  }
}
