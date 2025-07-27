require 'rails_helper'

RSpec.describe User, type: :model do
  # username がある場合は有効であること
  it 'is valid with a username' do
    user = build(:user)
    expect(user).to be_valid
  end

  # username がない場合は無効であること
  it 'is invalid without a username' do
    user = build(:user, username: nil) # name を username に変更
    expect(user).to_not be_valid
    expect(user.errors[:username]).to include("can't be blank") # バリデーションエラーメッセージを確認
  end

  # 重複したメールアドレスは無効であること
  it 'is invalid with a duplicate email address' do
    create(:user, email: 'test@example.com')
    user_with_duplicate_email = build(:user, email: 'test@example.com')
    expect(user_with_duplicate_email).to_not be_valid
    expect(user_with_duplicate_email.errors[:email]).to include("has already been taken")
  end

  # 重複したusernameは無効であること (AddUsernameToUsers マイグレーションによる)
  it 'is invalid with a duplicate username' do
    create(:user, username: 'testuser')
    user_with_duplicate_username = build(:user, username: 'testuser')
    expect(user_with_duplicate_username).to_not be_valid
    expect(user_with_duplicate_username.errors[:username]).to include("has already been taken")
  end

  # admin trait のテストは削除 (admin カラムがないため)
  # it 'creates an admin user when :admin trait is used' do
  #   admin_user = create(:user, :admin)
  #   expect(admin_user.admin).to be true
  # end

  # 無効なユーザーファクトリで作成したユーザーは無効であること
  it 'is invalid with an invalid user factory' do
    invalid_user_instance = build(:invalid_user)
    expect(invalid_user_instance).to_not be_valid
    expect(invalid_user_instance.errors[:username]).to include("can't be blank") # name を username に変更
  end
end