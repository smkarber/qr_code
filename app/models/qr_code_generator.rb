class QrCodeGenerator < ApplicationRecord

  def construct_qr(correction_level=:L, mode=:byte)
    vers = select_version(url, correction_level, mode)
    raw_qr_str = "#{mode_indicator(mode)}#{character_count_indicator(vers, mode)}#{encode_data}"
    req_num_bits = required_number_of_bits(vers, correction_level)
    qr_str = process_encoded_string(raw_qr_str, req_num_bits)
  end

  def mode_indicator(mode)
    return case mode
    when :numeric
      '0001'
    when :alphanumeric
      '0010'
    when :byte
      '0100'
    else
      '1000'
    end
  end

  def character_count_indicator(version, mode)
    cci_range = character_count_symbol(version)
    cci = CHARACTER_COUNT_INDICATOR[cci_range][mode]
    cc = url.length.to_s(2)
    while cc.length < cci
      cc = '0' + cc
    end
    return cc
  end

  def character_count_symbol(version)
    return case version
           when (1..9)
             :one_to_nine
           when (10..26)
             :ten_to_twenty_six
           else
             :twenty_seven_to_forty
           end
  end

  def character_capacity(version, correction_level, mode)
    CHARACTER_CAPACITY[version][correction_level][mode]
  end

  def required_number_of_bits(version, correction_level=:L)
    ERROR_CORRECTION_CODEWORDS[version][correction_level][:total_codewords] * 8
  end

  def select_version(str, correction_level=:L, mode=:byte)
    (1..40).each do |vers|
      if character_capacity(vers, correction_level, mode) >= str.length
        return vers
      end
    end
  end

  def process_encoded_string(raw_qr_string, req_num_bits)
    qr_str = build_terminator(raw_qr_string, req_num_bits)
    qr_str = make_divisible_by_eight(qr_str) if qr_str.length % 8 != 0
    qr_str = pad_qr_string(qr_str, req_num_bits) if qr_str.length < req_num_bits
    qr_str = qr_str.scan(/.{8}|.+/).join(' ')
  end

  def build_terminator(raw_qr_string, req_num_bits)
    term_zeroes = 0
    qr_str = raw_qr_string
    while qr_str.length < req_num_bits && term_zeroes < 4 do
      qr_str += '0'
      term_zeroes += 1
    end
    qr_str
  end

  def make_divisible_by_eight(qr_string)
    qr_str = qr_string
    while qr_str % 8 != 0
      qr_str += '0'
    end
    qr_str
  end

  def pad_qr_string(qr_string, req_num_bits)
    pad_arr = ['11101100', '00010001']
    pad_value = 0
    qr_str = qr_string
    while qr_str.length < req_num_bits
      qr_str += pad_arr[pad_value]
      pad_value ^= 1
    end
    qr_str
  end

  def encode_data(mode=:byte)
    return case mode
           when :numeric
             encode_numeric
           when :alphanumeric
             encode_alphanumeric
           when :byte
             encode_byte
           else
             encode_kanji
           end
  end

  def encode_numeric
    # TODO
  end

  def encode_alphanumeric
    # TODO
  end

  def encode_byte
    str_arr = url.split('')
    byte_arr = []
    str_arr.each do |char|
      byte_arr.push(char.unpack("B*"))
    end
    return byte_arr.join('')
  end

  def encode_kanji
    # TODO
  end
end
