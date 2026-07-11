class Users::RegistrationsController < Devise::RegistrationsController
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

    # University Domain Auto-Verification
    if @user.email.present?
      domain = @user.email.split('@').last.to_s.downcase
      matched_uni = University.find_by(email_domain: domain)
      @student_profile.university = matched_uni if matched_uni
    end

    ActiveRecord::Base.transaction do
      if @student_profile.save
        @user.profileable = @student_profile
        if @user.save
          sign_in(:user, @user)
          redirect_to dashboard_path, notice: "Welcome to StageUp! Your student account was successfully created."
          return
        else
          # Force rollback if user fails to save
          raise ActiveRecord::Rollback
        end
      end
    end

    # If we reach here, validation failed. Merge errors to display them in the view.
    flash.now[:alert] = "Please fix the errors below to complete your registration."
    render :new_student
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
    render :new_company
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
    render :new_university
  end

  private

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
