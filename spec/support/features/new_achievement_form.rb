class NewAchievementForm
  # include to use capybara helper
  include Capybara::DSL

  def visit_page
    visit('/')
    click_on('New Achievement')

    self # returns self to be able to chain method
  end

  def fill_in_with(params={title: "Read a book", cover_image: "placeholder.jpg"})
    fill_in('Title', with: params[:title])
    fill_in('Description', with: 'Excellent read')    
    select('Public', from: 'Privacy')    
    check('Featured achievement')
    attach_file('Cover image', Rails.root + "spec/fixtures/#{params[:cover_image]}")
    self
  end

  def submit
    click_on('Create Achievement')
  end
end