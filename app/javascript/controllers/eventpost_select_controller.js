import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["eventSelect", "stationSelect"];

  connect() {
    this.filterStations();
  }

  filterStations() {
    const eventId = this.eventSelectTarget.value;
    const stations = this.stationSelectTarget.querySelectorAll("option");

    stations.forEach((option) => {
      // Sempre mantém o prompt ("Selecione o posto...")
      if (option.value === "") {
        option.hidden = false;
        return;
      }

      // Compara o data-event-id da opção com o ID do evento selecionado
      if (option.dataset.eventId === eventId) {
        option.hidden = false;
        option.disabled = false;
      } else {
        option.hidden = true;
        option.disabled = true;
      }
    });

    // Limpa a seleção do posto ao trocar o evento
    this.stationSelectTarget.value = "";
  }
}
