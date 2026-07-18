# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with all required attributes" do
    user = users(:mohamed_user)
    assert user.valid?
  end

  test "is invalid without an email" do
    user = users(:mohamed_user)
    user.email = nil
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "is invalid with a duplicate email" do
    user = users(:mohamed_user).dup
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "is invalid with password shorter than 12 characters" do
    user = User.new(email: "new@test.com", password: "short", password_confirmation: "short")
    user.profileable = student_profiles(:mohamed)
    assert_not user.valid?
  end

  test "is invalid with an arbitrary profileable_type" do
    user = users(:mohamed_user)
    user.profileable_type = "Offer"
    assert_not user.valid?
    assert_includes user.errors[:profileable_type], "is not a valid profile type"
  end

  test "is valid with StudentProfile type" do
    user = users(:mohamed_user)
    assert_equal "StudentProfile", user.profileable_type
    assert user.valid?
  end

  test "admin attribute is read-only" do
    user = users(:mohamed_user)
    assert_not user.admin?
    assert_raises(ActiveRecord::ReadonlyAttributeError) do
      user.update(admin: true)
    end
  end

  test "student with unapproved university domain is blocked" do
    uni = universities(:unapproved)
    user = User.new(
      email: "student@#{uni.email_domain}",
      password: "securepassword123",
      password_confirmation: "securepassword123",
      profileable: student_profiles(:mohamed)
    )
    assert_not user.valid?
    assert_includes user.errors[:email].join, "not yet approved"
  end

  test "student can update email within approved domain" do
    user = users(:mohamed_user)
    user.email = "new_address@#{universities(:iset_sfax).email_domain}"
    assert user.valid?
  end

  test "cannot create a user with admin true by default" do
    user = User.new(
      email: "new_admin@test.com",
      password: "securepassword123",
      password_confirmation: "securepassword123",
      profileable: student_profiles(:mohamed),
      admin: true
    )
    assert_not user.valid?
    assert_includes user.errors[:admin], "cannot be set to true on registration"
  end

  test "can create a user with admin true if explicitly allowed" do
    user = User.new(
      email: "new_admin@test.com",
      password: "securepassword123",
      password_confirmation: "securepassword123",
      profileable: student_profiles(:mohamed),
      admin: true
    )
    user.allow_admin_creation = true
    assert user.valid?
  end
end
