RSpec.describe PhotoRegistration, type: :model do
  describe "unicidade" do
    it "não permite repetir associação" do
      photo = create(:photo)

      registration = create(:registration)

      create(
        :photo_registration,
        photo: photo,
        registration: registration
      )

      duplicate =
        build(
          :photo_registration,
          photo: photo,
          registration: registration
        )

      expect(duplicate)
        .not_to be_valid
    end
  end

  describe "confianca_ocr" do
    it "aceita valor entre 0 e 100" do
      record =
        build(
          :photo_registration,
          confianca_ocr: 101
        )

      expect(record)
        .not_to be_valid
    end
  end
end