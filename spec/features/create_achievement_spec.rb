feature 'create new achievement' do
  scenario 'create new achievement with valid data' do
    visit('/')
    click_on('New Acheivement')
    fill_in('title', with: 'Read a book')
    fill_in('Description', with: 'Excellent read')    
    select('Public', from: )    
    click_on()
  end
end