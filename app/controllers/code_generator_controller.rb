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
    begin
      response = openai_request(description)
      if response.success?
        return response['choices'].first['text'].strip
      else
        error_message = response.parsed_response['error']&.dig('message') || "Unknown error"
        Rails.logger.error "OpenAI API error: #{error_message}"
        render json: { "error": error_message }, status: :bad_request
      end
    rescue StandardError => e
      Rails.logger.error "Error generating code: #{e.message}"
      render json: { "error": "An unexpected error occurred while generating the code." }, status: :internal_server_error
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


  # Gemini Pro Request with Github Copilot
  def gemini_pro_request(description)
    begin
      url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_GOOGLE_API_KEY'
      headers = {
        'Content-Type' => 'application/json'
      }
      body = {
        "contents": [{
          "parts": [{
            "text": description
          }]
        }]
      }.to_json
      response = HTTParty.post(url, body: body, headers: headers)
      if response.success?
        return response.parsed_response
      else
        error_message = response.parsed_response['error']['message'] || "Unknown error"
        Rails.logger.error "Gemini Pro API error: #{error_message}"
        render json: { "error": error_message }, status: :bad_request
      end
    rescue StandardError => e
      Rails.logger.error "Error generating content: #{e.message}"
      render json: { "error": "An unexpected error occurred while generating the content." }, status: :internal_server_error
    end
  end
end