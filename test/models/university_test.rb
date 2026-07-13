# frozen_string_literal: true

require "test_helper"

class UniversityTest < ActiveSupport::TestCase
  test "is valid with all required fields" do
    uni = universities(:iset_sfax)
    assert uni.valid?
  end

  test "is invalid without name" do
    uni = universities(:iset_sfax)
    uni.name = nil
    assert_not uni.valid?
  end

  test "is invalid without email_domain" do
    uni = universities(:iset_sfax)
    uni.email_domain = nil
    assert_not uni.valid?
  end

  test "email_domain must be unique" do
    uni = University.new(name: "Another Uni", email_domain: universities(:iset_sfax).email_domain)
    assert_not uni.valid?
    assert_includes uni.errors[:email_domain], "has already been taken"
  end

  test "approved defaults to false" do
    uni = University.new(name: "New Uni", email_domain: "newuni.edu.tn")
    assert_not uni.approved?
  end
end
