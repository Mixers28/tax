require "json"

seed_path = Rails.root.join("..", "docs", "references", "sa-forms-2025-boxes-first-pass.json").cleanpath

unless File.exist?(seed_path)
  warn "Seed file not found: #{seed_path}"
  exit 1
end

boxes = JSON.parse(File.read(seed_path))

forms = {}
pages = {}
allowed_pages = {
  "SA100" => %w[TR1 TR2 TR4 TR5 TR7 TR8],
  "SA102" => %w[E1],
  "SA106" => %w[F1 F6],
  "SA110" => %w[TC1]
}

boxes.each do |entry|
  form_code = entry.fetch("form")
  page_code = entry.fetch("page")
  next unless allowed_pages.fetch(form_code, []).include?(page_code)
  year = 2025

  form = forms[form_code] ||= FormDefinition.find_or_create_by!(code: form_code, year: year)

  page_key = "#{form_code}-#{page_code}"
  page = pages[page_key] ||= PageDefinition.find_or_create_by!(
    form_definition_id: form.id,
    page_code: page_code
  )

  box_code = entry.fetch("box").to_s
  instance = (entry["instance"] || 1).to_i

  box = BoxDefinition.find_or_initialize_by(
    page_definition_id: page.id,
    box_code: box_code,
    instance: instance
  )
  box.hmrc_label = entry.fetch("label")
  box.data_type = entry.fetch("type", "text")
  box.save!
end

puts "Seeded #{BoxDefinition.count} box definitions across #{PageDefinition.count} pages."
