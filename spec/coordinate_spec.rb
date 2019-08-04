RSpec.describe Flatbot::Coordinate do
  it 'can convert a string of the form "46.259181, -96.037663" to a hash' do
    coordinate = Flatbot::Coordinate.from_string('46.259181, -96.037663')
    expect(coordinate).not_to be nil
    expect(coordinate[:latitude]).to eq '46.259181'
    expect(coordinate[:longitude]).to eq '-96.037663'
  end
end
