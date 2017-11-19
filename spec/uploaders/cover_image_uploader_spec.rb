describe CoverImageUploader do
  it 'allows only images' do
    uploader = CoverImageUploader.new(Achievement.new, :cover_image)

    expect do
      File.open("#{Rails.root}/spec/fixtures/test.md") do |f|
        uploader.store!(f)
      end
    end.to raise_exception(CarrierWave::IntegrityError)
  end
end