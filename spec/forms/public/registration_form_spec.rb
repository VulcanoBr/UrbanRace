
# frozen_string_literal: true

require "rails_helper"
require "tempfile"

RSpec.describe Public::RegistrationForm, type: :model do
  let(:form) { described_class.new }

  let(:limite_bytes) { 5.megabytes }

  # Assinatura básica de um arquivo PDF.
  let(:pdf_header) { "%PDF-1.4\n" }

  # Assinatura JPEG reconhecida pelo identificador de MIME.
  let(:jpeg_content) do
    "\xFF\xD8\xFF\xE0".b + ("\x00".b * 32)
  end

  # Assinatura PNG: 89 50 4E 47 0D 0A 1A 0A.
  let(:png_content) do
    "\x89PNG\r\n\x1A\n".b + ("\x00".b * 32)
  end

  def uploaded_file(filename:, content:, content_type: "application/octet-stream")
    tempfile = Tempfile.new(["upload", File.extname(filename)])
    tempfile.binmode
    tempfile.write(content)
    tempfile.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: content_type
    )
  end

  describe "validação do atestado médico" do
    context "quando nenhum arquivo é anexado" do
      it "considera o formulário válido quanto ao atestado" do
        form.atestado_file = nil

        form.valid?

        expect(form.errors[:atestado_file]).to be_empty
      end
    end

    context "quando o arquivo é válido" do
      it "aceita um PDF de até 5 MB" do
        content = pdf_header.b +
                  ("A".b * (limite_bytes - pdf_header.bytesize))

        form.atestado_file = uploaded_file(
          filename: "atestado.pdf",
          content: content,
          content_type: "application/pdf"
        )

        form.valid?

        expect(form.errors[:atestado_file]).to be_empty
      end

      it "aceita um JPG válido de até 5 MB" do
        form.atestado_file = uploaded_file(
          filename: "atestado.jpg",
          content: jpeg_content,
          content_type: "image/jpeg"
        )

        form.valid?

        expect(form.errors[:atestado_file]).to be_empty
      end

      it "aceita um PNG válido de até 5 MB" do
        form.atestado_file = uploaded_file(
          filename: "atestado.png",
          content: png_content,
          content_type: "image/png"
        )

        form.valid?

        expect(form.errors[:atestado_file]).to be_empty
      end
    end

    context "quando o arquivo é inválido" do
      it "rejeita um arquivo maior que 5 MB" do
        content = pdf_header.b +
                  ("A".b * (limite_bytes + 1 - pdf_header.bytesize))

        form.atestado_file = uploaded_file(
          filename: "atestado.pdf",
          content: content,
          content_type: "application/pdf"
        )

        form.valid?

        expect(form.errors[:atestado_file]).to include(
          "deve ter no máximo 5 MB."
        )
      end

      it "rejeita um executável renomeado para PDF" do
        form.atestado_file = uploaded_file(
          filename: "atestado.pdf",
          content: "MZ" + ("\x00".b * 64),
          content_type: "application/pdf"
        )

        form.valid?

        expect(form.errors[:atestado_file]).to be_present
      end

      it "rejeita um arquivo de texto renomeado para JPG" do
        form.atestado_file = uploaded_file(
          filename: "atestado.jpg",
          content: "Este é apenas um arquivo de texto.",
          content_type: "image/jpeg"
        )

        form.valid?

        expect(form.errors[:atestado_file]).to be_present
      end

      it "rejeita uma extensão não permitida" do
        form.atestado_file = uploaded_file(
          filename: "atestado.exe",
          content: pdf_header.b,
          content_type: "application/pdf"
        )

        form.valid?

        expect(form.errors[:atestado_file]).to be_present
      end
    end
  end
end
