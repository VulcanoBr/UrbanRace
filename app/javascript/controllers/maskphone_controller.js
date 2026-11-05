import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["inputPhone"];

  connect() {
    console.log("Mask Phone Controller Connected");
  }

  addMaskToPhoneFields(event) {
    // CAPTURA O INPUT QUE DISPAROU O EVENTO (pode ser o telefone ou o fone_emergencia)
    const input = event.target;
    let value = input.value.replace(/\D/g, "");
    let mask;

    if (value.length <= 10) {
      mask = value
        .replace(/(\d{2})(\d)/, "($1) $2")
        .replace(/(\d{4})(\d)/, "$1-$2");
    } else {
      mask = value
        .replace(/(\d{2})(\d)/, "($1) $2")
        .replace(/(\d{5})(\d)/, "$1-$2");
    }

    // Aplica a máscara apenas ao input que disparou o evento
    input.value = mask.slice(0, 15);
  }
}
