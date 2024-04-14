require 'httparty'

class CodeGeneratorController < ApplicationController
  def new
  end

  def generate
    @description = params[:description]
    @generated_code = generate_code(@description)
  end

  private

  def generate_code(description)
    response = openai_request(description)
    if response.success?
      begin
        return response['choices'].first['text'].strip
      rescue StandardError => e
        # Handle parsing error or other unexpected issues
        Rails.logger.error "Error parsing response: #{e.message}"
        render json: { "error": "An unexpected error occurred while processing the response." }, status: :internal_server_error
      end
    else
      error_message = response.parsed_response['error']&.dig('message') || "Unknown error"
      Rails.logger.error "OpenAI API error: #{error_message}"
      render json: { "error": error_message }, status: :bad_request
    end
  end
  

  def openai_request(description)
    begin
      url = 'https://api.openai.com/v1/completions'
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}"
      }
      body = {
        model: 'gpt-3.5-turbo',
        prompt: "Generate code for: #{description}",
        max_tokens: 100
      }.to_json
      p "Request Ready"

      HTTParty.post(url, body: body, headers: headers)
    rescue StandardError => e
      p "Something Went Wrong"
    end
  end
end
