import { Controller } from "@hotwired/stimulus";
import { Html5Qrcode } from "html5-qrcode";

export default class extends Controller {
  static targets = ["container", "video"];
  static values = { eventId: String };

  connect() {
    // Inicializa a instância do Scanner apontando para um ID interno
    this.html5QrCode = new Html5Qrcode("qr-reader");
    this.isScanning = false;
  }

  async start() {
    if (this.isScanning) return;

    this.containerTarget.classList.remove("hidden");
    const config = { fps: 10, qrbox: { width: 250, height: 250 } };

    try {
      await this.html5QrCode.start(
        { facingMode: "environment" }, // Usa a câmera traseira
        config,
        (decodedText) => this.onScanSuccess(decodedText),
      );
      this.isScanning = true;
    } catch (err) {
      alert("Erro ao acessar câmera: " + err);
      this.containerTarget.classList.add("hidden");
    }
  }

  onScanSuccess(decodedText) {
    // Feedback Sonoro (Opcional, mas excelente para UX de staff)
    this.playBeep();

    // Para o scanner para processar a requisição
    this.stop();

    // Envia o hash para o Rails
    this.processCheckin(decodedText);
  }

  processCheckin(hash) {
    const token = document.querySelector('meta[name="csrf-token"]').content;

    fetch(`/operation/events/${this.eventIdValue}/checkins`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
      },
      body: JSON.stringify({ qr_code_hash: hash }),
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          alert(
            alert(
              `CONFIRMADO: ${data.athlete}\nDorsal: #${data.dorsal}\nKit: ${data.kit}`,
            ),
          );
          window.location.reload(); // Atualiza estatísticas e lista
        } else {
          alert("ERRO: " + data.message);
          this.start(); // Reinicia o scanner em caso de erro
        }
      })
      .catch((error) => {
        console.error("Erro:", error);
        alert("Falha na conexão com o servidor.");
        this.start();
      });
  }

  stop() {
    if (this.html5QrCode && this.isScanning) {
      this.html5QrCode.stop().then(() => {
        this.isScanning = false;
        this.containerTarget.classList.add("hidden");
      });
    }
  }

  playBeep() {
    const context = new (window.AudioContext || window.webkitAudioContext)();
    const osc = context.createOscillator();
    osc.type = "sine";
    osc.frequency.setValueAtTime(880, context.currentTime);
    osc.connect(context.destination);
    osc.start();
    osc.stop(context.currentTime + 0.1);
  }

  disconnect() {
    this.stop();
  }
}
