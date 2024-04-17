require 'httparty'

class CodeGeneratorController < ApplicationController
  ##
  # It looks like you have defined a new method, but it appears to be empty.
  def new
  end
  ##
  # The `generate` function takes a description as a parameter, generates code based on that
  # description, and stores the generated code in an instance variable.
  def generate
    @description = params[:description]
    @generated_code = generate_code(@description)
  end

  # def summary
  #   return "This is a summary of the code generator controller"
  # end
  private

  ##
  # The `generate_code` function makes a request to OpenAI API with a given description and returns
  # the generated code, handling errors and logging appropriately.
  # 
  # Args:
  #   description: The `generate_code` method takes a `description` parameter as input. This parameter
  # is used to make a request to the OpenAI API to generate code based on the provided description.
  # The method then processes the response from the API and returns the generated code if the request
  # is successful. If there is
  # 
  # Returns:
  #   The `generate_code` method returns the generated code as a string if the OpenAI request is
  # successful. If there is an error during the request or an unexpected error occurs, it logs the
  # error message and returns a JSON response with an error message and the corresponding HTTP status
  # code.
  
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

  ##
  # The `openai_request` function sends a request to the OpenAI API to generate code based on a given
  # description using GPT-3.5-turbo model.
  # 
  # Args:
  #   description: The `openai_request` method sends a request to the OpenAI API to generate code 
  #   based on a given description using the GPT-3.5-turbo model.
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
  ##
  # The `gemini_pro_request` function sends a POST request to the Gemini Pro API with a description
  # and handles the response accordingly.
  # 
  # Args:
  #   description: The `gemini_pro_request` method you provided is a Ruby method that makes a POST
  # request to the Gemini Pro API endpoint to generate content based on the provided description.
  # 
  # Returns:
  #   The `gemini_pro_request` method is returning the response from the API call if it is successful.
  # If the response is successful, it returns the parsed response from the API. If there is an error
  # in the response, it logs the error message and returns a JSON response with the error message and
  # a status of bad request. If there is an unexpected error during the API call, it logs the
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