FactoryGirl.define do
  # define default values
  factory :achievement do
    # return sequence num for unique title
    # use Faker(optional) 
    sequence(:title) { |n| "Achievement #{n}" }
    description "description"
    privacy Achievement.privacies[:private_access]
    featured false
    cover_image "some_file.png"

    # sub factory, inherit from parent with the exception of defined value
    factory :public_achievement do
      privacy :public_access
    end

    factory :private_achievement do
      privacy :private_access
    end
  end
end