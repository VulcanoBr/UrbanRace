import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["inputCpfCnpj"];

  connect() {
    console.log("Mask Cpf/Cnpj");
  }

  addMaskToCpfCnpjFields(event) {
    const input = event.target;
    const originalCursorPosition = input.selectionStart;
    const originalValue = input.value;

    // Contar quantos dígitos numéricos existem ANTES da posição do cursor
    const digitsBeforeCursor = (
      originalValue.substring(0, originalCursorPosition).match(/\d/g) || []
    ).length;

    // Formata o valor
    const formattedValue = this.formatCpfCnpj(originalValue);

    // Atualiza o valor do input
    input.value = formattedValue;

    // Calcula a nova posição do cursor
    let newCursorPosition = 0;
    let digitsCounted = 0;
    for (
      let i = 0;
      i < formattedValue.length && digitsCounted < digitsBeforeCursor;
      i++
    ) {
      if (formattedValue[i].match(/\d/)) {
        digitsCounted++;
      }
      newCursorPosition++;
    }

    // Ajuste para o caso de backspace em um caractere de máscara
    // Se o caractere na nova posição do cursor não for um dígito (ex: '.', '-'),
    // e o usuário estiver apagando (formattedValue.length < originalValue.length),
    // movemos o cursor um passo para trás.
    if (
      formattedValue.length < originalValue.length &&
      !formattedValue[newCursorPosition - 1]?.match(/\d/)
    ) {
      newCursorPosition--;
    }

    // Define a nova posição do cursor
    input.setSelectionRange(newCursorPosition, newCursorPosition);
  }

  formatCpfCnpj(value) {
    const digitsOnly = value.replace(/\D/g, "").substring(0, 14);

    if (digitsOnly.length > 11) {
      // CNPJ: 99.999.999/9999-99
      return digitsOnly
        .replace(/(\d{2})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d)/, "$1/$2")
        .replace(/(\d{4})(\d{1,2})/, "$1-$2");
    } else {
      // CPF: 999.999.999-99
      return digitsOnly
        .replace(/(\d{3})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d)/, "$1.$2")
        .replace(/(\d{3})(\d{1,2})/, "$1-$2");
    }
  }
}
