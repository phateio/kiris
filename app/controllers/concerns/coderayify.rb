class CodeRayify < Redcarpet::Render::HTML
  def block_code(code, language)
    language ||= :plaintext
    CodeRay.scan(code, language).div
  end
end
