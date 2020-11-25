Rails.application.routes.draw do

  scope '/api' do
  	namespace :patients do
      post 'signup' => 'registrations#create'
      post 'signin' => 'sessions#create'

    end

    namespace :doctors do
      post 'signup' => 'registrations#create'
      post 'signin' => 'sessions#create'

    end

    # Patient
    get 'patient/:id/info' => 'patients#get_patient_info'
    get 'patient/:id/doctors' => 'patients#get_doctors'
    post 'patient/:id/association' => 'patients#assign_patient_to_doctor'

    post 'patient/:id/new_vital_signal' => 'vital_signals#create'

    # Doctor
    get 'doctor/:id/patients' => 'doctors#get_patients'
    
  end
end
