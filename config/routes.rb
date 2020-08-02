Rails.application.routes.draw do

  scope '/api' do
  	namespace :patients do
      post 'signup' => 'registrations#create'
      post 'signin' => 'sessions#create'

    end

    # Patient
    get 'patient/:id/info' => 'patients#get_patient_info'
    post 'patient/:id/new_vital_signal' => 'vital_signals#create'
  end
end
