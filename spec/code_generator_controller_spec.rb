# spec/controllers/code_generator_controller_spec.rb

require 'rails_helper'

RSpec.describe CodeGeneratorController, type: :controller do
  # OpenAI API Request
  # This block of code is a test suite written using RSpec for the `CodeGeneratorController` in a Ruby
  # on Rails application. Let's break down what each part of the test suite is doing:
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

  # The code snippet you provided is a test suite written using RSpec for the `#openai_request` method
  # in the `CodeGeneratorController`. This test suite is responsible for testing the behavior of the
  # `#openai_request` method under different scenarios.
  describe '#openai_request' do
    let(:description) { 'Generate a Ruby class' }

    context 'when API request is successful' do
      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: true)) 
      end

      it 'makes a POST request to OpenAI API' do
        expect(HTTParty).to receive(:post)
        subject.openai_request(description)
      end

      it 'uses the correct headers' do
        expect(HTTParty).to receive(:post)
          .with(anything, hash_including({
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}"
          }))
        subject.openai_request(description)
      end

      it 'uses the correct request body' do
        expect(HTTParty).to receive(:post)
          .with(anything, hash_including({
            model: 'gpt-3.5-turbo',
            prompt: "Generate code for: #{description}",
            max_tokens: 100
          }))
        subject.openai_request(description)
      end
    end

    context 'when API request fails' do
      before do
        allow(HTTParty).to receive(:post).and_raise(StandardError)
      end

      it 'rescues from error' do
        expect { subject.openai_request(description) }.not_to raise_error
      end
    end
  end

  # Written with github copilot
  
  # RSpec.describe CodeGeneratorController, type: :controller do
    # describe '#gemini_pro_request' do
    #   let(:description) { 'Write a story about a magic backpack.' }
    #   let(:success_response) { double(success?: true, parsed_response: { 'data' => 'Generated content' }) }
    #   let(:error_response) { double(success?: false, parsed_response: { 'error' => { 'message' => 'API error' } }) }
  
    #   before do
    #     allow(HTTParty).to receive(:post).and_return(response)
    #   end
  
    #   context 'when the API request is successful' do
    #     let(:response) { success_response }
  
    #     it 'returns the generated content' do
    #       post :code_generator_gemini_pro_request_path, params: { description: description }
    #       expect(JSON.parse(response.body)['data']).to eq('Generated content')
    #     end
    #   end
  
    #   context 'when the API request is unsuccessful' do
    #     let(:response) { error_response }
  
    #     it 'returns an error message' do
    #       post :code_generator_gemini_pro_request_path, params: { description: description }
    #       expect(JSON.parse(response.body)['error']).to eq('API error')
    #     end
    #   end
  
    #   context 'when an unexpected error occurs' do
    #     before do
    #       allow(HTTParty).to receive(:post).and_raise(StandardError.new('Unexpected error'))
    #     end
  
    #     it 'returns an error message' do
    #       post :code_generator_gemini_pro_request_path, params: { description: description }
    #       expect(JSON.parse(response.body)['error']).to eq('An unexpected error occurred while generating the content.')
    #     end
    #   end
    # end
  # end
# end
