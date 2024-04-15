# spec/controllers/code_generator_controller_spec.rb

require 'rails_helper'

RSpec.describe CodeGeneratorController, type: :controller do
  describe "POST #generate" do
    context "with valid description" do
      let(:valid_description) { "Test description" }

      it "returns a success response" do
        post :generate, params: { description: valid_description }
        expect(response).to have_http_status(:success)
      end

      it "assigns @generated_code" do
        post :generate, params: { description: valid_description }
        expect(assigns(:generated_code)).not_to be_nil
      end
    end

    context "with invalid description" do
      let(:invalid_description) { nil }

      it "returns a bad request response" do
        post :generate, params: { description: invalid_description }
        expect(response).to have_http_status(:bad_request)
      end

      it "returns an error message" do
        post :generate, params: { description: invalid_description }
        expect(JSON.parse(response.body)["error"]).to eq("An unexpected error occurred while generating the code.")
      end
    end
  end

  describe "#generate_code" do
    let(:description) { "Test description" }

    it "returns generated code" do
      allow_any_instance_of(CodeGeneratorController).to receive(:openai_request).and_return(double(success?: true, parsed_response: { "choices" => [{ "text" => "Generated code" }] }))
      expect(subject.send(:generate_code, description)).to eq("Generated code")
    end

    it "logs error for unsuccessful response" do
      allow_any_instance_of(CodeGeneratorController).to receive(:openai_request).and_return(double(success?: false, parsed_response: { "error" => { "message" => "API error" } }))
      expect(Rails.logger).to receive(:error).with("OpenAI API error: API error")
      subject.send(:generate_code, description)
    end

    it "logs error for rescue block" do
      allow_any_instance_of(CodeGeneratorController).to receive(:openai_request).and_raise(StandardError, "Internal error")
      expect(Rails.logger).to receive(:error).with("Error generating code: Internal error")
      subject.send(:generate_code, description)
    end
  end
end
