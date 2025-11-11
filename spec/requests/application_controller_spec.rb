# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end

    def admin_only
      require_admin!
      render plain: 'admin only'
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'admin_only' => 'anonymous#admin_only'
    end
  end

  describe 'require_admin!' do
    context 'when user is admin' do
      let(:admin) { create(:admin, :admin_role) }

      before do
        sign_in admin, scope: :admin
      end

      it 'allows access' do
        get :admin_only
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is not admin' do
      let(:member) { create(:admin, role: 'member') }

      before do
        sign_in member, scope: :admin
      end

      it 'redirects with alert' do
        get :admin_only
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include('must be an admin')
      end
    end
  end

  describe 'helper methods' do
    let(:admin) { create(:admin, :admin_role) }
    let(:member) { create(:admin, role: 'member') }
    let(:calendar) { create(:calendar) }

    before do
      sign_in admin, scope: :admin
    end

    it 'admin_user? returns true for admin' do
      expect(controller.admin_user?).to be true
    end

    it 'member_user? returns false for admin' do
      expect(controller.member_user?).to be false
    end

    it 'user_signed_in? returns true when signed in' do
      expect(controller.user_signed_in?).to be true
    end

    it 'current_user returns current admin' do
      expect(controller.current_user).to eq(admin)
    end

    it 'signed_up_for? returns true when signed up' do
      create(:signup, admin: admin, calendar: calendar)
      expect(controller.signed_up_for?(calendar)).to be true
    end

    it 'signed_up_for? returns false when not signed up' do
      expect(controller.signed_up_for?(calendar)).to be false
    end
  end
end

