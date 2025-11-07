# frozen_string_literal: true

require 'base64'
require 'uri'
require 'rqrcode'
require 'chunky_png'

module CalendarsHelper
  DEFAULT_BASE_URL = 'http://localhost:3000'

  def calendar_share_url(calendar)
    base_url = ENV.fetch('APP_BASE_URL', nil) || request&.base_url || DEFAULT_BASE_URL
    base_url = "#{base_url}/" unless base_url.ends_with?('/')
    URI.join(base_url, Rails.application.routes.url_helpers.show_calendar_path(calendar)).to_s
  end

  def calendar_qr_code_data_uri(calendar)
    qrcode = RQRCode::QRCode.new(calendar_share_url(calendar))
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 2,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      fill: 'white',
      module_px_size: 6,
      size: 240
    )
    "data:image/png;base64,#{Base64.strict_encode64(png.to_s)}"
  end
end
