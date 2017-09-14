require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#show action" do
    it "should successfully show the page if a correct id is found" do
      gram = FactoryGirl.create(:gram)
      get :show, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should render 404 if the id is not found" do
      get :show, params: { id: 'POTATO' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#new action" do
    it "should require user to be signed in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show new form" do
      user = FactoryGirl.create(:user)
      sign_in user
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "should require user to be signed in" do
      post :create, params: { gram: { message: 'Hello!'} }
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully add a new gram to the database" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, params: { gram: { message: 'Hello!' } }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly deal with validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, params: {gram: {message: '' }}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq 0
    end
  end

  describe "grams#edit action" do
    it "should successfully show the edit form if the gram is found" do
      gram = FactoryGirl.create(:gram)
      get :edit, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error message if the gram is not found" do
      get :edit, params: { id: 'potato' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do
    it "should allow users to successfully update grams" do
      gram = FactoryGirl.create(:gram, message: "Initial value")
      patch :update, params: { id: gram.id, gram: { message: "Changed value" }}
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq "Changed value"
    end

    it "should have http 404 error if the gram cannot be found" do
      patch :update, params: { id: 'potato', gram: { message: "Changed value" }}
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status of unprocessable_entity if update is not valid" do
      gram = FactoryGirl.create(:gram, message: "Initial Value")
      patch :update, params: { id: gram.id, gram: { message: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq "Initial Value"
    end
  end
end
