require 'rails_helper'

RSpec.describe Post, type: :model do

  describe 'a test that requires db access' do
    let(:post) { Post.new(text: 'A new post') }

    it 'passes' do
      post.save!
      expect(Post.find(post.id).text).to eq 'A new post'
    end
  end
end
