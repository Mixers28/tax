require "json"
require "net/http"
require "uri"

class OllamaExtractionService
  class ExtractionError < StandardError; end

  DEFAULT_URL = "http://localhost:11434".freeze
  DEFAULT_MODEL = "gemma3:1b".freeze
  HEALTH_CHECK_TIMEOUT = 5

  def initialize(model: ENV.fetch("OLLAMA_MODEL", DEFAULT_MODEL), url: ENV.fetch("OLLAMA_URL", DEFAULT_URL))
    @model = model
    @url = url
  end

  def health_check
    uri = URI.join(@url, "/api/tags")
    request = Net::HTTP::Get.new(uri)

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: HEALTH_CHECK_TIMEOUT) do |http|
      response = http.request(request)
      response.code.to_i < 400
    end
  rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => _e
    false
  end

  def available?
    health_check
  rescue StandardError
    false
  end

  def extract_candidates(text)
    prompt = build_prompt(text)
    payload = { model: @model, prompt: prompt, stream: false }

    response = post_json("/api/generate", payload)
    raw = response.fetch("response", "")
    raise ExtractionError, "Empty response from Ollama" if raw.strip.empty?

    # Try to extract JSON from the response
    parsed = extract_json_from_response(raw)
    raise ExtractionError, "Response does not contain valid JSON" unless parsed

    candidates = parsed.fetch("candidates", [])
    unless candidates.is_a?(Array)
      raise ExtractionError, "Invalid candidates payload"
    end

    {
      prompt: prompt,
      response_raw: raw,
      candidates: candidates
    }
  rescue JSON::ParserError => e
    raise ExtractionError, "Failed to parse Ollama response: #{e.message}"
  end

  def extract_json_from_response(text)
    # Try direct JSON parse first
    begin
      return JSON.parse(text)
    rescue JSON::ParserError
      # Try to find JSON in the text
      match = text.match(/\{[\s\S]*\}/)
      return JSON.parse(match[0]) if match

      # If still no JSON, return empty candidates
      return { "candidates" => [] }
    end
  rescue StandardError
    nil
  end

  private

  def post_json(path, payload)
    uri = URI.join(@url, path)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = JSON.dump(payload)

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 30) do |http|
      response = http.request(request)
      body = JSON.parse(response.body)
      if response.code.to_i >= 400
        message = body["error"] || "HTTP #{response.code}"
        raise ExtractionError, message
      end
      body
    end
  rescue SocketError, Errno::ECONNREFUSED => e
    raise ExtractionError, "Failed to reach Ollama: #{e.message}"
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise ExtractionError, "Ollama request timed out: #{e.message}"
  rescue JSON::ParserError => e
    raise ExtractionError, "Invalid response from Ollama: #{e.message}"
  end

  def build_prompt(text)
    <<~PROMPT
      TASK: Extract tax values from UK Self Assessment PDF text.

      INSTRUCTIONS:
      1. Return ONLY valid JSON. No other text.
      2. Extract ONLY values explicitly present in the text.
      3. Do NOT guess or make up values.
      4. If no values found, return: {"candidates": []}

      JSON FORMAT (REQUIRED):
      {
        "candidates": [
          {
            "form": "SA100",
            "page": "TR1",
            "box": "1",
            "instance": 1,
            "value_raw": "100.00",
            "confidence": 0.95,
            "note": "Source: line item"
          }
        ]
      }

      CONFIDENCE SCALE:
      - 0.9-1.0: Clearly visible value
      - 0.7-0.9: Likely value
      - 0.5-0.7: Uncertain value
      - Below 0.5: Do not include

      PDF TEXT TO EXTRACT FROM:
      ---
      #{text[0..2000]}
      ---

      RESPONSE (JSON ONLY):
    PROMPT
  end
end
