class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_scope!, only: [:edit, :update]

  # Disable default Devise signup actions (redirect to custom role selector)
  def new
    redirect_to select_role_path
  end

  def create
    redirect_to select_role_path
  end

  # GET /signup
  def select_role
    render :select_role
  end

  # GET /signup/student
  def new_student
    @user = User.new
    @student_profile = StudentProfile.new
    render :new_student
  end

  # POST /signup/student
  def create_student
    @student_profile = StudentProfile.new(student_profile_params)
    @user = User.new(sign_up_params)

    if @user.email.present?
      domain = @user.email.split("@").last.to_s.downcase
      matched_uni = University.find_by(email_domain: domain)
      if matched_uni && matched_uni.approved?
        @student_profile.university = matched_uni
      end
    end

    ActiveRecord::Base.transaction do
      if @student_profile.save
        @user.profileable = @student_profile
        if @user.save
          sign_in(:user, @user)
          redirect_to dashboard_path, notice: "Welcome to StageUp! Your student account was successfully created."
          return
        else
          raise ActiveRecord::Rollback
        end
      end
    end

    flash.now[:alert] = "Please fix the errors below to complete your registration."
    render :new_student, status: :unprocessable_entity
  end

  # GET /signup/company
  def new_company
    @user = User.new
    @company_profile = CompanyProfile.new
    render :new_company
  end

  # POST /signup/company
  def create_company
    @company_profile = CompanyProfile.new(company_profile_params)
    @user = User.new(sign_up_params)

    ActiveRecord::Base.transaction do
      if @company_profile.save
        @user.profileable = @company_profile
        if @user.save
          sign_in(:user, @user)
          redirect_to dashboard_path, notice: "Welcome to StageUp! Your employer account was successfully created."
          return
        else
          raise ActiveRecord::Rollback
        end
      end
    end

    flash.now[:alert] = "Please fix the errors below to complete your registration."
    render :new_company, status: :unprocessable_entity
  end

  # GET /signup/university
  def new_university
    @user = User.new
    @university_profile = UniversityProfile.new
    @universities = University.all
    render :new_university
  end

  # POST /signup/university
  def create_university
    @university_profile = UniversityProfile.new(university_profile_params)
    @user = User.new(sign_up_params)
    @universities = University.all

    ActiveRecord::Base.transaction do
      if @university_profile.save
        @user.profileable = @university_profile
        if @user.save
          sign_in(:user, @user)
          redirect_to dashboard_path, notice: "Welcome to StageUp! Your university coordinator account was successfully created."
          return
        else
          raise ActiveRecord::Rollback
        end
      end
    end

    flash.now[:alert] = "Please fix the errors below to complete your registration."
    render :new_university, status: :unprocessable_entity
  end

  # GET /users/edit
  def edit
    @profile = current_user.profileable
    @skills = Skill.all if current_user.profileable_type == "StudentProfile"
    render :edit
  end

  # PUT /users
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    @profile = resource.profileable
    @skills = Skill.all if resource.profileable_type == "StudentProfile"

    profile_updated = update_profile_attributes

    password_changing = params[:user][:password].present?
    email_changing = params[:user][:email].present? && params[:user][:email].strip.downcase != resource.email.downcase

    user_updated = true
    if password_changing || email_changing
      user_updated = update_resource(resource, account_update_params)
    end

    if profile_updated && user_updated
      bypass_sign_in(resource) if password_changing
      redirect_to dashboard_path, notice: "Your profile and security settings were successfully updated."
    else
      flash.now[:alert] = "Please fix the errors below to update your settings."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def update_profile_attributes
    return true unless @profile

    case resource.profileable_type
    when "StudentProfile"
      sp_params = params.require(:student_profile).permit(:first_name, :last_name, :phone, :major, :graduation_year, :bio)
      if params[:student_profile][:cv].present?
        @profile.cv.attach(params[:student_profile][:cv])
      end
      if params[:student_profile][:skill_ids].present?
        @profile.skill_ids = params[:student_profile][:skill_ids].reject(&:blank?)
      end
      @profile.update(sp_params)
    when "CompanyProfile"
      cp_params = params.require(:company_profile).permit(:name, :website, :description)
      @profile.update(cp_params)
    when "UniversityProfile"
      up_params = params.require(:university_profile).permit(:admin_name, :department)
      @profile.update(up_params)
    else
      true
    end
  end

  def student_profile_params
    params.require(:student_profile).permit(:first_name, :last_name, :phone, :major, :graduation_year, :bio)
  end

  def company_profile_params
    params.require(:company_profile).permit(:name, :website, :description)
  end

  def university_profile_params
    params.require(:university_profile).permit(:university_id, :admin_name, :department)
  end
end
