require "test_helper"

class CodeGeneratorControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
class CodeGeneratorControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    get code_generator_index_url
    assert_response :success
  end

  test "should get new" do
    get new_code_generator_url
    assert_response :success
  end

  test "should create code generator" do
    assert_difference('CodeGenerator.count') do
      post code_generators_url, params: { code_generator: {  } }
    end

    assert_redirected_to code_generator_url(CodeGenerator.last)
  end

  test "should show code generator" do
    get code_generator_url(@code_generator)
    assert_response :success
  end

  test "should get edit" do
    get edit_code_generator_url(@code_generator)
    assert_response :success
  end

  test "should update code generator" do
    patch code_generator_url(@code_generator), params: { code_generator: {  } }
    assert_redirected_to code_generator_url(@code_generator)
  end

  test "should destroy code generator" do
    assert_difference('CodeGenerator.count', -1) do
      delete code_generator_url(@code_generator)
    end

    assert_redirected_to code_generators_url
  end

end
