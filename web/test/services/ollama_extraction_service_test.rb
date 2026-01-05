require "test_helper"

class OllamaExtractionServiceTest < ActiveSupport::TestCase
  def setup
    @service_class = OllamaExtractionService
    @default_url = "http://localhost:11434"
    @default_model = "gemma3:1b"
  end

  test "extracts candidates with successful response" do
    mock_response = {
      "response" => JSON.dump({
        "candidates" => [
          {
            "form" => "SA100",
            "page" => "TR1",
            "box" => "1",
            "instance" => 1,
            "value_raw" => "1000",
            "confidence" => 0.95,
            "note" => "Income from trading"
          }
        ]
      })
    }

    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    result = service.extract_candidates("Sample tax PDF text")

    assert_equal "Sample tax PDF text", nil # We'll check the prompt is built
    assert result[:candidates].is_a?(Array)
    assert_equal 1, result[:candidates].size
    assert_equal "SA100", result[:candidates][0]["form"]
  end

  test "raises error on empty Ollama response" do
    mock_response = { "response" => "" }

    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    error = assert_raises(OllamaExtractionService::ExtractionError) do
      service.extract_candidates("Sample text")
    end
    assert_equal "Empty response from Ollama", error.message
  end

  test "raises error on invalid candidates payload" do
    mock_response = {
      "response" => JSON.dump({
        "candidates" => "not an array"
      })
    }

    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    error = assert_raises(OllamaExtractionService::ExtractionError) do
      service.extract_candidates("Sample text")
    end
    assert_equal "Invalid candidates payload", error.message
  end

  test "raises error on invalid JSON response" do
    mock_response = { "response" => "{ invalid json }" }

    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    error = assert_raises(OllamaExtractionService::ExtractionError) do
      service.extract_candidates("Sample text")
    end
    assert error.message.include?("Failed to parse Ollama response")
  end

  test "raises error on HTTP error responses" do
    error_response = { "error" => "Model not found" }

    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(404, error_response))

    error = assert_raises(OllamaExtractionService::ExtractionError) do
      service.extract_candidates("Sample text")
    end
    assert_equal "Model not found", error.message
  end

  test "raises error when connection to Ollama fails" do
    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Errno::ECONNREFUSED, "Connection refused")

    error = assert_raises(OllamaExtractionService::ExtractionError) do
      service.extract_candidates("Sample text")
    end
    assert error.message.include?("Failed to reach Ollama")
  end

  test "handles custom model configuration" do
    custom_model = "custom-model:7b"
    mock_response = {
      "response" => JSON.dump({ "candidates" => [] })
    }

    service = @service_class.new(model: custom_model)
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    result = service.extract_candidates("Sample text")

    assert result[:candidates].is_a?(Array)
  end

  test "handles custom URL configuration" do
    custom_url = "http://remote-ollama:11434"
    mock_response = {
      "response" => JSON.dump({ "candidates" => [] })
    }

    service = @service_class.new(url: custom_url)
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    result = service.extract_candidates("Sample text")

    assert result[:candidates].is_a?(Array)
  end

  test "returns empty candidates array when no candidates found" do
    mock_response = {
      "response" => JSON.dump({ "candidates" => [] })
    }

    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    result = service.extract_candidates("Sample text with no tax data")

    assert_equal [], result[:candidates]
  end

  test "includes prompt in result" do
    mock_response = {
      "response" => JSON.dump({ "candidates" => [] })
    }

    service = @service_class.new
    allow_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_http_response(200, mock_response))

    result = service.extract_candidates("Sample text")

    assert result[:prompt].include?("UK Self Assessment")
    assert result[:prompt].include?("Sample text")
    assert result[:response_raw].present?
  end

  private

  def mock_http_response(code, body)
    response = Net::HTTPResponse.new(code, 200, "OK")
    response.instance_variable_set(:@body, JSON.dump(body))
    allow(response).to receive(:code).and_return(code.to_s)
    allow(response).to receive(:body).and_return(JSON.dump(body))
    response
  end
end
