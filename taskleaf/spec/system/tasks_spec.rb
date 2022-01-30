require 'rails_helper'

describe 'タスク管理機能', type: :system do
  describe '一覧機能' do
    # #ユーザーAを作成
    let(:user_a) { FactoryBot.create(:user,name: 'ユーザーA', email: 'a@example.com')}

    # #ユーザーBを作成
    let(:user_b) {FactoryBot.create(:user,name: 'ユーザーB', email: 'b@example.com')}

    before do
      # # 作成者がユーザーAであるタスクを作成
      FactoryBot.create(:task, name:'最初のタスク', user: user_a)

      visit login_path
      fill_in 'メールアドレス' , with: login_user.email
      fill_in 'パスワード' , with: login_user.password
      click_button 'ログインする'
    end

    context 'ユーザーAがログインしているとき'do
      let(:login_user) { user_a }

      it 'ユーザーAが作成したタスクが表示される' , js: true do
        #作成済みのタスクの名称が画面に表示されることを確認
        expect(page).to have_content '最初のタスク'
      end
    end

    context 'ユーザーBがログインしているとき' do
      let(:login_user) { user_b }


      it 'ユーザーAが作成したタスクが表示されない' , js: true do
        expect(page).to have_no_content '最初のタスク'
      end
    end
  end
end